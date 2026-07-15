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
| `target` | 可选，指定编译哪个发行版：`all`（默认）、`istoreos`、`openwrt`、`immortalwrt` |
| `default_lan_ip` | 可选，三个 distro 同时使用此 IP（留空则用默认值）|
| `ssh` | 可选，填 `true` 开启 SSH 调试会话 |

选择 `target` 时，每次只编译该发行版，可用于单独更新某个固件而不触发其他两个。

**自动编译：** 每天北京时间 `00:00` 自动触发。

每个 Release tag 格式: `{dist_tag}_YYYY.MM.Dd-HH.MM`

---

## 执行顺序

```
diy-part1.sh              →  feeds update/install 之前运行，all distros 共用
diy-part2.d/{distro}.sh   →  .config 加载之后、make 之前运行，每个 distro 独立
files/{distro}/            →  make 阶段自动注入固件文件系统
```

### diy-part1.sh — 版本号（全局共用）

`scripts/feeds update` 之前运行，此时源码刚 clone 完毕、feeds.conf 就位。

```bash
# 示例：修改 version 文件中的时间戳
date_version=$(date +"%Y%m%d%H")
sed -i "s/0000000000/${date_version}/g" version

# 示例：替换某个源码文件
# cp "$GITHUB_WORKSPACE/patches/mt7996.c" openwrt/package/.../mt7996.c

# 示例：给源码打 patch
# cd openwrt && patch -p1 < "$GITHUB_WORKSPACE/patches/foo.patch"
```

---

### diy-part2.d — 配置注入与包管理

在 `.config` 加载之后、`make` 之前运行，此时可以读写 `.config` 文件和 `openwrt/` 目录。

#### 场景一：文件注入（自定义固件内置文件）

将文件放到 `files/{distro}/` 目录，编译时自动覆盖固件内的对应路径。

**目录结构示例：**
```
files/
├── istoreos/
│   └── etc/config/
│       ├── network          # 自定义网络配置（含 LAN IP）
│       └── firewall         # 自定义防火墙规则
└── openwrt/
    └── etc/config/
        └── network
```

**network 模板示例（`files/openwrt/etc/config/network`）：**
```
config interface 'loopback'
	option device 'lo'
	option proto 'static'
	option ipaddr '127.0.0.1'
	option netmask '255.0.0.0'

config device
	option name 'br-lan'
	option type 'bridge'
	list ports 'lan1'
	list ports 'lan2'
	list ports 'lan3'
	list ports 'lan4'

config interface 'lan'
	option device 'br-lan'
	option proto 'static'
	option ipaddr '${DEFAULT_LAN_IP}'
	option netmask '255.255.255.0'
	list ipaddr '${DEFAULT_LAN_IP}/24'

config interface 'wan'
	option device 'wan'
	option proto 'dhcp'
```

**diy-part2.d 中的注入写法：**
```bash
cp "$GITHUB_WORKSPACE/files/openwrt/etc/config/network" openwrt/files/etc/config/network
sed -i "s/\${DEFAULT_LAN_IP}/${DEFAULT_LAN_IP}/g" openwrt/files/etc/config/network
```

#### 场景二：修改内核选项（.config 覆写）

直接编辑 `.config` 文件（追加或注释掉行）。

```bash
# 追加：开启 BBR TCP 拥塞控制
echo 'CONFIG_PACKAGE_kmod-nf-tcp-bbr=y' >> .config
echo 'CONFIG_PACKAGE_tcpdump=y' >> .config

# 注释掉：禁用不需要的 USB 驱动（减小体积）
sed -i '/CONFIG_PACKAGE_kmod-usb-ohci/d' .config
sed -i '/CONFIG_PACKAGE_kmod-usb-uhci/d' .config

# 强制覆盖某个选项（先删后加）
sed -i '/CONFIG_KERNEL_HZ=/d' .config
echo 'CONFIG_KERNEL_HZ=1000' >> .config
```

#### 场景三：添加第三方 package（推荐方式）

推荐直接编辑 `packages/{distro}.conf`，**无需修改 diy 脚本**，编译时自动追加。例如在 `packages/istoreos.conf` 中添加：

```
CONFIG_PACKAGE_luci-app-samba4=y
CONFIG_PACKAGE_curl=y
CONFIG_PACKAGE_tcpdump=y
```

已在 `packages/*.conf` 中的包，diy-part2.d 会自动追加到 `.config`，不污染原始 `.config.*`。如需移除某个包，注释掉或删掉对应行即可。

**也可用 sed 在脚本中临时修改（不推荐，会污染 `.config.*`）：**
```bash
echo 'CONFIG_PACKAGE_curl=y' >> .config
sed -i '/CONFIG_PACKAGE_p910nd/d' .config
```

#### 场景四：UCI 默认值（固件首次启动自动应用）

通过 `/etc/uci-defaults/` 注入，固件首次启动时 UCI 会自动执行这些脚本。

```bash
mkdir -p openwrt/files/etc/uci-defaults
cat > openwrt/files/etc/uci-defaults/99-custom << 'UCIEOF'
#!/bin/sh
uci set network.lan.ipaddr='${DEFAULT_LAN_IP}'
uci commit network
uci set system.@system[0].timezone='CST-8'
uci commit system
UCIEOF
sed -i "s/\${DEFAULT_LAN_IP}/${DEFAULT_LAN_IP}/g" \
  openwrt/files/etc/uci-defaults/99-custom
```

---

## 目录结构

```
Gemtek-XR1710G-wrt-builder/
├── .github/workflows/build.yml     # CI 构建脚本
├── depends/ubuntu-22.04            # 构建依赖
├── diy-part1.sh                    # 版本号补丁，all distros 共用
├── feeds-istoreos.conf
├── feeds-openwrt.conf
├── feeds-immortalwrt.conf
├── .config.istoreos
├── .config.openwrt
├── .config.immortalwrt
├── diy-part2.d/                    # 每个 distro 独立的配置注入脚本
│   ├── istoreos.sh
│   ├── openwrt.sh
│   └── immortalwrt.sh
└── files/                          # 文件注入目录
    ├── istoreos/etc/config/network
    ├── openwrt/etc/config/network
    └── immortalwrt/etc/config/network
packages/                           # 每个 distro 独立的第三方插件配置
├── istoreos.conf
├── openwrt.conf
└── immortalwrt.conf
```

## 添加第三方插件

三个 distro 的插件配置文件**完全独立**，互不影响。

### 插件配置文件

| 发行版 | 插件配置 |
|--------|---------|
| iStoreOS | `packages/istoreos.conf` |
| OpenWrt | `packages/openwrt.conf` |
| ImmortalWrt | `packages/immortalwrt.conf` |

每个文件只放包名注释掉（`#` 开头）和要启用的包（格式：`CONFIG_PACKAGE_xxx=y`）。编译时 `diy-part2.d/{distro}.sh` 自动将这些行追加到 `.config`，不修改原始 `.config.*`。

**示例（`packages/istoreos.conf`）：**
```
# CONFIG_PACKAGE_luci-app-wol=y
# CONFIG_PACKAGE_luci-app-guest-wifi=y
CONFIG_PACKAGE_curl=y
CONFIG_PACKAGE_luci-app-samba4=y
CONFIG_PACKAGE_tcpdump=y
```
取消注释即启用，注释掉即不编译，不会污染原始 `.config.*`。

### 第一步：在 feeds 文件中添加仓库（如果插件来自第三方）

根据 distro 修改对应的 `feeds-*.conf`：
```
src-git myrepo https://github.com/用户名/仓库.git;分支
```

### 第二步：在 packages 配置文件中启用插件

编辑对应 distro 的 `packages/*.conf`，取消注释或新增：
```
CONFIG_PACKAGE_luci-app-myplugin=y
CONFIG_PACKAGE_my-plugin=y
```

不清楚包的确切名称？本地快速查找（需先 clone 源码）：
```bash
cd openwrt
./scripts/feeds update -a
./scripts/feeds install -a
./scripts/feeds search 关键字
```

### 第三步：提交并推送

```bash
git add feeds-istoreos.conf packages/istoreos.conf
git commit -m "feat: add third-party plugin repo and packages"
git push origin main
```

然后在 Actions 触发编译即可。

## 鸣谢

- [YYH2913/openwrt](https://github.com/YYH2913/openwrt) — XR1710G 设备适配
- [istoreos](https://github.com/istoreos/istoreos)
- [OpenWrt](https://github.com/openwrt/openwrt)
- [ImmortalWrt](https://github.com/immortalwrt/immortalwrt)
- [P3TERX/Actions-OpenWrt](https://github.com/P3TERX/Actions-OpenWrt)
- [GitHub Actions](https://github.com/features/actions)
- [softprops/action-gh-release](https://github.com/softprops/action-gh-release)
- [klever1988/cachewrtbuild](https://github.com/klever1988/cachewrtbuild)