#!/bin/bash
# ImmortalWrt DIY part2
# — 在 .config 加载之后、make 之前运行 —
# 以下是三种常用场景的示例，取消注释即可启用

# ===== 1. 文件注入（替换固件内置文件）=====
cp "$GITHUB_WORKSPACE/files/immortalwrt/etc/config/network" openwrt/files/etc/config/network
sed -i "s/\${DEFAULT_LAN_IP}/${DEFAULT_LAN_IP}/g" openwrt/files/etc/config/network

# 注入其他文件的用法：
# mkdir -p openwrt/files/etc/config
# cp "$GITHUB_WORKSPACE/files/immortalwrt/etc/config/firewall" openwrt/files/etc/config/firewall

# ===== 2. 修改内核选项（.config 覆写）=====
# 示例：开启更多网络优化
# echo 'CONFIG_PACKAGE_kmod-tcp-bbrx=y' >> .config

# 示例：关闭不需要的 wireless 驱动（省编译时间）
# sed -i '/CONFIG_PACKAGE_kmod-b43/d' .config

# ===== 3. 修改或追加 package（.config 覆写）=====
# 示例：在 ImmortalWrt 已有插件基础上追加
# echo 'CONFIG_PACKAGE_luci-app-xlnetacc=y' >> .config

# 示例：移除不需要的插件
# sed -i '/CONFIG_PACKAGE_luci-app-nlbwmon/d' .config

# ===== 4. 修改 UCI 默认配置值 ======
# mkdir -p openwrt/files/etc/uci-defaults
# cat > openwrt/files/etc/uci-defaults/99-custom << 'UCIEOF'
# uci set network.lan.ipaddr='${DEFAULT_LAN_IP}'
# uci commit network
# UCIEOF
# sed -i "s/\${DEFAULT_LAN_IP}/${DEFAULT_LAN_IP}/g" openwrt/files/etc/uci-defaults/99-custom