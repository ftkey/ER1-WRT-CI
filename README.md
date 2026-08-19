# OpenWRT-CI Custom

![Sync & Build](https://github.com/ftkey/ER1-WRT-CI/actions/workflows/sync-build.yml/badge.svg)
![Release](https://img.shields.io/github/v/release/ftkey/ER1-WRT-CI?label=最新固件)
![Release Date](https://img.shields.io/github/release-date/ftkey/ER1-WRT-CI?label=发布日期)

基于 [VIKINGYFY/OpenWRT-CI](https://github.com/VIKINGYFY/OpenWRT-CI) 的自定义云编译固件仓库。编译前自动同步上游更新，通过补丁脚本和配置文件修改，自动化打包编译 OpenWRT/ImmortalWrt 固件，全流程无需手动干预。

## 自动化流程

```
06:00  Sync & Build  →  同步工作流 (唯一自动任务)
  ├─ backup   备份 main 上的自定义文件
  ├─ check    检测上游 48h 内是否有更新
  └─ branch   有更新时从上游 main 重置 build-latest 固定分支并推送 (自带全量上游 + 自定义文件)
06:05  Build Firmware →  编译工作流 (push 到 build-latest 分支自动触发)
  ├─ build    调用 WRT-CORE 编译固件，Release 挂载到 build-<WRT_DATE> 时间戳 tag
  └─ archive  保留 build-latest 分支 (缓存复用)，main 始终不参与
```

> 为什么用固定 `build-latest` 分支而非时间戳分支？GitHub Actions 缓存按分支隔离，固定分支名才能命中上次缓存，大幅提速；时间戳分支每次全新，缓存永远 miss，导致全量编译。每次构建 = 一个 self-contained 分支 `build-latest`（全量上游 + 自定义补丁），push 触发编译时 `WRT-CORE.yml` 在该分支最新提交上解析，编译必需文件永远齐全。`main` 仅保留自定义文件，不被上游污染，也无需 Cleanup 反复清文件。构建留痕由 Release tag（`build-<WRT_DATE>` 时间戳）承担。

编译流程 (WRT-CORE): 检出项目 → 初始化环境 → 克隆源码 → 更新 Feeds → 自定义插件包 (`Packages.sh` → `PRIVATE.sh`) → 自定义设置 (`Settings.sh` → `PRIVATE.txt`) → 下载 & 编译 → 打包发布 Release。

## 目录结构

```
.github/workflows/
  sync-build.yml      # ★ 同步工作流: 同步上游 + 重置 build-latest 分支触发编译 (自定义)
  build-firmware.yml  # ★ 编译工作流: 调用 WRT-CORE 编译 + 保留 build-latest 分支 (自定义)
  WRT-CORE.yml        # 编译核心流程 (上游，仅在 build-latest 分支上，编译前自动打补丁: seed.config + Release tag)
  OWRT/MTK/QCA-ALL.yml、Auto-Clean.yml、Cache-Clean.yml  # 上游，自动触发已禁用
Scripts/
  Packages.sh / Settings.sh / Handles.sh   # 上游脚本 (只在 build-latest 分支)
  PRIVATE.sh          # ★ 自定义补丁脚本
Config/
  *.txt               # 各平台编译配置 (上游，只在 build-latest 分支)
  PRIVATE.txt         # ★ 自定义配置项
```

> ★ 为自定义文件，仅存在于 `main`（及每次拷贝到 `build-latest` 分支），同步时不会被覆盖。标注 (上游) 的文件随每次构建从上游拉到 `build-latest` 分支，编译完成后该分支保留以复用缓存，`main` 始终保持极简。

## 自定义方式

### 1. GitHub 仓库变量 - 固件参数

在 **Settings → Secrets and variables → Actions → Variables** 添加变量，未设置则用默认值：

| 变量名 | 说明 | 默认值 |
|--------|------|--------|
| `WRT_THEME` | 默认主题 | `aurora` |
| `WRT_NAME` | 主机名 | `OWRT` |
| `WRT_SSID` | WiFi 名称 | `OWRT` |
| `WRT_WORD` | WiFi 密码 | `12345678` |
| `WRT_IP` | 管理地址 | `192.168.10.1` |
| `WRT_PW` | 密码提示 (仅展示) | `无` |

### 2. Scripts/PRIVATE.sh - 补丁脚本

编译配置被读取前执行，可修改配置文件、安装自定义软件包。

### 3. Config/PRIVATE.txt - 配置项

编译时自动追加到 `.config`，用于添加上游配置中没有的选项，`make defconfig` 自动处理依赖。

## 快速开始

1. 将仓库文件推送到你的 GitHub 仓库
2. (可选) 添加固件参数变量
3. 等待每天 06:00 自动编译 (自动同步 + 编译 + 发布)
4. 在 **Releases** 页面下载固件

## 编译平台

默认只编译 IPQ60XX (无 WiFi)，可在 `build-firmware.yml` 的 `matrix.include` 修改：

| 配置名 | 平台 | 源码分支 |
|--------|------|----------|
| IPQ60XX-WIFI-NO | IPQ60XX (无 WiFi) | main |

### 支持设备

`PRIVATE.sh` 默认启用的设备（在 `Scripts/PRIVATE.sh` 中修改）：

| 设备代号 | 设备名称 |
|----------|----------|
| `jdcloud_re-ss-01` | 京东云无线宝 亚瑟 AX1800 Pro (IPQ6000) |
| `jdcloud_re-cs-07` | 京东云无线宝 太乙 ER1 |

## 编译产物

编译成功后发布到 **Releases**，每个 Release 包含：

| 文件 | 说明 |
|------|------|
| `Config-*.txt` | 完整编译配置 (`.config` 副本) |
| `Seed-*.txt` | 精简配置 (`diffconfig` 输出，可复现编译) |
| `*.bin` / `*.tar.gz` | 固件镜像，按设备区分 |

Release 标签: `build-<WRT_DATE>`（编译时刻时间戳），如 `build-26.08.24-06.30.00`。每次编译产生唯一 tag，即 Release 载体。

## 常见问题

**同步后自定义文件会丢失吗？** 不会。`PRIVATE.sh`、`PRIVATE.txt`、`sync-build.yml`、`build-firmware.yml`、`README.md` 仅存在于 `main` 且同步时受保护，每次重置 `build-latest` 分支时再拷贝进去，永不丢失。

**为什么上游触发器不自动运行了？** 生成 `build-latest` 分支时自动移除上游工作流的自动触发器（`workflow_run` / `schedule`），仅保留手动触发，自动编译完全由 `Sync & Build` + `Build Firmware` 接管。

**编译完成后上游文件会被删除吗？** 不会删除分支。Build Firmware 编译成功后，Release 已挂载到 `build-<WRT_DATE>` 时间戳 tag（由 WRT-CORE 创建），随后 archive 步骤保留 `build-latest` 分支以复用 GitHub Actions 缓存（缓存按分支隔离，删分支即丢缓存）。上游文件（`Scripts/Packages.sh`、`Handles.sh`、`Settings.sh`、`Config/*.txt`）常驻该分支，`main` 始终保持极简、不被上游污染。下次编译时由 `Sync & Build` 重新从上游重置该分支，周而复始。

**编译失败？** 检查 Actions 日志 → 勾选 `TEST` 仅生成配置检查 `.config` → 运行 `Cache-Clean` 清缓存 → 重新触发 `Sync & Build` 手动重新同步。

## 致谢

- [VIKINGYFY/OpenWRT-CI](https://github.com/VIKINGYFY/OpenWRT-CI) - 上游云编译项目
- [immortalwrt/immortalwrt](https://github.com/immortalwrt/immortalwrt) - OpenWrt 源码

## License

MIT
