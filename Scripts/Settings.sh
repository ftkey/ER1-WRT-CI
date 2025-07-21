#!/bin/bash

#自定义所有设置
echo "当前网关IP: $WRT_IP"
# 支持 ** 查找子目录
shopt -s globstar

#修改默认主题
sed -i "s/luci-theme-bootstrap/luci-theme-$WRT_THEME/g" $(find ./feeds/luci/collections/ -type f -name "Makefile")
#修改immortalwrt.lan关联IP
sed -i "s/192\.168\.[0-9]*\.[0-9]*/$WRT_IP/g" $(find ./feeds/luci/modules/luci-mod-system/ -type f -name "flash.js")
#添加编译日期标识
sed -i "s/(\(luciversion || ''\))/(\1) + (' \/ $WRT_CI-$WRT_DATE')/g" $(find ./feeds/luci/modules/luci-mod-status/ -type f -name "10_system.js")

CFG_FILE="./package/base-files/files/bin/config_generate"
#修改默认IP地址
sed -i "s/192\.168\.[0-9]*\.[0-9]*/$WRT_IP/g" $CFG_FILE
#修改默认主机名
sed -i "s/hostname='.*'/hostname='$WRT_NAME'/g" $CFG_FILE
#临时修复luci无法保存的问题
sed -i "s/\[sid\]\.hasOwnProperty/\[sid\]\?\.hasOwnProperty/g" $(find ./feeds/luci/modules/luci-base/ -type f -name "uci.js")



#调整位置
# sed -i 's/services/system/g' $(find ./ -type f -path "*/luci-app-ttyd/root/usr/share/luci/menu.d/*" -name "luci-app-ttyd.json")
# sed -i '3 a\\t\t"order": 10,' $(find ./ -type f -path "*/luci-app-ttyd/root/usr/share/luci/menu.d/*" -name "luci-app-ttyd.json")
# sed -i 's/services/network/g' $(find ./ -type f -path "*/luci-app-alist/root/usr/share/luci/menu.d/*" -name "luci-app-upnp.json")
# sed -i 's/services/nas/g' $(find ./ -type f -path "*/luci-app-alist/root/usr/share/luci/menu.d/*" -name "luci-app-alist.json")
# sed -i 's/admin\/status/admin\/vpn/g' $(find ./ -type f -path "*/luci-proto-wireguard/root/usr/share/luci/menu.d/*" -name "luci-proto-wireguard.json")
# #移除advancedplus无用功能
# sed -i '/advancedplus\/advancedset/d' $(find ./ -type f -path "*/luci-app-advancedplus/luasrc/controller/*" -name "advancedplus.lua")
# sed -i '/advancedplus\/advancedipk/d' $(find ./ -type f -path "*/luci-app-advancedplus/luasrc/controller/*" -name "advancedplus.lua")

#调整位置
sed -i 's/services/system/g' $(find ./**/luci-app-ttyd/root/usr/share/luci/menu.d/ -type f -name "luci-app-ttyd.json")
sed -i '3 a\\t\t"order": 10,' $(find ./**/luci-app-ttyd/root/usr/share/luci/menu.d/ -type f -name "luci-app-ttyd.json")
sed -i 's/services/network/g' $(find ./**/luci-app-upnp/root/usr/share/luci/menu.d/ -type f -name "luci-app-upnp.json")
sed -i 's/services/nas/g' $(find ./**/luci-app-alist/root/usr/share/luci/menu.d/ -type f -name "luci-app-alist.json")
sed -i 's/services/nas/g' $(find ./**/luci-app-openlist/root/usr/share/luci/menu.d/ -type f -name "luci-app-openlist.json")
sed -i 's/services/nas/g' $(find ./**/luci-app-openlist/root/usr/share/luci/menu.d/ -type f -name "luci-app-openlist2.json")

sed -i 's/admin\/status/admin\/vpn/g' $(find ./**/luci-proto-wireguard/root/usr/share/luci/menu.d/ -type f -name "luci-proto-wireguard.json")

#移除advancedplus无用功能
sed -i '/advancedplus\/advancedset/d' $(find ./**/luci-app-advancedplus/luasrc/controller/ -type f -name "advancedplus.lua")
sed -i '/advancedplus\/advancedipk/d' $(find ./**/luci-app-advancedplus/luasrc/controller/ -type f -name "advancedplus.lua")
sed -i '/^start() {/,/^}$/ { /advancedset/s/^\(.*advancedset.*\)$/#\1/ }' $(find ./**/luci-app-advancedplus/root/etc/ -type f -name "advancedplus")
 
WRT_IPPART=$(echo $WRT_IP | cut -d'.' -f1-3)
# #修复Openvpnserver无法连接局域网和外网问题
# if [ -f "./package/network/config/firewall/files/firewall.user" ]; then
#     echo "iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o br-lan -j MASQUERADE" >> ./package/network/config/firewall/files/firewall.user
#     echo "OpenVPN Server has been fixed and is now accessible on the network!"
# fi
# if [ -f "./package/network/config/firewall/files/firewall.config" ]; then
# echo "config nat
#         option name 'openvpn'
#         list proto 'all'
#         option src '*'
#         option src_ip '10.8.0.0/24'
#         option target 'MASQUERADE'
#         option device 'br-lan'" >> ./package/network/config/firewall/files/firewall.config
# echo "OpenVPN Server has been fixed and is now accessible on the network!"
# fi

#修复Openvpnserver 修复ifname语法问题
OPENSERV_UCI_FILES=$(find ./**/luci-app-openvpn-server/root/etc/uci-defaults/ -type f -name "openvpn")
if [ -n "$OPENSERV_UCI_FILES" ]; then
    for file in $OPENSERV_UCI_FILES; do
        sed -i 's/network\.vpn0\.ifname/network\.vpn0\.device/g' $file
    	echo "OpenVPN Server has fixed the ifname syntax issue!"
    done
fi

#修复Openvpnserver默认配置的网关地址与无法多终端同时连接问题
OPENSERV_CONFIG_FILES=$(find ./**/luci-app-openvpn-server/root/etc/config/ -type f -name "openvpn")
if [ -n "$OPENSERV_CONFIG_FILES" ]; then
    for file in $OPENSERV_CONFIG_FILES; do
		echo "	option duplicate_cn '1'" >>  $file
		echo "OpenVPN Server has been fixed to resolve the issue of duplicate connecting!"
		sed -i "s/192.168.1.1/$WRT_IPPART.1/g"  $file
		sed -i "s/192.168.1.0/$WRT_IPPART.0/g"  $file
		echo "OpenVPN Server has been fixed the default gateway address!"
    done
fi


echo "CONFIG_PACKAGE_luci=y" >> ./.config
echo "CONFIG_LUCI_LANG_zh_Hans=y" >> ./.config
echo "CONFIG_PACKAGE_luci-theme-$WRT_THEME=y" >> ./.config
# echo "CONFIG_PACKAGE_luci-app-$WRT_THEME-config=y" >> ./.config

#手动调整的插件
if [ -n "$WRT_PACKAGE" ]; then
	echo "$WRT_PACKAGE" >> ./.config
fi

#高通平台调整
if [[ $WRT_TARGET == *"IPQ"* ]]; then
	#取消nss相关feed
	echo "CONFIG_FEED_nss_packages=n" >> ./.config
	echo "CONFIG_FEED_sqm_scripts_nss=n" >> ./.config
	#设置NSS版本
	echo "CONFIG_NSS_FIRMWARE_VERSION_11_4=n" >> ./.config
	echo "CONFIG_NSS_FIRMWARE_VERSION_12_5=y" >> ./.config
fi

#编译器优化
if [[ $WRT_TARGET == *"IPQ"* ]]; then
	echo "CONFIG_TARGET_OPTIONS=y" >> ./.config
	echo "CONFIG_TARGET_OPTIMIZATION=\"-O2 -pipe -march=armv8-a+crypto+crc -mcpu=cortex-a53+crypto+crc -mtune=cortex-a53\"" >> ./.config
fi

#IPK包管理调整
if [[ $WRT_USEAPK == 'true' ]]; then
	echo "CONFIG_USE_APK=y" >> ./.config
else
	echo "CONFIG_USE_APK=n" >> ./.config
	echo "CONFIG_PACKAGE_default-settings-chn=y" >> ./.config

	DEFAULT_CN_FILE=./package/emortal/default-settings/files/99-default-settings-chinese
	if [ -f "$DEFAULT_CN_FILE" ]; then
		sed -i.bak "/^exit 0/r $GITHUB_WORKSPACE/Scripts/patches/99-default-settings-chinese" $DEFAULT_CN_FILE
        sed -i '/^exit 0/d' $DEFAULT_CN_FILE && echo "exit 0" >> $DEFAULT_CN_FILE
		echo "99-default-settings-chinese has been added!"
	fi
fi
# LiBwrt 6.12不支持qmi
#if [[ $WRT_SOURCE == *"LiBwrt"* ]]; then
#    echo "CONFIG_PACKAGE_kmod-usb-net-qmi-wwan=n" >> ./.config
#    echo "CONFIG_PACKAGE_kmod-usb-net-qmi-wwan-fibocom=n" >> ./.config
#    echo "CONFIG_PACKAGE_kmod-usb-net-qmi-wwan-quectel=n" >> ./.config
#	echo "LiBwrt CONFIG_PACKAGE_kmod-usb-net-qmi-wwan=n!"
#fi
