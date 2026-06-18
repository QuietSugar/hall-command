#!/bin/bash
# ====================================================
#   代理快捷设置
#   安装后由 ~/.hall-command/source 自动 source
# ====================================================

proxy() {
    if [ -z "$1" ]; then
        echo "用法: proxy <http://host:port> 或 proxy <https://host:port>" >&2
        return 1
    fi
    case "$1" in
        http://*|https://*)
            export http_proxy="$1"
            export https_proxy="$1"
            export all_proxy="$1"
            echo "代理已设置为: $1"
            ;;
        *)
            echo "代理地址必须以 http:// 或 https:// 开头" >&2
            return 1
            ;;
    esac
}

unproxy() {
    unset http_proxy https_proxy all_proxy
    echo "代理已取消"
}
