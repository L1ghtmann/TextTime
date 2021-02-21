DEBUG=0
ARCHS = arm64 arm64e

INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = TextTime

TextTime_FILES = Tweak.xm
TextTime_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += texttimeprefs
include $(THEOS_MAKE_PATH)/aggregate.mk
