ARCHS = arm64
SYSROOT = $(THEOS)/sdks/iPhoneOS9.3.sdk
TARGET = iphone::9.3:9.3
THEOS_BUILD_DIR = Packages
THEOS_DEVICE_IP = 192.168.1.77
include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Falcon
Falcon_FILES = FalconLS.xm FalconNC.xm NoctisSupport.xm FalconLSDelegate.m FalconNCDelegate.m UAObfuscatedString/UAObfuscatedString.m
Falcon_LIBRARIES = substrate flipswitch
Falcon_FRAMEWORKS = Foundation UIKit WebKit LocalAuthentication
Falcon_CODESIGN_FLAGS = -Sentitlements.xml

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += falconprefs
include $(THEOS_MAKE_PATH)/aggregate.mk
