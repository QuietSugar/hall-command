#!/bin/bash
# ====================================================
#   @version:		1.0.1
#   检查，用于提醒一些可能存在的问题
#
#   用法：check.sh <项目名1> [项目名2] ...
# ====================================================

. "$(dirname "$0")/lib/init.sh"
. "$(dirname "$0")/lib/git_tool.sh"

find_some_dir() {
  local key_word="$1"
  local target_dirs
  target_dirs=$(find ~ -maxdepth 3 -type d -name "*${key_word}*" -print0 | while IFS= read -r -d '' dir; do
      realpath_compat "$dir"
  done)
  if [ -n "${target_dirs}" ]; then
      log_warning "找到包含 ${key_word} 的文件夹，路径如下："
      log_warning "${target_dirs}"
  fi
}

if [ $# -eq 0 ]; then
  log_warning "用法: $0 <项目名1> [项目名2] ..."
  exit 0
fi

for keyword in "$@"; do
  find_some_dir "$keyword"
done
