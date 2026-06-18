#!/bin/bash

YELLOW='\033[1;33m'
CLEAR='\033[0m'

function setup_proxy() {
    local source_path
    source_path="${HOME}/.hall-command/source"
    mkdir -p "${source_path}"
    local proxy_file="${source_path}/proxy.sh"
    if [ -s "${proxy_file}" ]; then
      # shellcheck disable=SC1090
      source "${proxy_file}"
    fi
    # 检查是否已设置代理
    local current_http_proxy
    current_http_proxy=$(printf '%s' "${http_proxy}" | head -n1)
    local current_https_proxy
    current_https_proxy=$(printf '%s' "${https_proxy}" | head -n1)

    if [ -n "$current_http_proxy" ] || [ -n "$current_https_proxy" ]; then
        printf '%b检测到当前已设置代理:%b\n' "$YELLOW" "$CLEAR"
        [ -n "$current_http_proxy" ] && echo "  HTTP_PROXY: $current_http_proxy"
        [ -n "$current_https_proxy" ] && echo "  HTTPS_PROXY: $current_https_proxy"

        printf "是否直接使用当前代理? [Y/n]: "
        read -r use_current < /dev/tty

        case $use_current in
            ''|y|Y|yes|YES)
                echo "将继续使用当前代理设置"
                return 0
                ;;
        esac
    fi

    printf "是否设置 HTTP/HTTPS 代理? [y/N]: "
    read -r set_proxy < /dev/tty

    case $set_proxy in
        y|Y|yes|YES)
            printf "请输入代理地址 (格式: http://proxy.host:port): "
            read -r proxy_url < /dev/tty

            if [ -n "$proxy_url" ]; then
                # 检测输入的字符串必须以http开头
                if [[ ! "$proxy_url" =~ ^https?:// ]]; then
                    echo "代理地址格式错误，必须以http://或https://开头"
                    return 1
                fi
                export http_proxy="$proxy_url"
                export https_proxy="$proxy_url"

                if grep -q "export http_proxy=" "${proxy_file}" 2>/dev/null; then
                    sed -i.bak "s|export http_proxy=.*|export http_proxy=\"$proxy_url\"|" "${proxy_file}"
                    rm -f "${proxy_file}.bak"
                else
                    echo "export http_proxy=\"$proxy_url\"" >> "${proxy_file}"
                fi

                if grep -q "export https_proxy=" "${proxy_file}" 2>/dev/null; then
                    sed -i.bak "s|export https_proxy=.*|export https_proxy=\"$proxy_url\"|" "${proxy_file}"
                    rm -f "${proxy_file}.bak"
                else
                    echo "export https_proxy=\"$proxy_url\"" >> "${proxy_file}"
                fi
                # shellcheck disable=SC1090
                source "${proxy_file}"
                echo "代理已设置为: $proxy_url"
            else
                echo "未输入代理地址，跳过代理设置"
            fi
            ;;
        *)
            echo "跳过代理设置"
            ;;
    esac

}


function unset_proxy() {
  unset http_proxy
  unset https_proxy
  unset all_proxy
  echo "Unset proxy"
}

alias proxy="setup_proxy"
alias unproxy="unset_proxy"
