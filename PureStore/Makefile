TARGET := iphone:clang:16.5:14.0
INSTALL_TARGET_PROCESSES = PureStore
ARCHS = arm64

TARGET_CODESIGN = ../Exploits/fastPathSign/fastPathSign

include $(THEOS)/makefiles/common.mk

APPLICATION_NAME = PureStore

PureStore_FILES = $(wildcard *.m) $(wildcard ../Shared/*.m)
PureStore_FRAMEWORKS = UIKit CoreGraphics CoreServices CoreTelephony UniformTypeIdentifiers
PureStore_PRIVATE_FRAMEWORKS = Preferences MobileIcons MobileContainerManager
PureStore_LIBRARIES = archive
PureStore_CFLAGS = -fobjc-arc -I../Shared -I$(shell brew --prefix)/opt/libarchive/include
PureStore_CODESIGN_FLAGS = --entitlements entitlements.plist

include $(THEOS_MAKE_PATH)/application.mk
