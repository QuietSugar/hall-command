#!/bin/bash

## @version:		1.1.5

## @description:
# ====================================================
#   针对 git clone 的封装
#	  请事先做好账户认证,需要在执行git clone的情况下不需要输入用户名和密码
#   参数1: 克隆的URL
#
# ====================================================

. "$(dirname "$0")/lib/init.sh"
. "$(dirname "$0")/lib/git_tool.sh"


LOG_LEVEL_STDOUT="DEBUG"

cloneUrl=$1

is_git_url_https_ssh $cloneUrl
local_git_repo_path=$(get_git_repo_path)

log_success "【项目远程地址         】$cloneUrl"
# 项目-相对路径
project_relative_dir=$(make_filename_safe $cloneUrl)
log_debug "【项目相对路径           】$project_relative_dir"
project_name=$(echo ${project_relative_dir##*/} )
log_debug "【项目名称               】$project_name"
project_parent_relative_dir=${project_relative_dir%/*}
log_debug "【项目父目录的相对路径   】$project_parent_relative_dir"
project_parent_absolute_dir="$local_git_repo_path/$project_parent_relative_dir"
log_debug "【项目父目录的绝对路径   】$project_parent_absolute_dir"
project_absolute_dir="$project_parent_absolute_dir/$project_name"
log_success "【项目的绝对路径         】$project_absolute_dir"

# 预先准备父目录
if [ ! -d "$project_parent_absolute_dir" ]; then
  mkdir -p "$project_parent_absolute_dir"
fi
if [ ! -d "$project_absolute_dir" ]; then
  git clone  $cloneUrl $project_absolute_dir
else
  log_warning "已存在,跳过   】$project_absolute_dir"
fi

cd "$project_parent_absolute_dir/$project_name"

