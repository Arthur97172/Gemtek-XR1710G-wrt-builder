#!/bin/bash
# iStoreOS DIY part2
# — 在 .config 加载之后、make 之前运行 —

# ===== 追加第三方插件包（不影响 .config 主文件）=====
PKG_CONF="$GITHUB_WORKSPACE/packages/istoreos.conf"
[ -f "$PKG_CONF" ] && grep -v '^#' "$PKG_CONF" | grep -v '^$' >> .config && echo "已加载第三方插件: istoreos" || true

# ===== 修改内核选项示例（取消注释即可启用）=====
# sed -i '/CONFIG_PACKAGE_kmod-usb-ohci/d' .config
sed -i '/CONFIG_PACKAGE_mihomo-alpha/d' .config

# ===== UCI 默认值示例 ======
# mkdir -p openwrt/files/etc/uci-defaults
# cat > openwrt/files/etc/uci-defaults/99-custom << 'UCIEOF'
# uci set system.@system[0].timezone='CST-8'
# uci commit system
# UCIEOF
