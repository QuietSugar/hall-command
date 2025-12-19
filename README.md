# hall-command

> 命令相关工具

# 注意
假定没有安装git, 只有 wget 或者 curl

# 安装

- 一键安装

```bash
curl -fsSL https://raw.githubusercontent.com/QuietSugar/hall-command/refs/heads/master/install.sh | bash
```


- 一键安装（cn）

```bash
curl -fsSL https://gh-proxy.com/https://raw.githubusercontent.com/QuietSugar/hall-command/refs/heads/master/install.sh | bash

```

# 备注

```bash
# ====================================================================================
将以下脚本内容加入你的配置文件中
# 如果已经执行了 debian-init.sh 可以忽略以下内容
1. .profile
2. .bashrc 适用于linux和安装了git-bash的windows
3. .bash_profile  专门针对git-bash 位于git安装目录中
   以下是具体内容:
# ====================================================================================
# set user's private env if it exists
if [ -d "$HOME/.hall-command/source" ]; then
while IFS= read -r -d '' FILE; do
if [ -f "$FILE" ]; then
source "$FILE" || echo "[WARN] Failed to source: $FILE" >&2
fi
done < <(find "$HOME/.hall-command/source" -name '*.sh' -print0 | sort -z)
fi
# ====================================================================================
```


# 说明

- 将脚本安装成命令 command

将一个脚本放进操作系统的环境变量中,那么就可以将脚本当做命令执行
> 事先将一个目录设置进PATH

- 将脚本安装成别名 source
> 需要手动加载,或者在系统启动时放进profile中

# 注意

- 在 Windows 下面执行的时候需要使用`git-bash`执行

