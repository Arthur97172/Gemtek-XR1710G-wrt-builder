#!/bin/bash
# OpenWrt DIY part2

# 1. 修复 luci-app-clientstatus 循环依赖
find feeds/ package/ -type f -name "Makefile" 2>/dev/null | grep "luci-app-clientstatus" | xargs sed -i 's/DEPENDS:=luci-app-clientstatus/DEPENDS:=+luci-app-clientstatus/g' || true

# 2. 移除缺失依赖的 sdl3
rm -rf package/feeds/video/sdl3

# 3. 【全新安全方案】提前为 libffi 报错目录建立软链接
# 无论它生成 musl 还是 gnu 目录，我们都让 aarch64-openwrt-linux* 通配符能稳稳对齐
FFI_DIR="build_dir/target-aarch64_cortex-a53_musl/libffi-3.4.7"
if [ -d "$FFI_DIR" ]; then
    cd "$FFI_DIR"
    # 找出实际生成的 target 目录（比如 aarch64-openwrt-linux-musl）
    REAL_DIR=$(ls -d aarch64-openwrt-linux-* 2>/dev/null | head -n 1)
    if [ -n "$REAL_DIR" ]; then
        # 建立一个叫 aarch64-openwrt-linux 的软链接，这样 Makefile 里的 aarch64-openwrt-linux* 必然能匹配到
        ln -sf "$REAL_DIR" "aarch64-openwrt-linux"
    fi
    cd - >/dev/null
fi

# ===== 保持你原有的追加第三方包及清理逻辑 =====
PKG_CONF="$GITHUB_WORKSPACE/packages/openwrt.conf"
[ -f "$PKG_CONF" ] && grep -v '^#' "$PKG_CONF" | grep -v '^$' >> .config && echo "已加载第三方插件: openwrt" || true

sed -i '/CONFIG_PACKAGE_luci-i18n-clientstatus-zh-cn/d' .config
sed -i '/CONFIG_PACKAGE_luci-app-clientstatus/d' .config
