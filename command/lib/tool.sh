#!/bin/bash

# 跨平台 realpath 兼容实现
# macOS 默认没有 realpath，用 cd + pwd 实现等效功能
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

trim() {
    local var="$1"
    var="${var#"${var%%[![:space:]]*}"}"  # 去除开头空白
    var="${var%"${var##*[![:space:]]}"}"  # 去除结尾空白
    echo -n "$var"
}
