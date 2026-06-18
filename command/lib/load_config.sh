#!/bin/bash

## @version:		1.0.3

## @description:
# ====================================================
#   初始化变量,用于其他脚本调用,配置文件统一放在 $HOME/.hall-command/ 下
#   配置文件内容的的格式是 key=value
#   如何使用: source load_config.sh 表示加载 $HOME/.hall-command/env 配置文件
#
# ====================================================

if [ -n "$1" ]; then
  # 准备加载配置文件
  configFile="$HOME/.hall-command/env"
  log_debug '--->>> load env from :↓↓↓ '$configFile
  if [ -e "$configFile" ]; then
    while IFS='=' read -r key value || [ -n "$key" ]; do
      # 跳过空行和注释
      key=$(echo "$key" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
      [ -z "$key" ] && continue
      case "$key" in
        \#*) continue ;;
      esac
      export "$key=$value"
      log_debug "$key=$value"
    done < "$configFile"
    log_debug "--->>> load env from : finish load"
  else
   log_debug '文件不存在'$configFile
  fi
fi


