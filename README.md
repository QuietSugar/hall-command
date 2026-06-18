# hall-command

> 命令相关工具
>
> 目标运行环境：Linux、macOS、Windows git-bash。


# 安装

## 方式一：从远程一键安装

```bash
curl -fsSL https://raw.githubusercontent.com/QuietSugar/hall-command/refs/heads/master/install.sh | bash
```


## 方式二：从本地已 clone 的仓库安装

如果你已经把项目 clone 到本地，进入项目目录后执行：

```bash
cd /path/to/hall-command
bash install.sh
```

> `install.sh` 会自动检测：如果它位于一个 hall-command 仓库内，会优先使用当前仓库作为源码目录；否则会下载远程 release 到默认路径 `~/.cache/hall-command/src`。

如果 clone 到了其他位置，进入项目目录后执行：

```bash
cd /path/to/hall-command
bash install.sh
```

# 安装后说明

`install.sh` 会自动完成以下事情：

1. 将 `command/` 下的脚本复制到 `~/.hall-command/command/`
2. 生成不带 `.sh` 后缀的可执行命令副本
3. 从 `example.env` 生成 `~/.hall-command/env`（如果不存在）
4. 自动将 `~/.hall-command/command` 加入 shell 的 PATH：
   - Windows git-bash：`~/.bash_profile`、`~/.bashrc`
   - Linux/macOS：`~/.zshrc`、`~/.bashrc`、`~/.profile`
5. 如果 release 中附带 `checksums.txt`，下载后会自动校验

安装完成后，重新加载配置文件或重启终端即可使用：

```bash
source ~/.bashrc
# 或
source ~/.bash_profile
# 或（zsh）
source ~/.zshrc
```

# 常用命令

## 查看版本

```bash
hversion
```

输出示例：

```text
hall-command 1.0.7 abc1234   # 从干净的 git 仓库安装
hall-command 1.0.7-dev def56 # 从本地 git 仓库安装，且安装时存在未提交修改
hall-command 1.0.7-release   # 从 release 包（curl/wget）安装
```

# 发布

修改 `VERSION` 文件后，执行：

```bash
make release
```

`make release` 会：

1. 检查 `VERSION` 是否为空
2. 检查是否有未提交的修改
3. 检查对应 tag 是否已存在
4. 创建 tag 并推送到远程（只推送当前 tag）
5. 自动递增 `VERSION` 的 patch 版本号

示例：

```bash
echo "1.0.8" > VERSION
git add VERSION && git commit -m "bump version"
make release
# 已发布: 1.0.8
# VERSION 已递增为: 1.0.9
```

> 注意：release 前必须提交 `VERSION` 修改，且工作区需要干净。

# 环境变量

| 变量名 | 作用 | 默认值 |
|--------|------|--------|
| `HALL_GIT_REPO_PATH` | `gitclone` / `gitarc` 使用的本地 Git 项目根目录 | `~/git-repo` |
| `HALL_LOG_LEVEL` | 日志输出级别：`DEBUG` / `INFO` / `SUCCESS` / `WARNING` / `ERROR` | `INFO` |
| `PROXY_ADDR` | 代理地址（可在 `~/.hall-command/env` 中配置） | 空 |

配置文件示例见 `example.env`。

# 更新

`install.sh` 会根据 `~/.hall-command` 目录是否存在自动判断是**安装**还是**更新**：

- 目录不存在 → 显示「开始安装」
- 目录已存在 → 显示「开始更新」，脚本文件覆盖，配置文件保留并提醒

更新时直接重新运行 `install.sh` 即可：

```bash
bash /path/to/hall-command/install.sh
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
