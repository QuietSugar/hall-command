# Agent 指南

## 项目目标

hall-command 是一个 Bash 命令工具集合，目标是在以下三种环境都能运行：

- Linux（bash）
- macOS（bash/zsh）
- Windows（git-bash）

编写代码时应避免使用平台特有命令，优先使用 POSIX 兼容写法；路径、权限、行尾符等需考虑三端差异。

## 项目简介

hall-command 通过 `install.sh` 安装到 `~/.hall-command/`，并将 `command/` 目录加入 PATH。

## 代码风格

- 脚本统一使用 `#!/bin/bash`，库文件兼容 POSIX 的可保留 `#!/bin/sh`。
- 变量引用尽量加双引号，避免空格路径问题。
- 路径拼接使用 `"$base/$name"` 形式。
- 使用 `set -e` 时需谨慎，确保不会误伤正常流程。

## 目录结构

- `command/`：可执行脚本。
- `command/lib/`：脚本依赖的库文件（`init.sh`、`slog.sh`、`tool.sh`、`git_tool.sh`、`load_config.sh`）。
- `source/`：安装后会被自动 source 的 `.sh` 文件。例如 `source/proxy.sh` 提供 `proxy`/`unproxy` 别名和代理设置功能。
- `tests/`：测试脚本（引用路径需保持正确）。

## 配置

- 项目版本号统一维护在 `VERSION` 文件中，release workflow 和 install 脚本应优先从此文件读取。
- 配置文件位于 `~/.hall-command/env`，格式为 `key=value`。
- 示例配置见 `example.env`。
- 关键环境变量：
  - `HALL_COMMAND_GIT_DIR`：本地源码目录，默认 `~/.cache/hall-command/src`。
  - `HALL_GIT_REPO_PATH`：git 项目根目录，默认 `~/git-repo`。
  - `HALL_LOG_LEVEL`：日志级别，可选 DEBUG/INFO/SUCCESS/WARNING/ERROR。

## 测试

- 统一入口：`bash tests/run.sh`，会执行全量 `bash -n` 语法检查。
- 也可手动运行 `tests/sloggi.sh` 验证日志组件。
- 修改后建议至少执行 `bash tests/run.sh`。

## 提交规范

- 提交信息使用中文或英文，简要说明修改内容。
- 涉及多个文件时，按高/中/低优先级分阶段提交更清晰。
