#!/bin/bash
# SPDX-License-Identifier: MIT
# 自定义私有扩展脚本
#
# 此脚本由上游 Packages.sh 末尾自动 source 引入
# 运行目录: ./wrt/package/
# 可用变量: $GITHUB_WORKSPACE (仓库根目录), $WRT_CONFIG (当前编译配置名) 等
# 可用函数: UPDATE_PACKAGE (安装自定义软件包), UPDATE_VERSION (更新软件包版本)
#
# ============================================================
# 一、配置文件补丁 (sed 修改)
# ============================================================
# 在编译配置文件被读取之前 (Custom Settings 步骤之前) 修改它们
# 用于启用/禁用特定设备、修改默认配置等
# 注意: 此脚本在 Custom Packages 步骤执行，早于 Custom Settings 步骤
#       所以对 Config/*.txt 的修改会被后续步骤正确读取

# 对当前编译配置文件应用设备启用补丁
CFG="$GITHUB_WORKSPACE/Config/$WRT_CONFIG.txt"
if [ -f "$CFG" ]; then
    # ---- 第一步: 禁用所有设备 (默认全部关闭) ----
    sed -i '/CONFIG_TARGET_DEVICE_qualcommax_ipq60xx_DEVICE_.*=y/s/=y/=n/' "$CFG"
    sed -i '/CONFIG_TARGET_DEVICE_qualcommax_ipq807x_DEVICE_.*=y/s/=y/=n/' "$CFG"
    sed -i '/CONFIG_TARGET_DEVICE_mediatek_.*_DEVICE_.*=y/s/=y/=n/' "$CFG"

    # ---- 第二步: 选择性启用需要的设备 ----
    sed -i 's/jdcloud_re-ss-01=n/jdcloud_re-ss-01=y/' "$CFG"
    sed -i 's/jdcloud_re-cs-07=n/jdcloud_re-cs-07=y/' "$CFG"
fi

echo "==> 自定义配置补丁已应用!"

# ============================================================
# 二、自定义软件包安装
# ============================================================
# 使用上游的 UPDATE_PACKAGE 函数安装额外软件包
# 格式: UPDATE_PACKAGE "包名" "GitHub仓库(user/repo)" "分支" "pkg/name(可选)"
#   pkg: 从大杂烩仓库中单独提取指定包名的插件
#   name: 将克隆的仓库重命名为指定包名

# 从 ftkey/openwrt_pkgs 引入上游 feeds 中没有的插件 (pkg 模式提取单包)
UPDATE_PACKAGE "luci-app-advancedplus" "ftkey/openwrt_pkgs" "main" "pkg"
UPDATE_PACKAGE "luci-app-onliner" "ftkey/openwrt_pkgs" "main" "pkg"
UPDATE_PACKAGE "luci-app-socat" "ftkey/openwrt_pkgs" "main" "pkg"

# 替换上游 Argon 主题为自维护版本 (上游 sbwml/luci-theme-argon 有 bug)
UPDATE_PACKAGE "luci-theme-argon" "ftkey/openwrt_pkgs" "main" "pkg"

echo "==> 自定义软件包检查完成!"

# ============================================================
# 三、其他自定义修改
# ============================================================
# 可以在这里添加任何其他自定义修改命令
# 例如: 修改源码文件、添加自定义脚本等

# ---- 菜单位置调整 (从 ftkey/ER1-WRT-CI 引入) ----
# 当前运行目录: ./wrt/package/
# 搜索范围: ./wrt/package/ 和 ./wrt/feeds/

# ttyd: admin/services → admin/system
TTYD=$(find ./ ../feeds/ -path "*/luci-app-ttyd/root/usr/share/luci/menu.d/luci-app-ttyd.json" -print -quit 2>/dev/null)
if [ -n "$TTYD" ]; then
    sed -i 's|admin/services/|admin/system/|g' "$TTYD" && echo "menu: ttyd → system"
fi
# upnp: admin/services → admin/network
UPNP=$(find ./ ../feeds/ -path "*/luci-app-upnp/root/usr/share/luci/menu.d/luci-app-upnp.json" -print -quit 2>/dev/null)
if [ -n "$UPNP" ]; then
    sed -i 's|admin/services/|admin/network/|g' "$UPNP" && echo "menu: upnp → network"
fi
# alist: admin/services → admin/nas
ALIST=$(find ./ ../feeds/ -path "*/luci-app-alist/root/usr/share/luci/menu.d/luci-app-alist.json" -print -quit 2>/dev/null)
if [ -n "$ALIST" ]; then
    sed -i 's|admin/services/|admin/nas/|g' "$ALIST" && echo "menu: alist → nas"
fi
# openlist: admin/services → admin/nas
OPENLIST=$(find ./ ../feeds/ -path "*/luci-app-openlist/root/usr/share/luci/menu.d/luci-app-openlist.json" -print -quit 2>/dev/null)
if [ -n "$OPENLIST" ]; then
    sed -i 's|admin/services/|admin/nas/|g' "$OPENLIST" && echo "menu: openlist → nas"
fi
# openlist2: admin/services → admin/nas
OPENLIST2=$(find ./ ../feeds/ -path "*/luci-app-openlist2/root/usr/share/luci/menu.d/luci-app-openlist2.json" -print -quit 2>/dev/null)
if [ -n "$OPENLIST2" ]; then
    sed -i 's|admin/services/|admin/nas/|g' "$OPENLIST2" && echo "menu: openlist2 → nas"
fi
# zerotier: admin/services → admin/vpn
ZT=$(find ./ ../feeds/ -path "*/luci-app-zerotier/root/usr/share/luci/menu.d/luci-app-zerotier.json" -print -quit 2>/dev/null)
if [ -n "$ZT" ]; then
    sed -i 's|admin/services/|admin/vpn/|g' "$ZT" && echo "menu: zerotier → vpn"
fi
# tailscale: admin/services → admin/vpn
TS=$(find ./ ../feeds/ -path "*/luci-app-tailscale/root/usr/share/luci/menu.d/luci-app-tailscale.json" -print -quit 2>/dev/null)
if [ -n "$TS" ]; then
    sed -i 's|admin/services/|admin/vpn/|g' "$TS" && echo "menu: tailscale → vpn"
fi
# samba4: admin/services → admin/nas
SAMBA=$(find ./ ../feeds/ -path "*/luci-app-samba4/root/usr/share/luci/menu.d/luci-app-samba4.json" -print -quit 2>/dev/null)
if [ -n "$SAMBA" ]; then
    sed -i 's|admin/services/|admin/nas/|g' "$SAMBA" && echo "menu: samba4 → nas"
fi
# wolultra: admin/control → admin/services
WOL=$(find ./ ../feeds/ -path "*/luci-app-wolultra/root/usr/share/luci/menu.d/luci-app-wolultra.json" -print -quit 2>/dev/null)
if [ -n "$WOL" ]; then
    sed -i 's|admin/control|admin/services|g' "$WOL" && echo "menu: wolultra → services"
fi

# ---- DDNS 日志滚动修复 (从 ftkey/ER1-WRT-CI 引入) ----
# 修复 DDNS 日志框无法滚动的问题
DDNS=$(find ./ ../feeds/luci/ -path "*/luci-app-ddns/htdocs/luci-static/resources/view/ddns/overview.js" -print -quit 2>/dev/null)
if [ -n "$DDNS" ]; then
    sed -i "s/'textarea', { 'style': 'width:100%;/'textarea', { 'style': 'width:100%; overflow-y:auto;/" "$DDNS" && echo "fix: DDNS log scroll"
fi

# 示例 (取消注释即可使用):
# 修改默认 Shell 为 bash
# sed -i 's/\/bin\/ash/\/bin\/bash/' "$GITHUB_WORKSPACE/wrt/package/base-files/files/etc/passwd"

# 修改默认时区
# sed -i 's/UTC/CST-8/' "$GITHUB_WORKSPACE/wrt/package/base-files/files/etc/config/system"

echo "==> 私有扩展脚本执行完毕!"
