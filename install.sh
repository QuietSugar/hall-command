#!/bin/bash

set -e
set -o pipefail

HALL_COMMAND_NAME="hall-command"

# 在 Windows 的 git-bash/MSYS/Cygwin 中，$HOME 可能是 /home/hall 或 /cygdrive/c/cygwin64/home/hall
# 而不是 Windows 真正的用户目录 C:\Users\<user>。
# 因此 Windows 下优先使用 USERPROFILE，确保安装到 Windows 用户目录。
get_user_home() {
    if [ "Windows_NT" = "${OS:-}" ] && [ -n "${USERPROFILE:-}" ]; then
        cygpath -u "$USERPROFILE"
    else
        printf '%s' "$HOME"
    fi
}

HALL_COMMAND_HOME=$(get_user_home)

# 如果 install.sh 位于一个 hall-command 仓库内，优先使用当前仓库作为源码目录
script_dir="$(cd -P -- "$(dirname -- "$0")" && pwd)"
if [ -f "$script_dir/install.sh" ] && [ -d "$script_dir/command" ] && [ -d "$script_dir/source" ]; then
    HALL_COMMAND_GIT_DIR="$script_dir"
else
    HALL_COMMAND_GIT_DIR="${HALL_COMMAND_HOME}/.cache/hall-command/src"
fi
HALL_COMMAND_INSTALL_ROOT_PATH="${HALL_COMMAND_HOME}/.${HALL_COMMAND_NAME}"

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
        return 0
    fi

    local releases tag_name url
    releases=$(fetch https://api.github.com/repos/QuietSugar/hall-command/releases/latest)
    tag_name=$(printf '%s' "$releases" | grep -o '"tag_name": "[^"]*"' | head -n1 | sed 's/.*"tag_name": "//; s/"$//')

    if [ -z "$tag_name" ]; then
        echo "[ERROR] 无法从 GitHub API 获取最新版本" >&2
        return 1
    fi

    url="https://github.com/QuietSugar/hall-command/releases/download/${tag_name}/hall-command-${tag_name}.tar.gz"
    echo "${url}"
}

verify_checksum(){
    local tarball="$1"
    local url="$2"
    local checksum_url="${url%/*}/checksums.txt"
    local checksum_file="checksums.txt"
    local tarball_basename
    tarball_basename=$(basename -- "$tarball")

    if ! fetch "${checksum_file}" "${checksum_url}" >/dev/null 2>&1; then
        echo "[WARN] 未找到校验文件 ${checksum_url}，跳过校验" >&2
        return 0
    fi

    local expected_hash actual_hash
    expected_hash=$(awk -v name="${tarball_basename}" '$2 == name {print $1}' "${checksum_file}")

    if [ -z "$expected_hash" ]; then
        echo "[WARN] 在校验文件中未找到 ${tarball_basename}，跳过校验" >&2
        return 0
    fi

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
    local url
    url=$(get_latest_release_url)
    echo "下载来自：${url}"
    if [ -z "$url" ]; then
        echo "Could not find release info" >&2
        exit 1
    fi

    echo "Downloading hall-command..."

    local tarball_name
    tarball_name=$(basename -- "$url")
    temp_dir=$(mktemp -dt hall-command.XXXXXX)
    trap 'rm -rf "$temp_dir"' EXIT INT TERM
    cd "$temp_dir"

    if ! fetch "$tarball_name" "$url"; then
        echo "Could not download tarball" >&2
        exit 1
    fi

    verify_checksum "$tarball_name" "$url"

    tar xzf "$tarball_name"

    if [ ! -d "hall-command" ]; then
        echo "[ERROR] 解压后未找到 hall-command 目录" >&2
        exit 1
    fi

    mkdir -p "$(dirname -- "${HALL_COMMAND_GIT_DIR}")"
    rm -rf "${HALL_COMMAND_GIT_DIR}"
    mv hall-command "${HALL_COMMAND_GIT_DIR}"
}

copy_config_or_warn() {
    local src="$1"
    local dst="$2"
    if [ -f "$dst" ]; then
        echo "[WARN] 配置文件已存在，保留不变：$dst" >&2
    else
        cp "$src" "$dst"
        echo "[INFO] 已创建配置文件：$dst"
    fi
}

install_from_git_dir() {
    local is_update=false
    if [ -d "${HALL_COMMAND_INSTALL_ROOT_PATH}" ]; then
        is_update=true
    fi

    mkdir -p "${HALL_COMMAND_INSTALL_ROOT_PATH}"
    local r_path
    r_path=$(realpath_compat "${HALL_COMMAND_INSTALL_ROOT_PATH}")

    if [ "$is_update" = true ]; then
        echo ".${HALL_COMMAND_NAME} 开始更新：${r_path}"
    else
        echo ".${HALL_COMMAND_NAME} 开始安装：${r_path}"
    fi

    # 脚本文件直接覆盖
    cp -r "${HALL_COMMAND_GIT_DIR}/command" "${HALL_COMMAND_INSTALL_ROOT_PATH}/"
    cp -r "${HALL_COMMAND_GIT_DIR}/source" "${HALL_COMMAND_INSTALL_ROOT_PATH}/"

    # 版本号文件
    if [ -f "${HALL_COMMAND_GIT_DIR}/VERSION" ]; then
        cp "${HALL_COMMAND_GIT_DIR}/VERSION" "${HALL_COMMAND_INSTALL_ROOT_PATH}/VERSION"
    fi

    # 记录安装类型和 commit ID，供 hversion 命令读取
    if [ -d "${HALL_COMMAND_GIT_DIR}/.git" ]; then
        local commit_id
        commit_id=$(git -C "${HALL_COMMAND_GIT_DIR}" rev-parse --short HEAD 2>/dev/null)
        if [ -n "$commit_id" ]; then
            printf '%s\n' "$commit_id" > "${HALL_COMMAND_INSTALL_ROOT_PATH}/.install-commit"
        fi
        if git -C "${HALL_COMMAND_GIT_DIR}" status --porcelain 2>/dev/null | grep -q .; then
            printf 'dev\n' > "${HALL_COMMAND_INSTALL_ROOT_PATH}/.install-type"
        else
            printf 'git\n' > "${HALL_COMMAND_INSTALL_ROOT_PATH}/.install-type"
        fi
    else
        printf 'release\n' > "${HALL_COMMAND_INSTALL_ROOT_PATH}/.install-type"
    fi

    # 配置文件不覆盖，仅提醒
    copy_config_or_warn "${HALL_COMMAND_GIT_DIR}/example.env" "${HALL_COMMAND_INSTALL_ROOT_PATH}/example.env"
    copy_config_or_warn "${HALL_COMMAND_GIT_DIR}/example.env" "${HALL_COMMAND_INSTALL_ROOT_PATH}/env"

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

append_rc_block(){
    local shell_rc="$1"
    local marker="$2"
    local content="$3"
    local start_marker="# HALL_COMMAND_${marker}_START"
    local end_marker="# HALL_COMMAND_${marker}_END"

    touch "$shell_rc"

    # 如果已存在旧的配置块，先移除，避免重复或路径变更后残留旧配置
    if grep -Fxq "$start_marker" "$shell_rc" 2>/dev/null; then
        local tmp_file
        tmp_file=$(mktemp)
        awk "/^${start_marker}$/{skip=1; next} /^${end_marker}$/{skip=0; next} !skip" "$shell_rc" > "$tmp_file"
        mv "$tmp_file" "$shell_rc"
        rm -f "$tmp_file"
    fi

    {
        echo ""
        echo "$start_marker"
        echo "# 由 install.sh 自动生成，请勿手动修改"
        printf '%s\n' "$content"
        echo "$end_marker"
    } >> "$shell_rc"
    echo "[INFO] 已更新 ${marker} 配置：${shell_rc}"
}

append_path_config(){
    local shell_rc="$1"
    local bin_path="$2"
    local home_relative_path

    # 安装目录通常位于 HALL_COMMAND_HOME 下，生成相对于 $HOME 的 PATH
    # 如果不在（例如用户自定义路径），则回退到绝对路径
    if [ "${bin_path#${HALL_COMMAND_HOME}/}" != "$bin_path" ]; then
        home_relative_path="${bin_path#${HALL_COMMAND_HOME}/}"
        append_rc_block "$shell_rc" "PATH" "export PATH=\"\$HOME/${home_relative_path}:\$PATH\""
    else
        append_rc_block "$shell_rc" "PATH" "export PATH=\"${bin_path}:\$PATH\""
    fi
}

append_source_block(){
    local shell_rc="$1"
    local content
    content=$(cat <<'EOF'
if [ -d "$HOME/.hall-command/source" ]; then
  while IFS= read -r FILE; do
    if [ -f "$FILE" ]; then
      source "$FILE" || echo "[WARN] Failed to source: $FILE" >&2
    fi
  done < <(find "$HOME/.hall-command/source" -name '*.sh' -print | sort)
fi
EOF
)
    append_rc_block "$shell_rc" "SOURCE" "$content"
}

install_done() {
    local bin_path="${HALL_COMMAND_INSTALL_ROOT_PATH}/command"

    if [ "Windows_NT" = "${OS:-}" ]; then
        local win_bin_path
        win_bin_path=$(cygpath -w "$bin_path")
        echo "[INFO] Windows 安装路径：${win_bin_path}"
        append_path_config "${HALL_COMMAND_HOME}/.bash_profile" "$bin_path"
        append_path_config "${HALL_COMMAND_HOME}/.bashrc" "$bin_path"
        append_source_block "${HALL_COMMAND_HOME}/.bash_profile"
        append_source_block "${HALL_COMMAND_HOME}/.bashrc"
    else
        append_path_config "$HALL_COMMAND_HOME/.zshrc" "$bin_path"
        append_path_config "$HALL_COMMAND_HOME/.bashrc" "$bin_path"
        append_path_config "$HALL_COMMAND_HOME/.profile" "$bin_path"
        append_source_block "$HALL_COMMAND_HOME/.zshrc"
        append_source_block "$HALL_COMMAND_HOME/.bashrc"
        append_source_block "$HALL_COMMAND_HOME/.profile"
    fi

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
