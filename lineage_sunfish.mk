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

# MindTheGapps, baked in: with system_ext and product on EROFS nothing can
# be flashed into them after the ROM. SUNFISH_GAPPS picks the set, e.g.
#   SUNFISH_GAPPS=none m bacon
#   full  (default) the whole MindTheGapps set
#   mini  MindTheGapps' own reduced set (TARGET_IS_GROUPER): no SetupWizard,
#         GoogleRestore, Wellbeing, Velvet (Google app), Markup, Speech
#         Services or TalkBack -- setup runs without Google's wizard, so no
#         restore from a Google backup during setup
#   none  no Google apps at all (de-Googled build)
SUNFISH_GAPPS ?= full
ifeq ($(filter full mini none,$(SUNFISH_GAPPS)),)
$(error SUNFISH_GAPPS=$(SUNFISH_GAPPS): use full, mini or none)
endif
ifneq ($(SUNFISH_GAPPS),none)
ifeq ($(SUNFISH_GAPPS),mini)
TARGET_IS_GROUPER := true
endif
$(call inherit-product, vendor/gapps/arm64/arm64-vendor.mk)
endif
