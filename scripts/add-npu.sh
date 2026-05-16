#!/bin/bash
# 此时已经位于 $OPENWRT_PATH 下（openwrt 根目录）

cd package || exit 1

# 克隆 NPU 插件
if [ ! -d luci-app-airoha-npu ]; then
    echo "Cloning luci-app-airoha-npu..."
    git clone https://github.com/rchen14b/luci-app-airoha-npu.git
fi

# 修复 Makefile
if [ -f luci-app-airoha-npu/Makefile ]; then
    if ! grep -q "^include \$(TOPDIR)/feeds/luci/luci.mk" luci-app-airoha-npu/Makefile; then
        sed -i '1i include $(TOPDIR)/feeds/luci/luci.mk' luci-app-airoha-npu/Makefile
        echo "Fixed luci-app-airoha-npu Makefile"
    fi
fi

# 打包 NPU 固件（如果文件存在）
if [ -f "$GITHUB_WORKSPACE/npu-firmware/en7581_npu_rv32.bin" ]; then
    mkdir -p airoha-en7581-mt7996-npu-firmware
    cp "$GITHUB_WORKSPACE/npu-firmware/en7581_npu_rv32.bin" airoha-en7581-mt7996-npu-firmware/
    cat > airoha-en7581-mt7996-npu-firmware/Makefile << 'EOF'
include $(TOPDIR)/rules.mk
PKG_NAME:=airoha-en7581-mt7996-npu-firmware
PKG_RELEASE:=1
include $(INCLUDE_DIR)/package.mk
define Package/airoha-en7581-mt7996-npu-firmware
  SECTION:=firmware
  CATEGORY:=Firmware
  TITLE:=Airoha EN7581 NPU firmware for MT7996
endef
define Build/Compile
endef
define Package/airoha-en7581-mt7996-npu-firmware/install
  $(INSTALL_DIR) $(1)/lib/firmware/airoha
  $(INSTALL_DATA) ./en7581_npu_rv32.bin $(1)/lib/firmware/airoha/
endef
$(eval $(call BuildPackage,airoha-en7581-mt7996-npu-firmware))
EOF
    echo "NPU firmware package created"
else
    echo "WARNING: NPU firmware not found at $GITHUB_WORKSPACE/npu-firmware/en7581_npu_rv32.bin"
fi

# 返回 openwrt 根目录并重新安装 feeds
cd ..
./scripts/feeds install -a

echo "NPU integration completed."
