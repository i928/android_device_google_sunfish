#
# Copyright (C) 2020-2021 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

# Inherit some common Lineage stuff.
$(call inherit-product, vendor/lineage/config/common_full_phone.mk)

# Inherit device configuration
$(call inherit-product, device/google/sunfish/aosp_sunfish.mk)

include device/google/sunfish/device-lineage.mk

# Device identifier. This must come after all inclusions
PRODUCT_BRAND := google
PRODUCT_MODEL := Pixel 4a
PRODUCT_NAME := lineage_sunfish

# adb root: vendor/lineage/config/common.mk sets
# PRODUCT_NOT_DEBUGGABLE_IN_USERDEBUG := true, which makes userdebug builds
# ro.debuggable=0 and builds user sepolicy (no su domain), so adbd refuses root.
# This product makefile is the top of the inheritance graph, so its value wins.
PRODUCT_NOT_DEBUGGABLE_IN_USERDEBUG := false
PRODUCT_COPY_FILES += \
    device/google/sunfish/init.adb-root.rc:$(TARGET_COPY_OUT_SYSTEM_EXT)/etc/init/init.adb-root.rc

# Boot animation
TARGET_SCREEN_HEIGHT := 2340
TARGET_SCREEN_WIDTH := 1080

PRODUCT_BUILD_PROP_OVERRIDES += \
    BuildDesc="sunfish-user 13 TQ3A.230805.001.S1 10786265 release-keys" \
    BuildFingerprint=google/sunfish/sunfish:13/TQ3A.230805.001.S1/10786265:user/release-keys \
    DeviceProduct=sunfish

$(call inherit-product, vendor/google/sunfish/sunfish-vendor.mk)

# Ship APEXes uncompressed: compressed .capex are unpacked to /data on the first
# boot after every update (~5 s on sunfish). Costs ~150 MB more in super.
PRODUCT_COMPRESSED_APEX := false
