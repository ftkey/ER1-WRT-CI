#!/bin/bash

#修改默认主题
sed -i "s/luci-theme-bootstrap/luci-theme-$WRT_THEME/g" $(find ./feeds/luci/collections/ -type f -name "Makefile")
#修改immortalwrt.lan关联IP
sed -i "s/192\.168\.[0-9]*\.[0-9]*/$WRT_IP/g" $(find ./feeds/luci/modules/luci-mod-system/ -type f -name "flash.js")
#添加编译日期标识
sed -i "s/(\(luciversion || ''\))/(\1) + (' \/ $WRT_CI-$WRT_DATE')/g" $(find ./feeds/luci/modules/luci-mod-status/ -type f -name "10_system.js")
#修改默认WIFI名
sed -i "s/\.ssid=.*/\.ssid=$WRT_WIFI/g" $(find ./package/kernel/mac80211/ ./package/network/config/ -type f -name "mac80211.*")
#调整位置
sed -i 's/services/system/g' $(find ./feeds/luci/applications/luci-app-ttyd/ -type f -name "luci-app-ttyd.json")
sed -i '3 a\\t\t"order": 10,' $(find ./feeds/luci/applications/luci-app-ttyd/ -type f -name "luci-app-ttyd.json")
sed -i 's/services/nas/g' $(find ./feeds/luci/applications/luci-app-alist/ -type f -name "luci-app-alist.json")
sed -i 's/services/nas/g' $(find ./feeds/luci/applications/luci-app-samba4/ -type f -name "luci-app-samba4.json")
sed -i 's/services/network/g' $(find ./feeds/luci/applications/luci-app-upnp/ -type f -name "luci-app-upnp.json")

#修改默认IP地址
sed -i "s/192\.168\.[0-9]*\.[0-9]*/$WRT_IP/g" ./package/base-files/files/bin/config_generate
sed -i "s/192\.168\.[0-9]*\.[0-9]*/$WRT_IP/g" ./package/base-files/luci2/bin/config_generate
#修改默认主机名
sed -i "s/hostname='\(.*\)'/hostname='$WRT_NAME'/g" ./package/base-files/files/bin/config_generate
sed -i "s/hostname='\(.*\)'/hostname='$WRT_NAME'/g" ./package/base-files/luci2/bin/config_generate


#配置文件修改
echo "CONFIG_PACKAGE_luci=y" >> ./.config
echo "CONFIG_LUCI_LANG_zh_Hans=y" >> ./.config
echo "CONFIG_PACKAGE_luci-theme-$WRT_THEME=y" >> ./.config
echo "CONFIG_PACKAGE_luci-app-$WRT_THEME-config=y" >> ./.config

#手动调整的插件
if [ -n "$WRT_PACKAGE" ]; then
	echo "$WRT_PACKAGE" >> ./.config
fi

#高通平台调整
if [[ $WRT_TARGET == *"OWRT"* || $WRT_TARGET == *"LIBWRT"* || $WRT_TARGET == *"IMMWRT"*]]; then
	#取消nss相关feed
	echo "CONFIG_FEED_nss_packages=n" >> ./.config
	echo "CONFIG_FEED_sqm_scripts_nss=n" >> ./.config
fi
if [[ $WRT_TARGET == *"LEDE"*]]; then
	#取消自带科学相关feed
	echo "CONFIG_FEED_helloworld=n" >> ./.config
fi