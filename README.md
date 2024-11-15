# ER1-WRT-CI
京东云ER1 (设备型号: qualcommax_ipq60xx_DEVICE_jdcloud_re-cs-07)

## 云编译OpenWRT固件

### 高通版

OWRT: https://github.com/VIKINGYFY/immortalwrt.git 

LibWRT: https://github.com/LiBwrt-op/openwrt-6.x.git 

LEDE: https://github.com/coolsnowwolf/lede.git 

## 编译时间
固件自动每天早上4点自动编译

## 固件信息

默认管理地址：192.168.1.1 默认用户：root 默认密码：password

OWR&LibWRT: 带NSS的6.6内核固件，默认主题为Argon；默认使用nftables防火墙（fw4）。

LEDE: 带NSS的6.1内核固件，默认主题为Argon；默认使用fw3防火墙iptables。

额外的软件包

## 刷机方法:
### LEDE:
    Hugo Uboot + 原厂CDT + 双分区GPT
    Uboot 刷入squashfs-recovery.bin
    Luci 刷入squashfs-sysupgrade.bin

### LibWRT&OWRT:
    Hugo Uboot + 原厂CDT + 单/双分区GPT
    Uboot 刷入squashfs-factory.bin
    Luci 刷入squashfs-sysupgrade.bin

## THKS
VIKINGYFY | LiBwrt-op | Lede


