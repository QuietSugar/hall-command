# hall-command

> 命令相关工具
>
> 目标运行环境：Linux、macOS、Windows git-bash。

# 注意

- 假定没有安装 `git`，只有 `wget` 或者 `curl`
- Windows 下请使用 `git-bash` 执行

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

> `install.sh` 会自动检测：如果它位于一个 hall-command 仓库内，会优先使用当前仓库作为源码目录；否则会下载远程 release 到 `~/.cache/hall-command/src`。

# 安装后说明

`install.sh` 会自动完成以下事情：

1. 将 `command/` 下的脚本复制到 `~/.hall-command/command/`
2. 生成不带 `.sh` 后缀的可执行命令副本
3. 从 `example.env` 生成 `~/.hall-command/env`（如果不存在）
4. 自动将 `~/.hall-command/command` 加入 shell 的 PATH：
   - Windows git-bash：`~/.bash_profile`、`~/.bashrc`
   - Linux/macOS：`~/.zshrc`、`~/.bashrc`、`~/.profile`
5. 如果 release 中附带 `checksums.txt`，下载后会自动校验

> **Windows 路径说明**：Windows 下会优先使用 Windows 用户目录（`C:\Users\<用户名>`）作为安装目标，而不是 MSYS/Cygwin 自己的 home 目录。

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

## 检查 Git 仓库状态

```bash
gitcheck -t /path/to/projects
```

常用选项：

- `-a`：同时打印 CLEAN 的项目
- `-r`：检查远程状态（未推送 / 无上游分支 / 无远程）
- `-t <dir>`：指定目标目录

## 批量归档 Git 仓库

```bash
gitarc /path/to/source
```

按 `remote.origin.url` 把找到的 `.git` 仓库移动到 `~/git-repo/` 下。

## 封装 git clone

```bash
gitclone https://github.com/user/repo.git
```

会按 URL 结构把仓库克隆到 `~/git-repo/` 下。

## 删除空目录

```bash
rm_empty_dir /path/to/dir
```

## 检查历史项目残留

```bash
check
```

# 更新

`install.sh` 会根据 `~/.hall-command` 目录是否存在自动判断是**安装**还是**更新**：

- 目录不存在 → 显示「开始安装」
- 目录已存在 → 显示「开始更新」，脚本文件覆盖，配置文件保留并提醒

更新时直接重新运行 `install.sh` 即可：

```bash
bash /path/to/hall-command/install.sh
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
| `PROXY_ADDR` | 代理地址（可在 `~/.hall-command/env` 中配置） | 空 |

配置文件示例见 `example.env`。

# 备注

如果你不想使用自动 PATH 配置，可以手动将以下路径加入环境变量：

```bash
export PATH="$HOME/.hall-command/command:$PATH"
```

`~/.hall-command/source/` 目录下的 `.sh` 文件会在 shell 启动时被自动 source：

```bash
if [ -d "$HOME/.hall-command/source" ]; then
  while IFS= read -r FILE; do
    if [ -f "$FILE" ]; then
      source "$FILE" || echo "[WARN] Failed to source: $FILE" >&2
    fi
  done < <(find "$HOME/.hall-command/source" -name '*.sh' -print | sort)
fi
```
