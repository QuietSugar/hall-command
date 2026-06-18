#!/bin/bash

# ====================================================
#   @version:		1.0.0
#   显示当前 hall-command 版本
#
#   安装类型后缀：
#     -dev     从本地 git 仓库安装，且安装时存在未提交修改
#     -release 从 release 包（curl/wget）安装
#     无后缀   从干净的 git 仓库安装
# ====================================================

# 去除字符串前后空白（不删除中间空白）
trim() {
    local var="$1"
    var="${var#"${var%%[![:space:]]*}"}"  # 去除开头空白
    var="${var%"${var##*[![:space:]]}"}"  # 去除结尾空白
    printf '%s' "$var"
}

get_version() {
    local script_dir
    script_dir="$(cd -P -- "$(dirname -- "$0")" && pwd)"

    local install_root="${script_dir}/.."
    local version=""

    # 优先读取安装目录下的 VERSION 文件
    if [ -f "${install_root}/VERSION" ]; then
        version=$(trim "$(cat "${install_root}/VERSION")")
    fi

    # 开发环境：从 git tag 获取（没有 VERSION 文件时）
    if [ -z "$version" ] && command -v git >/dev/null 2>&1 && git -C "$script_dir" rev-parse --git-dir >/dev/null 2>&1; then
        version=$(git -C "$script_dir" describe --tags --always 2>/dev/null)
    fi

    [ -z "$version" ] && version="unknown"

    local install_type=""
    local commit_id=""

    # 优先读取 install 时记录的安装类型和 commit ID
    if [ -f "${install_root}/.install-type" ]; then
        install_type=$(trim "$(cat "${install_root}/.install-type")")
    elif [ -d "${install_root}/.git" ]; then
        # 开发模式：直接运行 command/hversion.sh，install_root 是仓库根目录
        if git -C "$install_root" status --porcelain 2>/dev/null | grep -q .; then
            install_type="dev"
        fi
    else
        install_type="release"
    fi

    if [ -f "${install_root}/.install-commit" ]; then
        commit_id=$(trim "$(cat "${install_root}/.install-commit")")
    elif [ -d "${install_root}/.git" ]; then
        # 开发模式：直接读取当前 commit ID
        commit_id=$(git -C "$install_root" rev-parse --short HEAD 2>/dev/null)
    fi

    local result="$version"
    if [ -n "$install_type" ] && [ "$install_type" != "git" ]; then
        result="${result}-${install_type}"
    fi

    if [ -n "$commit_id" ]; then
        result="${result} ${commit_id}"
    fi

    echo "$result"
}

echo "hall-command $(get_version)"
