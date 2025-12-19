#!/bin/bash

# 纳入git管理并更新

[ -f "INFO" ] && [ "$(sed 's/^[[:space:]]*//;s/[[:space:]]*$//' INFO)" = "HALL-COMMAND" ] || { echo "不是预期目录"; exit 1; }

if ! command -v git &> /dev/null; then
    echo "错误: 系统中未安装 git 命令"
    exit 1
fi


# 检查是否存在代理设置
if [[ -n "$https_proxy" || -n "$HTTPS_PROXY" ]]; then
    GIT_PROXY_CONFIG="-c https.proxy=$https_proxy"
elif [[ -n "$http_proxy" || -n "$HTTP_PROXY" ]]; then
    GIT_PROXY_CONFIG="-c https.proxy=$http_proxy"
else
    GIT_PROXY_CONFIG=""
fi

git_pull(){
  if [ -n "$GIT_PROXY_CONFIG" ]; then
      git $GIT_PROXY_CONFIG pull origin master
  else
      git pull origin master
  fi
}

if git rev-parse --git-dir > /dev/null 2>&1; then
    echo "当前目录已处于 git 管理之下，退出"
    git_pull
    exit 1
fi

# 检查远程仓库是否网络可达
if ! curl -s --connect-timeout 1 https://github.com/QuietSugar/hall-command.git > /dev/null; then
    echo "错误: 远程仓库 https://github.com/QuietSugar/hall-command.git 不可达"
    exit 1
fi


# 使用初始化和拉取命令时加入代理配置（如有）
git init
git remote add origin https://github.com/QuietSugar/hall-command.git

# 应用重置与清理操作
git reset --hard
git clean -fd

git_pull
git branch --set-upstream-to=origin/master master

git status
