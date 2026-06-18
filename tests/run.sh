#!/bin/bash
# ====================================================
#   统一测试入口
#   当前主要执行 bash 语法检查
# ====================================================

set -e

cd "$(dirname "$0")/.."

fail=0
for f in install.sh command/*.sh command/lib/*.sh source/*.sh tests/*.sh; do
    # 跳过自身和可能不存在的模式
    [ -f "$f" ] || continue
    if ! bash -n "$f"; then
        echo "[ERROR] 语法检查失败: $f" >&2
        fail=1
    fi
done

if [ "$fail" -ne 0 ]; then
    exit 1
fi

echo "[INFO] 所有脚本语法检查通过"
