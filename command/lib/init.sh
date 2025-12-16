#!/bin/bash

# ====================================================
#   @version:		1.0.1
# ====================================================

# ====================================================
# 初始化
# 1. 加载日志组件
# 2. 加载配置文件
#
# ====================================================

# 确定脚本的规范路径
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do
    DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
    SOURCE="$(readlink "$SOURCE")"
    [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done
# 脚本所在目录的路径
SCRIPT_DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

. $SCRIPT_DIR/slog.sh
. $SCRIPT_DIR/load_config.sh
. $SCRIPT_DIR/tool.sh
