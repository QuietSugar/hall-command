#!/bin/bash

[ -f ".gitkeep" ] && [ "$(cat .gitkeep)" = "HALL-COMMAND" ] || { echo "不是预期目录"; exit 1; }

if ! command -v git &> /dev/null; then
    echo "错误: 系统中未安装 git 命令"
    exit 1
fi

if git rev-parse --git-dir > /dev/null 2>&1; then
    echo "当前目录已处于 git 管理之下，退出"
    exit 1
fi

# 检查远程仓库是否网络可达
if ! curl -s --connect-timeout 1 https://github.com/QuietSugar/hall-command.git > /dev/null; then
    echo "错误: 远程仓库 https://github.com/QuietSugar/hall-command.git 不可达"
    exit 1
fi

# 初始化 git 仓库并关联远程仓库
git init
git remote add origin https://github.com/QuietSugar/hall-command.git
git reset --hard
git clean -fd
# git -c https.proxy=http://proxy.server:port pull origin master
git pull origin master
git status



