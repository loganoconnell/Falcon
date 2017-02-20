ARCHS = arm64
SYSROOT = $(THEOS)/sdks/iPhoneOS9.3.sdk
TARGET = iphone::9.3:9.3
include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = FalconPrefs
FalconPrefs_FILES = FCNRootListController.m  UILabel+AutomaticWriting/UILabel+AutomaticWriting.m
FalconPrefs_INSTALL_PATH = /Library/PreferenceBundles
FalconPrefs_LIBRARIES = MobileGestalt substrate
FalconPrefs_FRAMEWORKS = Foundation UIKit CoreGraphics QuartzCore MessageUI
FalconPrefs_PRIVATE_FRAMEWORKS = Preferences Twitter

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/FalconPrefs.plist$(ECHO_END)
