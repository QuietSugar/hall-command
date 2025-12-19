#!/bin/bash

set -e
HALL_COMMAND_NAME="hall-command"
# git 相关目录
THIS_GIT_USER_DIR="${HOME}/git-repo/github.com/QuietSugar"
HALL_COMMAND_GIT_DIR="${THIS_GIT_USER_DIR}/hall-command"
# 安装后的 相关目录
HALL_COMMAND_INSTALL_ROOT_PATH=${HOME}"/.${HALL_COMMAND_NAME}"


fetch(){
    if which curl > /dev/null; then
        if [ "$#" -eq 2 ]; then curl -fL -o "$1" "$2"; else curl -fsSL "$1"; fi
    elif which wget > /dev/null; then
        if [ "$#" -eq 2 ]; then wget -O "$1" "$2"; else wget -nv -O - "$1"; fi
    else
        echo "Can't find curl or wget, can't download package"
        exit 1
    fi
}

get_latest_release_url(){
    if [ -n "${RELEASE_FILE_URL}" ]; then
        echo ${RELEASE_FILE_URL}
    else
        releases=$(fetch https://api.github.com/repos/QuietSugar/hall-command/releases/latest)
        url=$(echo "$releases" | grep -wo -m1 "https://.*.tar.gz" || true)
        echo ${url}
    fi
}
download_and_un_tar(){
  url=$(get_latest_release_url)
  echo "下载自来：${url}"
  if ! test "$url"; then
      echo "Could not find release info"
      exit 1
  fi

  echo "Downloading hall-command..."

  temp_dir=$(mktemp -dt hall-command.XXXXXX)
  trap 'rm -rf "$temp_dir"' EXIT INT TERM
  cd "$temp_dir"

  if ! fetch hall-command.tar.gz "$url"; then
      echo "Could not download tarball"
      exit 1
  fi

  # 此时已经下载好了
  tar xzf hall-command.tar.gz
  mkdir -p ${THIS_GIT_USER_DIR}/
  mv hall-command ${THIS_GIT_USER_DIR}/
}


function install_from_git_dir() {
  mkdir -p ${HALL_COMMAND_INSTALL_ROOT_PATH}
  cp -r ${HALL_COMMAND_GIT_DIR}/command ${HALL_COMMAND_INSTALL_ROOT_PATH}/
  cp ${HALL_COMMAND_GIT_DIR}/example.env ${HALL_COMMAND_INSTALL_ROOT_PATH}/
  cp -r ${HALL_COMMAND_GIT_DIR}/source ${HALL_COMMAND_INSTALL_ROOT_PATH}/
  chmod -R +x ${HALL_COMMAND_INSTALL_ROOT_PATH}
  copy_sh_file
  install_done
}

# ====================================================
#   复制一份不带后缀的文件
#	  foo.sh ->  foo
# ====================================================
function copy_sh_file() {
  local command_path=${HALL_COMMAND_INSTALL_ROOT_PATH}/command
  pushd "${command_path}"
  for file in "${command_path}"/*.sh; do
    if [[ -f "$file" ]]; then
      cp -f $file $(basename $file .sh)
    fi
  done
  popd
}

function install_done() {
  if [ "Windows_NT" = "$OS" ]; then
    bin_ath=$(cygpath -w ${HALL_COMMAND_INSTALL_ROOT_PATH}/command)
  else
    bin_ath=${HALL_COMMAND_INSTALL_ROOT_PATH}/command
    mkdir -p $HOME/.zsh/source
    echo 'export PATH="'${bin_ath}':$PATH"' > $HOME/.zsh/source/${HALL_COMMAND_NAME}.sh
  fi
  cat <<'EOF'
# ====================================================================================
将以下脚本内容加入你的配置文件中
# 如果已经执行了 debian-init.sh 可以忽略以下内容
1. .profile
2. .bashrc 适用于linux和安装了git-bash的windows
3. .bash_profile  专门针对git-bash 位于git安装目录中
以下是具体内容:
# ====================================================================================
# set user's private env if it exists
if [ -d "$HOME/.hall-command/source" ]; then
  while IFS= read -r -d '' FILE; do
    if [ -f "$FILE" ]; then
      source "$FILE" || echo "[WARN] Failed to source: $FILE" >&2
    fi
  done < <(find "$HOME/.hall-command/source" -name '*.sh' -print0 | sort -z)
fi
# ====================================================================================
EOF

  echo "${bin_ath}"
  echo 'install done'
}

try_link(){
  cd "${HALL_COMMAND_GIT_DIR}"
  bash link.sh
}

main(){
  if [ -d "${HALL_COMMAND_GIT_DIR}" ]; then
    echo "GIT DIR 已经存在"
  else
    download_and_un_tar
  fi

  rm -rf "${HALL_COMMAND_INSTALL_ROOT_PATH}/command"

  local r_path
  r_path=$(realpath "${HALL_COMMAND_INSTALL_ROOT_PATH}")
  echo ".${HALL_COMMAND_NAME}开始安装"在"${r_path}"
  install_from_git_dir
  try_link
}

main


