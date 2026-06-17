# hall-command

> 命令相关工具

# 注意

假定没有安装 git，只有 wget 或者 curl。
在 Windows 下面执行的时候需要使用 `git-bash`。

# 安装

## 方式一：从远程一键安装

```bash
curl -fsSL https://raw.githubusercontent.com/QuietSugar/hall-command/refs/heads/master/install.sh | bash
```

国内加速：

```bash
curl -fsSL https://gh-proxy.com/https://raw.githubusercontent.com/QuietSugar/hall-command/refs/heads/master/install.sh | bash
```

## 方式二：从本地已 clone 的仓库安装

如果你已经把项目 clone 到本地，进入项目目录后执行：

```bash
cd /path/to/hall-command
bash install.sh
```

> 只有当项目位于默认路径 `~/git-repo/github.com/QuietSugar/hall-command` 时，才不需要额外配置。

如果 clone 到了其他位置，通过环境变量指定仓库路径：

```bash
cd /path/to/hall-command
HALL_COMMAND_GIT_DIR="$(pwd)" bash install.sh
```

也可以手动指定安装目录：

```bash
HALL_COMMAND_GIT_DIR=/path/to/hall-command \
HALL_COMMAND_INSTALL_ROOT_PATH=/path/to/.hall-command \
bash /path/to/hall-command/install.sh
```

# 安装后说明

`install.sh` 会自动完成以下事情：

1. 将 `command/` 下的脚本复制到 `~/.hall-command/command/`
2. 生成不带 `.sh` 后缀的可执行命令副本
3. 从 `example.env` 生成 `~/.hall-command/.env`（如果不存在）
4. 自动将 `~/.hall-command/command` 加入 shell 的 PATH：
   - Windows git-bash：`~/.bash_profile`、`~/.bashrc`
   - Linux/macOS：`~/.zsh/source/hall-command.sh`、`~/.bashrc`、`~/.profile`
5. 如果发布时附带 `.sha256` 校验文件，下载后会自动校验

安装完成后，重新加载配置文件或重启终端即可使用：

```bash
source ~/.bashrc
# 或
source ~/.bash_profile
```

# 备注

如果你不想使用自动 PATH 配置，可以手动将以下路径加入环境变量：

```bash
export PATH="$HOME/.hall-command/command:$PATH"
```

`~/.hall-command/source/` 目录下的 `.sh` 文件会在 shell 启动时被自动 source（由 `install.sh` 写入的配置实现）：

```bash
if [ -d "$HOME/.hall-command/source" ]; then
  while IFS= read -r FILE; do
    if [ -f "$FILE" ]; then
      source "$FILE" || echo "[WARN] Failed to source: $FILE" >&2
    fi
  done < <(find "$HOME/.hall-command/source" -name '*.sh' -print | sort)
fi
```

# 说明

- 将脚本安装成命令 command

将一个脚本放进操作系统的环境变量中，那么就可以将脚本当做命令执行。
> 事先将一个目录设置进 PATH。

- 将脚本安装成别名 source
> 需要手动加载，或者在系统启动时放进 profile 中。
