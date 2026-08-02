#!/bin/bash
# Immortalwrt DIY part2
# — 在 .config 加载之后、make 之前运行 —

# =================================================================
# 步骤 1：加载第三方插件包配置（包含你的 mihomo 配置）
# =================================================================
PKG_CONF="$GITHUB_WORKSPACE/packages/immortalwrt.conf"
if [ -f "$PKG_CONF" ]; then
    grep -v '^#' "$PKG_CONF" | grep -v '^$' >> .config
    echo "已成功加载第三方插件配置"
fi

# =================================================================
# 步骤 2：【彻底全盘清理】引起 Kconfig 死循环/冲突的源码包
# =================================================================
echo "正在物理剔除冲突与崩溃组件..."

# 1. 物理删除 clientstatus 主包 以及 遗留的语言包（包含 package/emortal 路径）
#find . -type d -name "*clientstatus*" -exec rm -rf {} + 2>/dev/null || true
find feeds/ -name "Makefile" -path "*clientstatus*" -exec sed -i '/luci-i18n-clientstatus-zh-cn/d' {} + 2>/dev/null || true

# 2. 深度清理 nftables-nojson（通过搜索文件内部文本 + 文件夹全盘查找）
find . -name "Makefile" -exec grep -l "PACKAGE_nftables-nojson" {} + | xargs rm -rf 2>/dev/null || true
find . -type d -name "*nftables-nojson*" -exec rm -rf {} + 2>/dev/null || true

# 3. 清理 freeradius3 与 mihomo 冲突包
rm -rf feeds/packages/net/freeradius3
find . -type d -name "*mihomo*" -exec rm -rf {} + 2>/dev/null || true

# =================================================================
# 步骤 3：移除缺失依赖的 sdl3 游戏残余组件，消除满屏报错
# =================================================================
echo "正在清理 sdl3 残余组件..."
rm -rf package/feeds/video/sdl3
rm -rf package/feeds/video/sdl2-compat
rm -rf package/feeds/video/sdl3-*
rm -rf feeds/video/video/sdl3*

# =================================================================
# 步骤 4：替换 libffi 源码，避开 aarch64 路径匹配 Bug
# =================================================================
echo "正在降级替换 libffi 源码..."
rm -rf feeds/packages/libs/libffi
git clone https://github.com/openwrt/packages.git tmp/openwrt-packages --depth=1
cp -r tmp/openwrt-packages/libs/libffi feeds/packages/libs/
rm -rf tmp/openwrt-packages

# =================================================================
# 步骤 5：抹除 .config 冲突条目 & 【关键】强行清空旧索引缓存
# =================================================================
sed -i '/CONFIG_PACKAGE_luci-i18n-clientstatus-zh-cn/d' .config
sed -i '/CONFIG_PACKAGE_luci-app-clientstatus/d' .config

# 强制 OpenWrt 重新扫描全盘 package，防止读取旧报错缓存（极其关键！）
rm -rf tmp/.config*
rm -rf tmp/info/.files-package*

echo "✅ DIY Part2 配置修正完成！"
