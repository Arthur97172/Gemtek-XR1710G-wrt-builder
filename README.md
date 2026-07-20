# Gemtek XR1710G 固件

编译配置 for **Airoha AN7581**，支持两种发行版固件构建。

## 固件发行版

| 发行版 | 版本 | 默认用户名 | 默认IP（可自定义） | 默认密码 |
|--------|------|-----------|-----------|---------|
| **OpenWrt** | SNAPSHOT | root | 192.168.1.1 | `password` |
| **ImmortalWrt** | SNAPSHOT | root | 192.168.1.1 | 无密码（首次按 `Enter`） |

**通用：第一个网口默认 WAN，其余 LAN。各发行版使用其系统默认 LAN IP。**

## 编译

**手动触发：** `Actions → Build Airoha_an7581-Wrt → Run workflow → 填写参数 → Run`

| 参数 | 说明 |
|------|------|
| `target` | 指定编译哪个发行版：`openwrt` / `immortalwrt`（默认 `immortalwrt`） |
| `ipaddr` | 设置软路由管理地址，如 `192.168.1.1`（默认 `192.168.1.1`） |
| `ssh` | 可选，填 `true` 开启 SSH 调试会话 |

---

## 目录结构

```
iStoreOS-for-Gemtek-XR1710G/
├── .github/
│   └── workflows/
│       ├── build.yml          # CI 构建脚本
│       └── sync-apps.yml      # 自动同步 apps/ 到各仓库
├── apps/                      # 第三方内置应用（编译时自动复制到源码）
│   ├── luci-app-airoha-fancontrol/
│   ├── luci-app-airoha-flowsense/
│   └── luci-app-airoha-npu/
├── configs/                   # 内核配置文件
│   ├── openwrt.config
│   └── immortalwrt.config
├── depends/ubuntu-22.04       # 构建依赖
├── diy-part2.d/               # 每个 distro 独立的配置注入脚本
│   ├── openwrt.sh
│   └── immortalwrt.sh
├── feeds.d/                   # feeds 源配置
│   ├── openwrt
│   └── immortalwrt
├── files/                     # 固件文件系统覆盖
│   └── etc/
│       ├── banner
│       └── uci-defaults/99-custom.sh
├── packages/                  # 每个 distro 的第三方插件配置
│   ├── openwrt.conf
│   └── immortalwrt.conf
└── scripts/
    └── diy-part1.sh           # 版本号补丁，all distros 共用
```

---

## 执行顺序

```
scripts/diy-part1.sh      →  feeds update/install 之前运行，all distros 共用
diy-part2.d/{distro}.sh   →  .config 加载之后、make 之前运行，每个 distro 独立
```

### scripts/diy-part1.sh — 版本号（全局共用）

`scripts/feeds update` 之前运行，此时源码刚 clone 完毕、feeds.conf 就位。

```bash
# 示例：修改 version 文件中的时间戳
date_version=$(date +"%Y%m%d%H")
sed -i "s/0000000000/${date_version}/g" version
```

---

## DIY part2 — 配置注入与包管理

在 `.config` 加载之后、`make` 之前运行，此时可以读写 `.config` 文件和 `openwrt/` 目录。

### 添加第三方 package（推荐方式）

直接编辑 `packages/{distro}.conf`，**无需修改 diy 脚本**，编译时自动追加。例如在 `packages/immortalwrt.conf` 中添加：

```
CONFIG_PACKAGE_luci-app-samba4=y
CONFIG_PACKAGE_curl=y
CONFIG_PACKAGE_tcpdump=y
```

已在 `packages/*.conf` 中的包，diy-part2.d 会自动追加到 `.config`，不污染原始 `.config.*`。如需移除某个包，注释掉或删掉对应行即可。

### 修改内核选项

直接编辑 `.config` 文件（追加或注释掉行）。

```bash
# 追加
echo 'CONFIG_PACKAGE_kmod-nf-tcp-bbr=y' >> .config

# 注释掉
sed -i '/CONFIG_PACKAGE_kmod-usb-ohci/d' .config
```

### apps/ 目录（内置应用）

`apps/` 下的应用（如 `luci-app-airoha-*`）会在编译前自动复制到 `openwrt/package/` 目录，无需手动管理。若需添加新应用，直接放入 `apps/` 即可。

---

## 鸣谢

- [YYH2913/openwrt](https://github.com/YYH2913/openwrt) — XR1710G 设备适配
- [OpenWrt](https://github.com/openwrt/openwrt)
- [ImmortalWrt](https://github.com/immortalwrt/immortalwrt)
- [P3TERX/Actions-OpenWrt](https://github.com/P3TERX/Actions-OpenWrt)
- [GitHub Actions](https://github.com/features/actions)
- [softprops/action-gh-release](https://github.com/softprops/action-gh-release)
- [klever1988/cachewrtbuild](https://github.com/klever1988/cachewrtbuild)