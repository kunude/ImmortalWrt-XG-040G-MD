#!/bin/bash
cd package || exit 1

# 只打包 NPU 固件（不再克隆插件，因为 patch.sh 已经处理）
if [ -f "$GITHUB_WORKSPACE/npu-firmware/en7581_npu_rv32.bin" ]; then
    rm -rf airoha-en7581-mt7996-npu-firmware  # 确保没有旧目录干扰
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

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./en7581_npu_rv32.bin $(PKG_BUILD_DIR)/
endef

define Build/Compile
endef

define Package/airoha-en7581-mt7996-npu-firmware/install
	$(INSTALL_DIR) $(1)/lib/firmware/airoha
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/en7581_npu_rv32.bin $(1)/lib/firmware/airoha/en7581_npu_rv32.bin
endef

$(eval $(call BuildPackage,airoha-en7581-mt7996-npu-firmware))
EOF
    echo "NPU firmware package created"
else
    echo "WARNING: NPU firmware not found"
fi

cd ..
./scripts/feeds install -a
echo "NPU firmware integration completed."
