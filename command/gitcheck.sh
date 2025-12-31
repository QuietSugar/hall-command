#!/bin/bash

# ====================================================
#   @version:		1.0.2
# ====================================================

# ====================================================
#   寻找目录下所有带 .git的目录,
#	并且检查是否有未提交文件
#	-a 打印CLEAN
#	-d DEBUG调试
#	-t 目标目录
#
# ====================================================

# 是否打印CLEAN的项目
PRINT_CLEAN=false
IS_DEBUG=false
# 目标项目目录 默认为当前目录
TARGET_CHECK_DIR=$(pwd)


. "$(dirname "$0")/lib/init.sh"

function lm_traverse_dir() {
  if [ "$IS_DEBUG" = true ]; then
    log_info "[ DEBUG 当前目录 ]"$(realpath .)
  fi
	# 判断.git文件是否存在,如果存在,表示当前目录是一个git仓库
	if [ -d ".git" ]; then
		local this_repo_relative_path=$(echo "$(pwd)" | sed "s#$TARGET_CHECK_DIR##")
		local this_repo_status=''
		if [ -n "$(git status -s)" ]; then
		  this_repo_status+="[未提交$(trim $(git status -s | wc -l))]"
		fi
		if [ -n "$(git remote -v)" ]; then
		  # 判断当前分支是否有远程跟踪分支
      if git rev-parse --abbrev-ref HEAD@{upstream} >/dev/null 2>&1; then
          # 判断是否有未推送
          if [ -n "$(git cherry -v)" ]; then
            this_repo_status+="[未推送$(git cherry -v | wc -l)]"
          fi
      else
          this_repo_status+="[无远程跟踪分支]"
      fi


			# 获取stash数量
			stash_count=$(git stash list | wc -l)
			stash_count=$(echo $stash_count | tr -d ' ')  # 去除可能的空白字符

			# 判断并输出结果
			if [ "$stash_count" -ne 0 ]; then
			    this_repo_status+="[储藏${stash_count}]"
			fi
		else
		  this_repo_status+="[无远程]"
		fi
    if [ -n "$this_repo_status" ]; then # 输出结果
			log_error "[ DIRTY ]$this_repo_status \${TARGET_CHECK_DIR}"$this_repo_relative_path
		else
      if [ "$PRINT_CLEAN" = true ]; then
        log_info "[ CLEAN ]"$this_repo_relative_path
      fi
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

while getopts "adt:" opt; do
  case $opt in
    a)
      PRINT_CLEAN=true
      echo "PRINT_CLEAN 设置为 true"
      ;;
    t)
      TARGET_CHECK_DIR=$(realpath $OPTARG)
      echo "TARGET_CHECK_DIR 设置为: $TARGET_CHECK_DIR"
      ;;
    d)
      IS_DEBUG=true
      ;;
    \?)
      echo "无效选项: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "选项 -$OPTARG 需要参数" >&2
      exit 1
      ;;
  esac
done

echo "PRINT_CLEAN: $PRINT_CLEAN"
echo "辅助设置 export TARGET_CHECK_DIR=${TARGET_CHECK_DIR}"

# 执行命令 如果需要接收参数,那就执行 lm_traverse_dir $1
log_info "此次检查当前目录: "${TARGET_CHECK_DIR}
cd $TARGET_CHECK_DIR
lm_traverse_dir $TARGET_CHECK_DIR

