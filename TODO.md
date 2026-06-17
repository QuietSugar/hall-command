# 待处理事项

## `tat.sh` 已移除

`command/tat.sh` 依赖 `tmux`，而 tmux 在 macOS、Windows、多数 Linux 上都不是默认安装的。由于当前用户暂时不使用 tmux，已将 `tat.sh` 从仓库中删除。

如果未来需要恢复 tmux 会话管理功能，可以从 git 历史中提取 `command/tat.sh`，或重新实现一个基于 `screen`/`tmux` 的可选插件。

### 原始 `tat.sh` 内容

```sh
#!/bin/sh

# ====================================================
#   @version:		1.0.1
# ====================================================

#
# Attach or create tmux session named the same as current directory.

path_name="$(basename "$PWD" | tr . -)"
session_name=${1-$path_name}

not_in_tmux() {
  [ -z "$TMUX" ]
}

session_exists() {
  tmux has-session -t "=$session_name"
}

create_detached_session() {
  (TMUX='' tmux new-session -Ad -s "$session_name")
}

create_if_needed_and_attach() {
  if not_in_tmux; then
    tmux new-session -As "$session_name"
  else
    if ! session_exists; then
      create_detached_session
    fi
    tmux switch-client -t "$session_name"
  fi
}

create_if_needed_and_attach
```
