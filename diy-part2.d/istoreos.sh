#!/bin/bash
# iStoreOS DIY part2
# — 在 .config 加载之后、make 之前运行 —
# 以下是三种常用场景的示例，取消注释即可启用

# ===== 1. 文件注入（替换固件内置文件）=====
cp "$GITHUB_WORKSPACE/files/istoreos/etc/config/network" openwrt/files/etc/config/network
sed -i "s/\${DEFAULT_LAN_IP}/${DEFAULT_LAN_IP}/g" openwrt/files/etc/config/network

# 注入其他文件的用法：
# mkdir -p openwrt/files/etc/config
# cp "$GITHUB_WORKSPACE/files/istoreos/etc/config/firewall" openwrt/files/etc/config/firewall

# ===== 2. 修改内核选项（.config 覆写）=====
# 示例：强制开启 BBR
# sed -i 's/.*CONFIG_PACKAGE_kmod-tcp-bbr=y/# CONFIG_PACKAGE_kmod-tcp-bbr is not set/' .config
# echo 'CONFIG_PACKAGE_kmod-nf-tcp-bbr=y' >> .config

# 示例：移除不需要的 USB 模块（省空间）
# sed -i '/CONFIG_PACKAGE_kmod-usb-ohci/d' .config

# ===== 3. 修改或追加 package（.config 覆写）=====
# 示例：添加额外包（需先确认 feeds install）
# echo 'CONFIG_PACKAGE_curl=y' >> .config
# echo 'CONFIG_PACKAGE_luci-app-samba4=y' >> .config

# 示例：移除 iStore 预置但你不需要的应用
# sed -i '/CONFIG_PACKAGE_istoreos-intl/d' .config

# ===== 4. 修改 UCI 默认配置值 ======
# mkdir -p openwrt/files/etc/uci-defaults
# cat > openwrt/files/etc/uci-defaults/99-custom << 'UCIEOF'
# uci set network.lan.ipaddr='${DEFAULT_LAN_IP}'
# uci commit network
# UCIEOF
# sed -i "s/\${DEFAULT_LAN_IP}/${DEFAULT_LAN_IP}/g" openwrt/files/etc/uci-defaults/99-custom