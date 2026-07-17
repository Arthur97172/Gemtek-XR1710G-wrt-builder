#!/bin/bash
# OpenWrt DIY part2
# — 在 .config 加载之后、make 之前运行 —

# ===== 追加第三方插件包（不影响 .config 主文件）=====
PKG_CONF="$GITHUB_WORKSPACE/packages/openwrt.conf"
[ -f "$PKG_CONF" ] && grep -v '^#' "$PKG_CONF" | grep -v '^$' >> .config && echo "已加载第三方插件: openwrt" || true

# 1. 强行修复 luci-app-clientstatus 源码作者引发的循环依赖死锁
find feeds/ package/ -type f -name "Makefile" 2>/dev/null | grep "luci-app-clientstatus" | xargs sed -i 's/DEPENDS:=luci-app-clientstatus/DEPENDS:=+luci-app-clientstatus/g' || true

# 2. 移除缺失依赖且一般用不上的 sdl3 源码，防止后续报错
rm -rf package/feeds/video/sdl3

# 3. 修复本次遇到的 libffi (aarch64) 编译找不到 fficonfig.h 的 Bug
LIBFFI_MAKEFILE="feeds/packages/libs/libffi/Makefile"
[ -f "$LIBFFI_MAKEFILE" ] && sed -i 's/\$(PKG_BUILD_DIR)\/aarch64-openwrt-linux\*\/fficonfig.h/\$(PKG_BUILD_DIR)\/\*\/fficonfig.h/g' "$LIBFFI_MAKEFILE" || true

# ===== 原有的 .config 修改逻辑 =====
PKG_CONF="$GITHUB_WORKSPACE/packages/openwrt.conf"
[ -f "$PKG_CONF" ] && grep -v '^#' "$PKG_CONF" | grep -v '^$' >> .config && echo "已加载第三方插件: openwrt" || true

sed -i '/CONFIG_PACKAGE_luci-i18n-clientstatus-zh-cn/d' .config
sed -i '/CONFIG_PACKAGE_luci-app-clientstatus/d' .config
