#!/bin/bash
cd openwrt/package || exit 1

# 克隆 NPU 插件
if [ ! -d luci-app-airoha-npu ]; then
    git clone https://github.com/rchen14b/luci-app-airoha-npu.git
    sed -i '1i include $(TOPDIR)/feeds/luci/luci.mk' luci-app-airoha-npu/Makefile
fi

# 打包 NPU 固件（如果文件存在）
if [ -f "$GITHUB_WORKSPACE/npu-firmware/en7581_npu_rv32.bin" ]; then
    mkdir -p airoha-npu-firmware
    cp "$GITHUB_WORKSPACE/npu-firmware/en7581_npu_rv32.bin" airoha-npu-firmware/
    cat > airoha-npu-firmware/Makefile << 'EOF'
include $(TOPDIR)/rules.mk
PKG_NAME:=airoha-npu-firmware
PKG_RELEASE:=1
include $(INCLUDE_DIR)/package.mk
define Package/airoha-npu-firmware
  SECTION:=firmware
  CATEGORY:=Firmware
  TITLE:=Airoha NPU firmware
endef
define Build/Compile
endef
define Package/airoha-npu-firmware/install
  $(INSTALL_DIR) $(1)/lib/firmware/airoha
  $(INSTALL_DATA) ./en7581_npu_rv32.bin $(1)/lib/firmware/airoha/
endef
$(eval $(call BuildPackage,airoha-npu-firmware))
EOF
    echo "NPU firmware package created"
else
    echo "No NPU firmware found, skipping"
fi

cd ..
./scripts/feeds install -a
