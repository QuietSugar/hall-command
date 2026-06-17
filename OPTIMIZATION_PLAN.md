# 优化修复计划

> 由 AI 扫描本项目后生成，供后续分批修复参考。

---

## 高优先级

### 1. 修改 `install.sh` 默认源码目录

**问题**：远程安装时把 release tarball 解压到 `~/git-repo/github.com/QuietSugar/hall-command`，路径不合理，把这个工具项目当成了普通开发项目。

**建议**：改为缓存目录：
```bash
HALL_COMMAND_GIT_DIR="${HALL_COMMAND_GIT_DIR:-${HOME}/.cache/hall-command/src}"
```

**涉及文件**：`install.sh`、`README.md`

---

### 2. Release workflow 生成校验和文件

**问题**：`.github/workflows/release.yml` 只发布 `.tar.gz` 和 `.zip`，没有 `.sha256`。`install.sh` 里的 `verify_checksum()` 永远找不到校验文件，形同虚设。

**建议**：在 workflow 中增加：
```yaml
- name: Generate checksums
  run: |
    sha256sum *.tar.gz *.zip > checksums.txt
```
并一起作为 release asset 上传。

**涉及文件**：`.github/workflows/release.yml`、`install.sh`（调整校验文件 URL）

---

### 3. 修复或清理 `tests/` 目录

**问题**：
- `tests/sloggi.sh` 引用 `../common/slog.sh`，该路径不存在
- `tests/xu_script_test.sh` 引用 `init.sh`，当前目录下不存在

**建议**：
- 修复引用路径：分别改为 `../command/lib/slog.sh` 和 `../command/lib/init.sh`
- 或如果测试已无意义，直接删除 `tests/` 目录

**涉及文件**：`tests/sloggi.sh`、`tests/xu_script_test.sh`

---

## 中优先级

### 4. `load_config.sh` 注释和实现不一致

**问题**：注释说配置在 `$HOME/.xu/config/`，实际代码读取 `$HOME/.hall-command/env`。

**涉及文件**：`command/lib/load_config.sh`

---

### 5. `eval "$line"` 读取配置存在安全风险

**问题**：
```bash
while read line; do
  eval "$line"
done < $configFile
```
如果 `.env` 被写入恶意命令会被执行。

**建议**：改为更安全的解析方式：
```bash
while IFS='=' read -r key value; do
    [ -n "$key" ] && export "$key=$value"
done < "$configFile"
```

**涉及文件**：`command/lib/load_config.sh`

---

### 6. `get_git_repo_path()` 支持环境变量覆盖

**问题**：`command/gitarc.sh` 和 `command/gitclone.sh` 把用户 git 项目根目录硬编码为 `~/git-repo`。

**建议**：支持环境变量覆盖：
```bash
get_git_repo_path() {
    local git_repo_path="${HALL_GIT_REPO_PATH:-${HOME}/git-repo}"
    mkdir -p "$git_repo_path"
    echo "$git_repo_path"
}
```

**涉及文件**：`command/lib/git_tool.sh`、`example.env`

---

### 7. `command/check.sh` 硬编码历史项目名

**问题**：
```bash
find_some_dir xu-command
find_some_dir ubuntu-server-init
find_some_dir InitHall
```

**建议**：改为从配置文件读取或作为参数传入：
```bash
check.sh xu-command ubuntu-server-init InitHall
```

**涉及文件**：`command/check.sh`

---

### 8. `command/gitclone.sh` 多处变量未加引号

**问题**：
```bash
project_relative_dir=$(make_filename_safe $cloneUrl)
project_name=$(echo ${project_relative_dir##*/} )
git clone  $cloneUrl $project_absolute_dir
```

**建议**：给所有变量加引号。

**涉及文件**：`command/gitclone.sh`

---

### 9. `command/gitarc.sh` 变量引号问题

**问题**：路径拼接和调用处有多处未引号。

**建议**：统一加引号，避免空格路径问题。

**涉及文件**：`command/gitarc.sh`

---

## 低优先级

### 10. `slog.sh` 顶部 banner 始终带颜色

**问题**：
```bash
printf "slog $(tput setaf 2)[...] \n";
```
在 `INTERACTIVE_MODE` 判断之前执行，非交互环境也会输出 ANSI 码。

**建议**：把 banner 放到颜色判断之后，或在非交互时禁用颜色。

**涉及文件**：`command/lib/slog.sh`

---

### 11. `command/http_proxy_set.sh` 路径硬编码

**问题**：
```bash
zsh_source_path=~/.hall-command/command/source
```
现在安装路径已固定为 `~/.hall-command`，所以暂时 OK，但代码健壮性一般。

**建议**：如果未来需要支持自定义安装路径，改为从统一配置读取。

**涉及文件**：`command/http_proxy_set.sh`

---

### 12. `INFO` 文件用途检查

**问题**：`INFO` 原本用于 `link.sh` 验证目录。`link.sh` 已删除。

**建议**：检查是否还有其他脚本依赖 `INFO`。如果没有，可以删除该文件。

**涉及文件**：`INFO`、各脚本

---

### 13. `AGENTS.md` 为空

**问题**：项目根目录的 `AGENTS.md` 没有任何内容。

**建议**：补充项目约定，例如：
- 代码风格（bash 脚本规范）
- 测试命令
- 提交规范

**涉及文件**：`AGENTS.md`

---

### 14. `example.env` 可扩展

**问题**：目前只有 `IF_CHECK_URL` 和 `PROXY_ADDR`。

**建议**：增加：
- `HALL_GIT_REPO_PATH`（用户 git 项目根目录）
- `HALL_LOG_LEVEL`

**涉及文件**：`example.env`

---

## 处理顺序建议

1. 高优先级 3 项先处理
2. 中优先级按依赖顺序处理
3. 低优先级可后续有空再处理
