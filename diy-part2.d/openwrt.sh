#!/bin/bash
# OpenWrt DIY part2
# — 在 .config 加载之后、make 之前运行 —

# ===== 1. 全盘物理剔除引发 Kconfig 死循环的冲突包 =====
echo "正在物理剔除冲突与死循环组件..."

# 彻底清理 nftables-nojson（包含单独的 Makefile 文件）
find . -name "Makefile" -exec grep -l "PACKAGE_nftables-nojson" {} + | xargs rm -rf 2>/dev/null || true
find . -type d -name "*nftables-nojson*" -exec rm -rf {} + 2>/dev/null || true

# 彻底清理 clientstatus 主包及其关联语言包
find . -type d -name "*clientstatus*" -exec rm -rf {} + 2>/dev/null || true

# 清理 freeradius3 和 mihomo 冲突包
rm -rf feeds/packages/net/freeradius3
find . -type d -name "*mihomo*" -exec rm -rf {} + 2>/dev/null || true

# 顺便清理 sdl3 警告
rm -rf package/feeds/video/sdl3 feeds/video/video/sdl3* 2>/dev/null || true

# ===== 2. 追加第三方插件包 =====
PKG_CONF="$GITHUB_WORKSPACE/packages/openwrt.conf"
[ -f "$PKG_CONF" ] && grep -v '^#' "$PKG_CONF" | grep -v '^$' >> .config && echo "已加载第三方插件: openwrt" || true

# ===== 3. 清理旧的 config 临时缓存，强制重绘依赖关系（绝对不能注释！） =====
rm -rf tmp/.config*
rm -rf tmp/info/.files-package*

echo "✅ DIY Part2 修复完毕，已强制重置缓存！"
