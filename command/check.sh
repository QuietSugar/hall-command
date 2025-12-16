#!/bin/bash
# ====================================================
#   @version:		1.0.0
#   检查，用于提醒一些可能存在的问题
#
# ====================================================

. "$(dirname "$0")/lib/init.sh"
. "$(dirname "$0")/lib/git_tool.sh"

find_some_dir() {
  local key_word=$1
  target_dirs=$(find ~ -maxdepth 3 -type d -name "*${key_word}*" -exec realpath {} \;)
  if [ -n "${target_dirs}" ]; then
      log_warning "找到包含 ${target_dirs} 的文件夹，路径如下："
      log_warning "${target_dirs}"
  fi

}
find_some_dir xu-command
find_some_dir ubuntu-server-init
find_some_dir InitHall
