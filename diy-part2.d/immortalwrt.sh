#!/bin/bash
# Immortalwrt DIY part2
# — 在 .config 加载之后、make 之前运行 —

# 1. 强行修复 luci-app-clientstatus 源码作者引发的循环依赖死锁
find feeds/ package/ -type f -name "Makefile" 2>/dev/null | grep "luci-app-clientstatus" | xargs sed -i 's/DEPENDS:=luci-app-clientstatus/DEPENDS:=+luci-app-clientstatus/g' || true

# 2. 移除缺失依赖且一般用不上的 sdl3 源码，防止后续报错
rm -rf package/feeds/video/sdl3

# 3. 终极修复：替换 libffi 源码，避开 aarch64 路径匹配 Bug
rm -rf feeds/packages/libs/libffi
git clone https://github.com/openwrt/packages.git tmp/openwrt-packages --depth=1
cp -r tmp/openwrt-packages/libs/libffi feeds/packages/libs/
rm -rf tmp/openwrt-packages

# ===== 追加第三方插件包 =====
PKG_CONF="$GITHUB_WORKSPACE/packages/immortalwrt.conf"
[ -f "$PKG_CONF" ] && grep -v '^#' "$PKG_CONF" | grep -v '^$' >> .config && echo "已加载第三方插件: immortalwrt" || true

# ===== 清理无用配置 =====
sed -i '/CONFIG_PACKAGE_luci-i18n-clientstatus-zh-cn/d' .config
sed -i '/CONFIG_PACKAGE_luci-app-clientstatus/d' .config
