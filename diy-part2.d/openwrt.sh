#!/bin/bash
# OpenWrt DIY part2
# — 在 .config 加载之后、make 之前运行 —
# 以下是三种常用场景的示例，取消注释即可启用

# ===== 1. 文件注入（替换固件内置文件）=====
# 适用于：自定义 /etc/config/network、/etc/config/firewall、/etc/shadow 等
# 用法：将自定义文件放到 files/openwrt/ 目录下，运行时自动注入
# 下面示例：注入自定义 LAN IP（通过 DEFAULT_LAN_IP 环境变量）
cp "$GITHUB_WORKSPACE/files/openwrt/etc/config/network" openwrt/files/etc/config/network
sed -i "s/\${DEFAULT_LAN_IP}/${DEFAULT_LAN_IP}/g" openwrt/files/etc/config/network

# 如果还需要注入其他文件，取消注释：
# mkdir -p openwrt/files/etc/config
# cp "$GITHUB_WORKSPACE/files/openwrt/etc/config/firewall" openwrt/files/etc/config/firewall
# cp "$GITHUB_WORKSPACE/files/openwrt/etc/config/dropbear" openwrt/files/etc/config/dropbear

# ===== 2. 修改内核选项（.config 覆写）=====
# 适用于：追加或修改 OpenWrt 内核编译选项
# 示例：强制开启 BBR TCP 拥塞控制
# sed -i 's/.*CONFIG_PACKAGE_kmod-tcp-bbr=y/# CONFIG_PACKAGE_kmod-tcp-bbr is not set/' .config
# sed -i 's/.*CONFIG_PACKAGE_kmod-tcp-bbrx=y/# CONFIG_PACKAGE_kmod-tcp-bbrx is not set/' .config
# echo 'CONFIG_PACKAGE_kmod-nf-tcp-bbr=y' >> .config

# 示例：移除不需要的内核模块（减小体积）
# sed -i '/CONFIG_PACKAGE_kmod-usb-ohci/d' .config
# sed -i '/CONFIG_PACKAGE_kmod-usb-uhci/d' .config

# ===== 3. 修改或追加 package（.config 覆写）=====
# 适用于：增减预装软件包（在 .config 已经启用的基础上调整）
# 示例：添加额外软件包（必须先 ./scripts/feeds install xxx）
# echo 'CONFIG_PACKAGE_curl=y' >> .config
# echo 'CONFIG_PACKAGE_wget-ssl=y' >> .config
# echo 'CONFIG_PACKAGE_luci-app-accesscontrol=y' >> .config

# 示例：删除不需要的软件包
# sed -i '/CONFIG_PACKAGE_luci-app-wol/d' .config
# sed -i '/CONFIG_PACKAGE_ddns-scripts/d' .config

# ===== 4. 修改 UCI 默认配置值 ======
# 适用于：修改 OpenWrt UCI 数据库的默认值
# mkdir -p openwrt/files/etc/uci-defaults
# cat > openwrt/files/etc/uci-defaults/99-custom << 'UCIEOF'
# uci set network.lan.ipaddr='${DEFAULT_LAN_IP}'
# uci commit network
# UCIEOF
# sed -i "s/\${DEFAULT_LAN_IP}/${DEFAULT_LAN_IP}/g" openwrt/files/etc/uci-defaults/99-custom