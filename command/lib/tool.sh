#!/bin/bash
trim() {
    local var="$1"
    var="${var#"${var%%[![:space:]]*}"}"  # 去除开头空白
    var="${var%"${var##*[![:space:]]}"}"  # 去除结尾空白
    echo -n "$var"
}
