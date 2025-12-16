#!/bin/bash

## @version:		1.0.2

## @description:
# ====================================================
#   初始化变量,用于其他脚本调用,配置文件统一放在 $HOME/.xu/config/下
#   配置文件内容的的格式是 key=value
#   如何使用: source load_config.sh .testConfig 表示加载文件夹下的.testConfig 配置文件
#
# ====================================================

if [ -n "$1" ]; then
  # 准备加载配置文件
  configFile="$HOME/.hall-command/env"
  log_debug '--->>> load env from :↓↓↓ '$configFile
  if [ -e $configFile ]; then
    while read line || [[ -n ${line} ]];do
      eval "$line"
      log_debug $line
    done < $configFile
    log_debug "--->>> load env from : finish load"
  else
   log_debug '文件不存在'$configFile
  fi
fi


