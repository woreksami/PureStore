TARGET := iphone:clang:16.5:14.0
INSTALL_TARGET_PROCESSES = PureStoreLite
ARCHS = arm64

include $(THEOS)/makefiles/common.mk

APPLICATION_NAME = PureStoreLite

PureStoreLite_FILES = $(wildcard ../PureStore/*.m) $(wildcard ../Shared/*.m)
PureStoreLite_FRAMEWORKS = UIKit CoreGraphics CoreServices CoreTelephony
PureStoreLite_PRIVATE_FRAMEWORKS = Preferences MobileIcons MobileContainerManager
PureStoreLite_LIBRARIES = archive
PureStoreLite_CFLAGS = -fobjc-arc -I../Shared -I$(shell brew --prefix)/opt/libarchive/include -DTROLLSTORE_LITE
PureStoreLite_CODESIGN_FLAGS = -Sentitlements.plist

include $(THEOS_MAKE_PATH)/application.mk
