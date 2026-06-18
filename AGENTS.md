# Agent 指南

## 项目简介

hall-command 是一个 Bash 命令工具集合，通过 `install.sh` 安装到 `~/.hall-command/`，并将 `command/` 目录加入 PATH。

## 代码风格

- 脚本统一使用 `#!/bin/bash`，库文件兼容 POSIX 的可保留 `#!/bin/sh`。
- 变量引用尽量加双引号，避免空格路径问题。
- 路径拼接使用 `"$base/$name"` 形式。
- 使用 `set -e` 时需谨慎，确保不会误伤正常流程。

## 目录结构

- `command/`：可执行脚本。
- `command/lib/`：脚本依赖的库文件（`init.sh`、`slog.sh`、`tool.sh`、`git_tool.sh`、`load_config.sh`）。
- `source/`：安装后会被自动 source 的 `.sh` 文件。
- `tests/`：测试脚本（引用路径需保持正确）。

## 配置

- 配置文件位于 `~/.hall-command/env`，格式为 `key=value`。
- 示例配置见 `example.env`。
- 关键环境变量：
  - `HALL_COMMAND_GIT_DIR`：本地源码目录，默认 `~/.cache/hall-command/src`。
  - `HALL_GIT_REPO_PATH`：git 项目根目录，默认 `~/git-repo`。
  - `HALL_LOG_LEVEL`：日志级别，可选 DEBUG/INFO/SUCCESS/WARNING/ERROR。

## 测试

- 无统一测试框架，可手动运行 `tests/` 下的脚本验证。
- 修改后建议至少执行 `bash -n <script>` 检查语法。

## 提交规范

- 提交信息使用中文或英文，简要说明修改内容。
- 涉及多个文件时，按高/中/低优先级分阶段提交更清晰。
