# Gemtek XR1710G 固件

编译配置 for **Airoha AN7581**，支持三种发行版固件同时构建。

## 固件发行版

| 发行版 | 默认 LAN IP | Web 管理地址 | 备注 |
|--------|------------|-------------|------|
| **iStoreOS** | `192.168.100.1` | `http://iStoreOS.lan/` | LuCI + iStore 管理面板 |
| **OpenWrt 24.10** | `192.168.1.1` | `http://192.168.1.1` | 标准 LuCI |
| **ImmortalWrt 24.10** | `192.168.1.1` | `http://192.168.1.1` | 增强插件生态 |

**通用登录：** 用户名 `root` / 密码 `password`，第一个网口默认 WAN，其余 LAN。

## 自定义默认 LAN IP

编译前在 GitHub Actions 触发构建时填写 `default_lan_ip` 参数（可选），可同时覆盖三个发行版的默认 IP。

不填写时各发行版使用自己的默认值（见上表）。

## 编译

**手动触发：** `Actions → Build All → Run workflow → 填写参数 → Run`

| 参数 | 说明 |
|------|------|
| `default_lan_ip` | 可选，三个 distro 同时使用此 IP（留空则用默认值）|
| `ssh` | 可选，填 `true` 开启 SSH 调试会话 |

**自动编译：** 每天北京时间 `00:00` 自动触发。

每个 Release tag 格式: `{dist_tag}_YYYY.MM.DD-HH.MM`

## 目录结构

```
Gemtek-XR1710G-wrt-builder/
├── .github/workflows/build.yml        # CI 构建脚本
├── depends/ubuntu-22.04               # 构建依赖
├── feeds-istoreos.conf                # iStoreOS feeds
├── feeds-openwrt.conf                 # OpenWrt feeds
├── feeds-immortalwrt.conf             # ImmortalWrt feeds
├── .config.istoreos                   # iStoreOS 内核配置
├── .config.openwrt                    # OpenWrt 内核配置
├── .config.immortalwrt                # ImmortalWrt 内核配置
├── diy-part1.d/                       # 每个 distro 独立的 part1 脚本
│   ├── istoreos.sh
│   ├── openwrt.sh
│   └── immortalwrt.sh
├── diy-part2.d/                       # 每个 distro 独立的 part2 脚本
│   ├── istoreos.sh
│   ├── openwrt.sh
│   └── immortalwrt.sh
└── files/                             # 每个 distro 独立的文件注入
    ├── istoreos/etc/config/network    # iStoreOS 自定义 /etc/config/network
    ├── openwrt/etc/config/network     # OpenWrt 自定义 /etc/config/network
    └── immortalwrt/etc/config/network # ImmortalWrt 自定义 /etc/config/network
```

## DIY 脚本说明

每个发行版有独立的 part1 / part2 脚本，互不影响，可在对应目录添加或修改：

**diy-part1.d/{distro}.sh** — 在 `scripts/feeds update` 之前运行
- 用途：修改版本号、替换源码文件等

**diy-part2.d/{distro}.sh** — 在 `.config` 加载之后、`make` 之前运行
- 用途：注入自定义配置、修改内核选项、覆盖 package 等

**files/{distro}/** — 在 `make` 阶段注入到固件文件系统
- 示例：`files/istoreos/etc/config/network` 会覆盖固件内对应路径

## 添加自定义包（以 iStoreOS 为例）

1. 克隆代码后进入源码目录：
   ```bash
   cd openwrt
   ```
2. 检查包是否存在：
   ```bash
   scripts/feeds search 关键字
   ```
3. 安装包：
   ```bash
   ./scripts/feeds install 包名
   ```
4. 在 `.config.istoreos` 中启用：
   ```bash
   make menuconfig
   # 选择 Target System → Subtarget → Target Profile → Packages
   ```
5. 提交改动

## 鸣谢

- [YYH2913/openwrt](https://github.com/YYH2913/openwrt) — XR1710G 设备适配
- [istoreos](https://github.com/istoreos/istoreos)
- [OpenWrt](https://github.com/openwrt/openwrt)
- [ImmortalWrt](https://github.com/immortalwrt/immortalwrt)
- [P3TERX/Actions-OpenWrt](https://github.com/P3TERX/Actions-OpenWrt)
- [GitHub Actions](https://github.com/features/actions)
- [softprops/action-gh-release](https://github.com/softprops/action-gh-release)
- [klever1988/cachewrtbuild](https://github.com/klever1988/cachewrtbuild)