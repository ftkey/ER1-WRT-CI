#!/bin/bash

#删除软件包(全名)
DELETE_PACKAGE() {
	local PKG_NAME=$1
	rm -rf $(find ./ ../feeds/luci/ ../feeds/packages/ -maxdepth 3 -type d -iname "$PKG_NAME" -prune)
}
#DELETE_PACKAGE "socat"
#DELETE_PACKAGE "openvpn-openssl"
#DELETE_PACKAGE "openvpn-easy-rsa"
#rm -rf ../feeds/packages/net/socat

#安装和更新软件包(包含通配符)
UPDATE_PACKAGE() {
	local PKG_NAME=$1
	local PKG_REPO=$2
	local PKG_BRANCH=$3
	local PKG_SPECIAL=$4
	local REPO_NAME=$(echo $PKG_REPO | cut -d '/' -f 2)

	rm -rf $(find ./ ../feeds/luci/ ../feeds/packages/ -maxdepth 3 -type d -iname "*$PKG_NAME*" -prune)

	git clone --depth=1 --single-branch --branch $PKG_BRANCH "https://github.com/$PKG_REPO.git"

	if [[ $PKG_SPECIAL == "pkg" ]]; then
		cp -rf $(find ./$REPO_NAME/*/ -maxdepth 3 -type d -iname "*$PKG_NAME*" -prune) ./
		rm -rf ./$REPO_NAME/
	elif [[ $PKG_SPECIAL == "name" ]]; then
		mv -f $REPO_NAME $PKG_NAME
	fi
}

#UPDATE_PACKAGE "包名" "项目地址" "项目分支" "pkg/name，可选，pkg为从大杂烩中单独提取包名插件；name为重命名为包名"
UPDATE_PACKAGE "argon" "ftkey/openwrt_pkgs" "main" "pkg"
UPDATE_PACKAGE "homeproxy" "ftkey/openwrt_pkgs" "main" "pkg"
UPDATE_PACKAGE "nikki" "ftkey/openwrt_pkgs" "main" "pkg"
UPDATE_PACKAGE "passwall" "ftkey/openwrt_pkgs" "main" "pkg"
UPDATE_PACKAGE "vlmcsd" "ftkey/openwrt_pkgs" "main" "pkg"
UPDATE_PACKAGE "luci-app-advancedplus" "ftkey/openwrt_pkgs" "main" "pkg"
UPDATE_PACKAGE "luci-app-wolplus" "ftkey/openwrt_pkgs" "main" "pkg"
UPDATE_PACKAGE "luci-app-onliner" "ftkey/openwrt_pkgs" "main" "pkg"
UPDATE_PACKAGE "ddns-scripts-aliyun" "ftkey/openwrt_pkgs" "main" "pkg"
UPDATE_PACKAGE "luci-app-socat" "ftkey/openwrt_pkgs" "main" "pkg"
UPDATE_PACKAGE "openlist2" "ftkey/openwrt_pkgs" "main" "pkg"






#if [[ $WRT_REPO != *"immortalwrt"* ]]; then
#	UPDATE_PACKAGE "qmi-wwan" "immortalwrt/wwan-packages" "master" "pkg"
#fi

#更新软件包版本
UPDATE_VERSION() {
	local PKG_NAME=$1
	local PKG_MARK=${2:-not}
	local PKG_FILES=$(find ./ ../feeds/packages/ -maxdepth 3 -type f -wholename "*/$PKG_NAME/Makefile")

	echo " "

	if [ -z "$PKG_FILES" ]; then
		echo "$PKG_NAME not found!"
		return
	fi

	echo "$PKG_NAME version update has started!"

	for PKG_FILE in $PKG_FILES; do
		local PKG_REPO=$(grep -Pho 'PKG_SOURCE_URL:=https://.*github.com/\K[^/]+/[^/]+(?=.*)' $PKG_FILE | head -n 1)
		local PKG_VER=$(curl -sL "https://api.github.com/repos/$PKG_REPO/releases" | jq -r "map(select(.prerelease|$PKG_MARK)) | first | .tag_name")
		local NEW_VER=$(echo $PKG_VER | sed "s/.*v//g; s/_/./g")
		local NEW_HASH=$(curl -sL "https://codeload.github.com/$PKG_REPO/tar.gz/$PKG_VER" | sha256sum | cut -b -64)
		local OLD_VER=$(grep -Po "PKG_VERSION:=\K.*" "$PKG_FILE")

		echo "$OLD_VER $PKG_VER $NEW_VER $NEW_HASH"

		if [[ $NEW_VER =~ ^[0-9].* ]] && dpkg --compare-versions "$OLD_VER" lt "$NEW_VER"; then
			sed -i "s/PKG_VERSION:=.*/PKG_VERSION:=$NEW_VER/g" "$PKG_FILE"
			sed -i "s/PKG_HASH:=.*/PKG_HASH:=$NEW_HASH/g" "$PKG_FILE"
			echo "$PKG_FILE $NEW_VER version has been updated!"
		else
			echo "$PKG_FILE $NEW_VER version is already the latest!"
		fi
	done
}

#UPDATE_VERSION "软件包名" "测试版，true，可选，默认为否"
UPDATE_VERSION "sing-box"
UPDATE_VERSION "alist"
UPDATE_VERSION "zerotier"
#修复Openvpnserver一键生成证书
#UPDATE_VERSION "openvpn-easy-rsa" 
#UPDATE_VERSION "tailscale"

