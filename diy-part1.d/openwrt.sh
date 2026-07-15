#!/bin/bash
# OpenWrt DIY part1 — version date patch

date_version=$(date +"%Y%m%d%H")
[ -f version ] && sed -i "s/0000000000/${date_version}/g" version || true