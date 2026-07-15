# Gemtek XR1710G 固件

编译配置 for **Airoha AN7581**，支持三种发行版固件同时构建。

[![支持设备](https://img.shields.io/badge/XR1710G-Airoha%20AN7581-blueviolet?style=flat-square)]()

## 固件发行版

| 发行版 | 特色 | 内核 |
|--------|------|------|
| **iStoreOS** | 网盘、存储、应用商店 | 6.18 |
| **OpenWrt 24.10** | 标准上游固件 | 6.18 |
| **ImmortalWrt 24.10** | 增强插件生态 | 6.18 |

## 设备信息

- **设备:** XR1710G (Gemtek)
- **SoC:** Airoha AN7581
- **架构:** airoha / an7581
- **固件格式:** sysupgrade.itb

## 默认配置

- IP: `http://192.168.100.1` 或 `http://iStoreOS.lan/`
- 用户名: `root`
- 密码: `password`
- 第一个网口默认 WAN，其余为 LAN

## 编译

点击 **Actions → Build Firmware → Run workflow** 可手动触发三发行版同时构建，构建完成后自动发布到 Releases。

每个 Release tag 格式: `{dist_tag}_YYYY.MM.DD-HH.MM`

## 文件说明

| 文件 | 用途 |
|------|------|
| `feeds-istoreos.conf` | iStoreOS 专属 feeds |
| `feeds-openwrt.conf` | 标准 OpenWrt feeds |
| `feeds-immortalwrt.conf` | ImmortalWrt feeds |
| `.config.istoreos` | iStoreOS 内核配置 |
| `.config.openwrt` | OpenWrt 内核配置 |
| `.config.immortalwrt` | ImmortalWrt 内核配置 |
| `depends/ubuntu-22.04` | 构建依赖 |
| `diy-part1.sh` | 版本号生成脚本 |
| `.github/workflows/build.yml` | 三发行版 CI 脚本 |

## 鸣谢

- [YYH2913/openwrt](https://github.com/YYH2913/openwrt) — XR1710G 设备适配
- [istoreos](https://github.com/istoreos/istoreos)
- [OpenWrt](https://github.com/openwrt/openwrt)
- [ImmortalWrt](https://github.com/immortalwrt/immortalwrt)
- [P3TERX/Actions-OpenWrt](https://github.com/P3TERX/Actions-OpenWrt)
- [GitHub Actions](https://github.com/features/actions)
- [softprops/action-gh-release](https://github.com/softprops/action-gh-release)
- [klever1988/cachewrtbuild](https://github.com/klever1988/cachewrtbuild)