#!/bin/bash

set -e
set -o pipefail

HALL_COMMAND_NAME="hall-command"

# 允许通过环境变量覆盖安装路径
THIS_GIT_USER_DIR="${HALL_COMMAND_GIT_USER_DIR:-${HOME}/git-repo/github.com/QuietSugar}"
HALL_COMMAND_GIT_DIR="${HALL_COMMAND_GIT_DIR:-${THIS_GIT_USER_DIR}/hall-command}"
HALL_COMMAND_INSTALL_ROOT_PATH="${HALL_COMMAND_INSTALL_ROOT_PATH:-${HOME}/.${HALL_COMMAND_NAME}}"

# 跨平台 realpath 兼容实现
# install.sh 需要自包含，不能依赖 command/lib/tool.sh（网络安装时该文件可能还不存在）
realpath_compat() {
    local path="$1"
    if [ -d "$path" ]; then
        (cd -P -- "$path" && pwd -P)
    elif [ -e "$path" ]; then
        local dir
        dir=$(cd -P -- "$(dirname -- "$path")" && pwd -P)
        printf '%s/%s\n' "$dir" "$(basename -- "$path")"
    else
        return 1
    fi
}

fetch(){
    # 说明：如果访问 GitHub API 时遇到速率限制，可设置 GITHUB_TOKEN 环境变量，
    # 并在 curl/wget 调用中添加认证头，例如：-H "Authorization: Bearer $GITHUB_TOKEN"
    if command -v curl >/dev/null 2>&1; then
        if [ "$#" -eq 2 ]; then
            curl -fL -o "$1" "$2"
        else
            curl -fsSL "$1"
        fi
    elif command -v wget >/dev/null 2>&1; then
        if [ "$#" -eq 2 ]; then
            wget -O "$1" "$2"
        else
            wget -nv -O - "$1"
        fi
    else
        echo "Can't find curl or wget, can't download package" >&2
        exit 1
    fi
}

get_latest_release_url(){
    if [ -n "${RELEASE_FILE_URL:-}" ]; then
        echo "${RELEASE_FILE_URL}"
    else
        releases=$(fetch https://api.github.com/repos/QuietSugar/hall-command/releases/latest)
        url=$(echo "$releases" | grep -wo -m1 "https://.*.tar.gz" || true)
        echo "${url}"
    fi
}

verify_checksum(){
    local tarball="$1"
    local url="$2"
    local checksum_url="${url}.sha256"
    local checksum_file="${tarball}.sha256"

    if ! fetch "${checksum_file}" "${checksum_url}" >/dev/null 2>&1; then
        echo "[WARN] 未找到校验文件 ${checksum_url}，跳过校验" >&2
        return 0
    fi

    local expected_hash actual_hash
    expected_hash=$(tr -d '[:space:]' < "${checksum_file}")

    if command -v sha256sum >/dev/null 2>&1; then
        actual_hash=$(sha256sum "${tarball}" | awk '{print $1}')
    elif command -v shasum >/dev/null 2>&1; then
        actual_hash=$(shasum -a 256 "${tarball}" | awk '{print $1}')
    else
        echo "[WARN] 未找到 sha256sum/shasum，跳过校验" >&2
        return 0
    fi

    if [ "$expected_hash" != "$actual_hash" ]; then
        echo "[ERROR] 校验和验证失败" >&2
        return 1
    fi

    echo "[INFO] 校验和验证通过"
}

download_and_un_tar(){
    url=$(get_latest_release_url)
    echo "下载来自：${url}"
    if [ -z "$url" ]; then
        echo "Could not find release info" >&2
        exit 1
    fi

    echo "Downloading hall-command..."

    temp_dir=$(mktemp -dt hall-command.XXXXXX)
    trap 'rm -rf "$temp_dir"' EXIT INT TERM
    cd "$temp_dir"

    if ! fetch hall-command.tar.gz "$url"; then
        echo "Could not download tarball" >&2
        exit 1
    fi

    verify_checksum hall-command.tar.gz "$url"

    tar xzf hall-command.tar.gz

    if [ ! -d "hall-command" ]; then
        echo "[ERROR] 解压后未找到 hall-command 目录" >&2
        exit 1
    fi

    mkdir -p "${THIS_GIT_USER_DIR}"
    rm -rf "${HALL_COMMAND_GIT_DIR}"
    mv hall-command "${HALL_COMMAND_GIT_DIR}"
}

install_from_git_dir() {
    mkdir -p "${HALL_COMMAND_INSTALL_ROOT_PATH}"
    local r_path
    r_path=$(realpath_compat "${HALL_COMMAND_INSTALL_ROOT_PATH}")
    echo ".${HALL_COMMAND_NAME} 开始安装在 ${r_path}"

    cp -r "${HALL_COMMAND_GIT_DIR}/command" "${HALL_COMMAND_INSTALL_ROOT_PATH}/"
    cp "${HALL_COMMAND_GIT_DIR}/example.env" "${HALL_COMMAND_INSTALL_ROOT_PATH}/"
    cp -r "${HALL_COMMAND_GIT_DIR}/source" "${HALL_COMMAND_INSTALL_ROOT_PATH}/"

    # 自动创建 .env（如果不存在）
    if [ ! -f "${HALL_COMMAND_INSTALL_ROOT_PATH}/.env" ]; then
        cp "${HALL_COMMAND_GIT_DIR}/example.env" "${HALL_COMMAND_INSTALL_ROOT_PATH}/.env"
    fi

    # 只给脚本加执行权限，而不是整个安装目录
    find "${HALL_COMMAND_INSTALL_ROOT_PATH}/command" -type f -name '*.sh' -exec chmod +x {} \;

    copy_sh_file
    install_done
}

# ====================================================
#   复制一份不带后缀的文件
#	  foo.sh ->  foo
# ====================================================
copy_sh_file() {
    local command_path="${HALL_COMMAND_INSTALL_ROOT_PATH}/command"
    pushd "${command_path}" >/dev/null || return
    for file in "${command_path}"/*.sh; do
        if [ -f "$file" ]; then
            local target_name
            target_name=$(basename "$file" .sh)
            cp -f "$file" "$target_name"
            chmod +x "$target_name"
        fi
    done
    popd >/dev/null || return
}

append_path_config(){
    local shell_rc="$1"
    local bin_path="$2"
    local start_marker="# HALL_COMMAND_PATH_START"
    local end_marker="# HALL_COMMAND_PATH_END"

    touch "$shell_rc"

    # 如果已存在旧的配置块，先移除，避免重复或路径变更后残留旧配置
    if grep -Fxq "$start_marker" "$shell_rc" 2>/dev/null; then
        local tmp_file
        tmp_file=$(mktemp)
        awk "/^${start_marker}$/{skip=1; next} /^${end_marker}$/{skip=0; next} !skip" "$shell_rc" > "$tmp_file"
        mv "$tmp_file" "$shell_rc"
    fi

    {
        echo ""
        echo "$start_marker"
        echo "# 由 install.sh 自动生成，请勿手动修改"
        echo "export PATH=\"${bin_path}:\$PATH\""
        echo "$end_marker"
    } >> "$shell_rc"
    echo "[INFO] 已更新 PATH 配置：${shell_rc}"
}

install_done() {
    local bin_path="${HALL_COMMAND_INSTALL_ROOT_PATH}/command"

    if [ "Windows_NT" = "${OS:-}" ]; then
        local win_bin_path
        win_bin_path=$(cygpath -w "$bin_path")
        echo "[INFO] Windows 安装路径：${win_bin_path}"
        append_path_config "${HOME}/.bash_profile" "$bin_path"
        append_path_config "${HOME}/.bashrc" "$bin_path"
    else
        mkdir -p "$HOME/.zsh/source"
        append_path_config "$HOME/.zsh/source/${HALL_COMMAND_NAME}.sh" "$bin_path"
        append_path_config "$HOME/.bashrc" "$bin_path"
        append_path_config "$HOME/.profile" "$bin_path"
    fi

    cat <<'EOF'
# ====================================================================================
# 已尝试自动配置 PATH。如果未生效，请重新加载 shell 配置文件或手动添加以下内容：
# 1. .profile
# 2. .bashrc（适用于 Linux 和 git-bash）
# 3. .bash_profile（git-bash）
# 以下是具体内容：
# ====================================================================================
# set user's private env if it exists
if [ -d "$HOME/.hall-command/source" ]; then
  while IFS= read -r FILE; do
    if [ -f "$FILE" ]; then
      source "$FILE" || echo "[WARN] Failed to source: $FILE" >&2
    fi
  done < <(find "$HOME/.hall-command/source" -name '*.sh' -print | sort)
fi
# ====================================================================================
EOF

    echo "${bin_path}"
    echo 'install done'
}

main(){
    if [ -d "${HALL_COMMAND_GIT_DIR}" ]; then
        echo "GIT DIR 已经存在"
    else
        download_and_un_tar
    fi

    rm -rf "${HALL_COMMAND_INSTALL_ROOT_PATH}/command"

    install_from_git_dir
}

main
