#
# Copyright (C) 2020-2021 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

# Kernel
BOARD_KERNEL_IMAGE_NAME := Image.lz4
TARGET_COMPILE_WITH_MSM_KERNEL := true
TARGET_KERNEL_CONFIG := sunfish_defconfig
TARGET_KERNEL_NO_GCC := true
TARGET_KERNEL_SOURCE := kernel/google/msm-4.14

# Kernel Clang: Clang 23 (r614150), the same kernel toolchain as crosshatch and
# the Evolution X sunfish build. It lives in prebuilts/clang/kernel (not the
# platform prebuilts/clang/host). Unset both lines for the LineageOS default.
TARGET_KERNEL_CLANG_VERSION := r614150
TARGET_KERNEL_CLANG_PATH := $(abspath .)/prebuilts/clang/kernel/$(HOST_PREBUILT_TAG)/clang-$(TARGET_KERNEL_CLANG_VERSION)
TARGET_NEEDS_DTBOIMAGE := true

# Partitions
AB_OTA_PARTITIONS += \
    vendor
BOARD_VENDORIMAGE_FILE_SYSTEM_TYPE := erofs

# Reserve space for gapps install
-include vendor/lineage/config/BoardConfigReservedSize.mk

# SELinux
BOARD_SEPOLICY_DIRS += device/google/sunfish/sepolicy-lineage/dynamic
BOARD_SEPOLICY_DIRS += device/google/sunfish/sepolicy-lineage/vendor
# prebuilts/extra-apps is untracked local content (see device.mk); skip its
# sepolicy when a freshly synced tree does not have it.
ifneq ($(wildcard device/google/sunfish/prebuilts/extra-apps/sepolicy/file_contexts),)
BOARD_SEPOLICY_DIRS += device/google/sunfish/prebuilts/extra-apps/sepolicy
endif

# Verified Boot
ifneq ($(WITH_AVB),true)
BOARD_AVB_MAKE_VBMETA_IMAGE_ARGS += --flags 3
endif

include vendor/google/sunfish/BoardConfigVendor.mk

# libksud.so is shipped via PRODUCT_COPY_FILES in device.mk (see comment
# there for why) -- this flag is what actually permits an ELF binary
# through that mechanism; it's board-scoped and silently ignored if set
# from a product .mk like device.mk instead.
BUILD_BROKEN_ELF_PREBUILT_PRODUCT_COPY_FILES := true

# PRODUCT_COPY_FILES's copy-one-file rule uses plain `cp` (no -p), which
# drops the source file's executable bit regardless of what it was, and the
# app execs this file directly as a subprocess. Force it via a separate
# stamp file (referencing $(PRODUCT_OUT) as a rule prerequisite from
# device.mk hits a "||PRODUCT-PATH-PH||" placeholder-substitution bug --
# PRODUCT_OUT isn't fully resolved yet at product-config-parse time;
# BoardConfigLineage.mk runs later and is fine).
# Same condition as the libksud.so PRODUCT_COPY_FILES in device.mk: without
# the app there is no copied file, so no rule may depend on it. When absent,
# libksud_chmod_stamp stays empty and the droidcore line below is a no-op.
# Board config cannot see device.mk's app list, so repeat its decision: the app
# ships unless a release build past the transition leaves it out of release.txt.
SUNFISH_KSU_APP := $(wildcard device/google/sunfish/prebuilts/extra-apps/prebuilt/KernelSUNext.apk)
ifeq ($(SUNFISH_RELEASE)$(or $(SUNFISH_RELEASE_TRANSITION),1),10)
ifeq ($(filter KernelSUNext,$(shell sed -e 's/#.*//' device/google/sunfish/release.txt 2>/dev/null)),)
SUNFISH_KSU_APP :=
endif
endif
ifneq ($(SUNFISH_KSU_APP),)
libksud_chmod_stamp := $(OUT_DIR)/libksud_chmod.stamp
$(libksud_chmod_stamp): $(PRODUCT_OUT)/$(TARGET_COPY_OUT_PRODUCT)/app/KernelSUNext/lib/arm64/libksud.so
	chmod 755 $<
	touch $@
endif
droidcore: $(libksud_chmod_stamp)
