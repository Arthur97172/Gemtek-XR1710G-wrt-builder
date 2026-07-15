#!/bin/bash
# iStoreOS DIY part2
# — 在 .config 加载之后、make 之前运行 —

# ===== 1. LAN IP 文件注入 =====
mkdir -p openwrt/files/etc/config
cp "$GITHUB_WORKSPACE/files/istoreos/etc/config/network" openwrt/files/etc/config/network
sed -i "s/\${DEFAULT_LAN_IP}/${DEFAULT_LAN_IP}/g" openwrt/files/etc/config/network

# ===== 2. 追加第三方插件包（不影响 .config 主文件）=====
PKG_CONF="$GITHUB_WORKSPACE/packages/istoreos.conf"
[ -f "$PKG_CONF" ] && grep -v '^#' "$PKG_CONF" | grep -v '^$' >> .config && echo "已加载第三方插件: istoreos" || true

# ===== 3. 修改内核选项示例（取消注释即可启用）=====
# sed -i '/CONFIG_PACKAGE_kmod-usb-ohci/d' .config

# ===== 4. UCI 默认值示例 =====
# mkdir -p openwrt/files/etc/uci-defaults
# cat > openwrt/files/etc/uci-defaults/99-custom << 'UCIEOF'
# uci set network.lan.ipaddr='${DEFAULT_LAN_IP}'
# uci commit network
# UCIEOF
# sed -i "s/\${DEFAULT_LAN_IP}/${DEFAULT_LAN_IP}/g" openwrt/files/etc/uci-defaults/99-custom