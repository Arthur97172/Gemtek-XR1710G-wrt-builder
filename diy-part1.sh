#!/bin/bash
#===============================================
# Description: DIY script
# File name: diy-script.sh
# Lisence: MIT
# Author: P3TERX
# Blog: https://p3terx.com
#===============================================

# 修改版本为编译日期（如果 version 文件存在）
date_version=$(date +"%Y%m%d%H")
[ -f version ] && sed -i "s/0000000000/${date_version}/g" version
