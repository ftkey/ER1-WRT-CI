#!/bin/bash

PKG_PATH="$GITHUB_WORKSPACE/wrt/package/"
ls -an $PKG_PATH

#预置HomeProxy数据
if [ -d *"homeproxy"* ]; then
	HP_RULE="surge"
	HP_PATH="homeproxy/root/etc/homeproxy"
        if [ ! -d "$HP_PATH" ]; then
		HP_PATH="luci-app-homeproxy/root/etc/homeproxy"
   	fi

	git clone -q --depth=1 --single-branch --branch "release" "https://github.com/Loyalsoldier/surge-rules.git" ./$HP_RULE/
	cd ./$HP_RULE/ && RES_VER=$(git log -1 --pretty=format:'%s' | grep -o "[0-9]*")

	echo $RES_VER | tee china_ip4.ver china_ip6.ver china_list.ver gfw_list.ver
	awk -F, '/^IP-CIDR,/{print $2 > "china_ip4.txt"} /^IP-CIDR6,/{print $2 > "china_ip6.txt"}' cncidr.txt
	sed 's/^\.//g' direct.txt > china_list.txt ; sed 's/^\.//g' gfw.txt > gfw_list.txt
	mv -f ./{china_*,gfw_list}.{ver,txt} ../$HP_PATH/resources/

	cd .. && rm -rf ./$HP_RULE/

	cd $PKG_PATH && echo "homeproxy date has been updated!"
fi

#移除Shadowsocks组件
PW_FILE=$(find ./ -maxdepth 3 -type f -wholename "*/luci-app-passwall/Makefile")
if [ -f "$PW_FILE" ]; then
	sed -i '/config PACKAGE_$(PKG_NAME)_INCLUDE_Shadowsocks_Libev/,/x86_64/d' $PW_FILE
	sed -i '/config PACKAGE_$(PKG_NAME)_INCLUDE_ShadowsocksR/,/default n/d' $PW_FILE
	sed -i '/Shadowsocks_NONE/d; /Shadowsocks_Libev/d; /ShadowsocksR/d' $PW_FILE

	cd $PKG_PATH && echo "passwall has been fixed!"
fi

SP_FILE=$(find ./ -maxdepth 3 -type f -wholename "*/luci-app-ssr-plus/Makefile")
if [ -f "$SP_FILE" ]; then
	sed -i '/default PACKAGE_$(PKG_NAME)_INCLUDE_Shadowsocks_Libev/,/libev/d' $SP_FILE
	sed -i '/config PACKAGE_$(PKG_NAME)_INCLUDE_ShadowsocksR/,/x86_64/d' $SP_FILE
	sed -i '/Shadowsocks_NONE/d; /Shadowsocks_Libev/d; /ShadowsocksR/d' $SP_FILE

	cd $PKG_PATH && echo "ssr-plus has been fixed!"
fi

#修复TailScale配置文件冲突
TS_FILE=$(find ../feeds/packages/ -maxdepth 3 -type f -wholename "*/tailscale/Makefile")
if [ -f "$TS_FILE" ]; then
	sed -i '/\/files/d' $TS_FILE
	cd $PKG_PATH && echo "tailscale has been fixed!"
fi

#修复Socat配置文件冲突
SOCAT_FILE=$(find ../feeds/packages/ -maxdepth 3 -type f -wholename "*/socat/Makefile")
if [ -f "$SOCAT_FILE" ]; then
	sed -i '/\/files/d' $SOCAT_FILE
	cd $PKG_PATH && echo "socat has been fixed!"
fi

#修复 OpenVPN 和 Easy-RSA 配置文件冲突
OPENVPN_FILE=$(find ../feeds/packages/ -maxdepth 3 -type f -wholename "*/openvpn/Makefile")
if [ -f "$OPENVPN_FILE" ]; then
    sed -i '/INSTALL_CONF/{N;d;}' $OPENVPN_FILE
    cd $PKG_PATH && echo "OpenVPN conflict has been fixed!"
fi
EASY_RSA_FILE=$(find ../feeds/packages/ -maxdepth 3 -type f -wholename "*/openvpn-easy-rsa/Makefile")
if [ -f "$EASY_RSA_FILE" ]; then
    sed -i '/vars.example/d' $EASY_RSA_FILE
    cd $PKG_PATH && echo "Easy-RSA conflict has been fixed!"
fi

#修改argon主题颜色
ARGON_CSS_FILE=$(find ./ -type f -path "*/luci-theme-argon/htdocs/luci-static/argon/css/cascade.css")
if [ -f "$ARGON_CSS_FILE" ]; then
	sed -i "s/#483d8b/#31a1a1/" $ARGON_CSS_FILE
	cd $PKG_PATH && echo "Theme argon color has been fixed!"
fi
ARGON_BG_FILE=$(find ./ -type f -path "*/luci-theme-argon/htdocs/luci-static/argon/img/bg.webp")
if [ -f "$ARGON_BG_FILE" ]; then
	cp $GITHUB_WORKSPACE/Scripts/patches/bg.webp $ARGON_BG_FILE
	cd $PKG_PATH && echo "Theme argon bg has been fixed!"
fi

#修复ddns日志无法滚动问题
DDNS_OVERVIEW_FILE=$(find ./ ../feeds/luci/ -type f -path "*/luci-app-ddns/htdocs/luci-static/resources/view/ddns/overview.js")
if [ -f "$DDNS_OVERVIEW_FILE" ]; then
	sed -i "s/'textarea', { 'style': 'width:100%;/'textarea', { 'style': 'width:100%; overflow-y:auto;/" $DDNS_OVERVIEW_FILE
	cd $PKG_PATH && echo "DDNS log display has been fixed!"
fi


#修改qca-nss-drv启动顺序
NSS_DRV="../feeds/nss_packages/qca-nss-drv/files/qca-nss-drv.init"
if [ -f "$NSS_DRV" ]; then
	echo " "

	sed -i 's/START=.*/START=85/g' $NSS_DRV

	cd $PKG_PATH && echo "qca-nss-drv has been fixed!"
fi

#修改qca-nss-pbuf启动顺序
NSS_PBUF="./kernel/mac80211/files/qca-nss-pbuf.init"
if [ -f "$NSS_PBUF" ]; then
	echo " "

	sed -i 's/START=.*/START=86/g' $NSS_PBUF

	cd $PKG_PATH && echo "qca-nss-pbuf has been fixed!"
fi

#修复Rust编译失败
RUST_FILE=$(find ./ ../feeds/packages/ -maxdepth 3 -type f -wholename "*/rust/Makefile")
if [ -f "$RUST_FILE" ]; then
	echo " "

	sed -i 's/ci-llvm=true/ci-llvm=false/g' $RUST_FILE

	cd $PKG_PATH && echo "rust has been fixed!"
fi
