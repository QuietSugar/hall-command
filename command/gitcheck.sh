#!/bin/bash

# ====================================================
#   @version:		1.0.1
# ====================================================

# ====================================================
#   寻找目录下所有带 .git的目录,
#	并且检查是否有未提交文件
#	需要传入参数 比如当前目录 .
#
# ====================================================

. "$(dirname "$0")/lib/init.sh"

function lm_traverse_dir() {
	# 判断.git文件是否存在,如果存在,表示当前目录是一个git仓库
	if [ -d ".git" ]; then
		local this_repo_relative_path=$(echo "$(pwd)" | sed "s#$BASE_PATH##")
		local this_repo_status=''
		if [ -n "$(git status -s)" ]; then
		  this_repo_status+="[未提交$(trim $(git status -s | wc -l))]"
		fi
		if [ -n "$(git remote -v)" ]; then
			# 判断是否有未推送
			if [ -n "$(git cherry -v)" ]; then
				this_repo_status+="[未推送$(git cherry -v | wc -l)]"
			fi

			# 获取stash数量
			stash_count=$(git stash list | wc -l)
			stash_count=$(echo $stash_count | tr -d ' ')  # 去除可能的空白字符

			# 判断并输出结果
			if [ "$stash_count" -ne 0 ]; then
			    this_repo_status+="[储藏$(stash_count)]"
			fi


		else
		  this_repo_status+="[无远程]"
		fi
    if [ -n "$this_repo_status" ]; then # 输出结果
			log_error "[ DIRTY ]$this_repo_status [ROOT_PATH]"$this_repo_relative_path
		else
			log_info "[ CLEAN ]"$this_repo_relative_path
    fi
	else
		# 当前目录不是一个git仓库文件夹,遍历进入处理
		for file in $(ls -a); do
			# 判断是否是目录
			if [ -d $file ]; then
				# 判断是不是 . 和 ..
				if [[ $file != '.' ]] && [[ $file != '..' ]]; then
					# echo '准备进入文件夹'$file
					# 进入当前目录
					cd $file
					lm_traverse_dir $file #遍历子目录
				fi
			fi
		done
	fi
	# echo '结束 文件夹: ---------------------------'$(pwd)
	cd ..
}
# 基准目录
BASE_PATH=$(pwd)

# 执行命令 如果需要接收参数,那就执行 lm_traverse_dir $1
if [ $# -eq 0 ]; then
	log_success "此次检查当前目录: "$(realpath .)
else
	log_success "此次检查指定目录: "$(realpath $1)
	BASE_PATH=$1
fi

cd $BASE_PATH
lm_traverse_dir $BASE_PATH
