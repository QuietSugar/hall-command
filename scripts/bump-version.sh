#!/bin/bash

# 读取 VERSION 并自动递增 patch 版本号
# 支持：1.0.8 -> 1.0.9, v1.0.8 -> v1.0.9

version_file="${1:-VERSION}"

if [ ! -f "$version_file" ]; then
    echo "错误：$version_file 不存在" >&2
    exit 1
fi

version=$(sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' "$version_file")

if [ -z "$version" ]; then
    echo "错误：$version_file 内容为空" >&2
    exit 1
fi

if [[ "$version" =~ ^(v?)([0-9]+)\.([0-9]+)\.([0-9]+)$ ]]; then
    prefix="${BASH_REMATCH[1]}"
    major="${BASH_REMATCH[2]}"
    minor="${BASH_REMATCH[3]}"
    patch="${BASH_REMATCH[4]}"
    new_version="${prefix}${major}.${minor}.$((patch + 1))"
    printf '%s\n' "$new_version" > "$version_file"
    echo "VERSION 已递增为: $new_version"
else
    echo "错误：无法解析版本号格式: $version" >&2
    exit 1
fi
