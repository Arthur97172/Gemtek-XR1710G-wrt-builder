#!/bin/bash
# iStoreOS DIY part2 — inject network config with custom LAN IP

mkdir -p openwrt/files/etc/config
cp "$GITHUB_WORKSPACE/files/istoreos/etc/config/network" openwrt/files/etc/config/network
sed -i "s/\${DEFAULT_LAN_IP}/${DEFAULT_LAN_IP}/g; s/\${LAN_NETWORK}/${LAN_NETWORK}/g" openwrt/files/etc/config/network