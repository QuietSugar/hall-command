#!/bin/bash
# ====================================================
#   @version:		1.0.1
#   删除所有空目录
#
# ====================================================

. "$(dirname "$0")/lib/init.sh"

LOG_LEVEL_STDOUT="INFO"
set -e
# 基准目录
if [ $# -eq 0 ]; then
    SOURCE_BASE_ABS_PATH=$(realpath .)
    log_success "此次操作当前目录: "$SOURCE_BASE_ABS_PATH
else
    SOURCE_BASE_ABS_PATH=$(realpath $1)
    log_success "此次操作指定目录: "$SOURCE_BASE_ABS_PATH
fi

# 一次性操作 find $SOURCE_BASE_ABS_PATH -type d -empty -exec rmdir {} \;
log_info "删除可能存在的.DS_Store"
find $SOURCE_BASE_ABS_PATH -name ".DS_Store" -type f -print -delete
find $SOURCE_BASE_ABS_PATH -type d | sort -r | while read -r dir; do
    if [ -z "$(ls -A "$dir")" ]; then
        log_success "删除目录: "$dir
        rmdir "$dir"
    fi
done
