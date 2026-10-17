# hall-command

> **已弃用并归档。** 这里的命令已用 Go 重写并迁移到
> [hall-kit](https://github.com/QuietSugar/hall-kit)；本仓库只读，不再更新。

## 新的安装方式

```bash
go install github.com/QuietSugar/hall-kit/cmd/hall@latest
hall shell install
```

## 迁移对照

| hall-command | hall-kit |
| --- | --- |
| `command/gitcheck.sh` | `cmd/gitcheck`（Go） |
| `command/gitclone.sh` | `cmd/gitclone`（Go） |
| `command/gitarc.sh` | `cmd/gitarc`（Go） |
| `command/rm_empty_dir.sh` | `cmd/rmempty`（Go） |
| `command/tat.sh` | `shell/bin/tat.sh`（由 `hall shell install` 装成 `tat`） |
| `command/lib/{slog,init,load_config}.sh` | `shell/lib/*.sh` |
| `source/proxy.sh` | `shell/source/hall-proxy.sh`（合并） |
| `source/docker.profile.sh` | `shell/source/hall-docker.sh` |
| `source/http_proxy_set.sh` | 合并进 `hall-proxy.sh` |
| `command/hversion.sh` | 改用 `hall --version` |
| `command/check.sh` | 未迁移，已删除 |

## 旧版本

- 最后一个包含完整 shell 实现的版本是 **v1.0.9**：
  <https://github.com/QuietSugar/hall-command/releases/tag/v1.0.9>
- 老的远程安装命令仍然可用（`install.sh` 会下载 v1.0.9 的 release）：

  ```bash
  curl -fsSL https://raw.githubusercontent.com/QuietSugar/hall-command/refs/heads/master/install.sh | bash
  ```

- 不要在本仓库执行 `make release`：HEAD 已不再包含命令，新 tag 会是空壳。
- 本仓库不接受 issue / PR。

## 环境变量

配置已迁移到 hall-kit 的 `~/.hall/env`；迁移期仍会回退读取旧的 `~/.hall-command/env`。
