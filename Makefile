
MODULE_NAME=$(notdir $(shell pwd))

SRCS=$(wildcard $(shell pwd)/Source/*.swift)

BUILD="build/"

DEVICE_SDK_PATH=`xcrun --sdk iphoneos --show-sdk-path`
DEVICE_TARGET="arm64-apple-ios7.1"
DEVICE_TARGET2="armv7-apple-ios7.1"
SIMULATOR_SDK_PATH=`xcrun --sdk iphonesimulator --show-sdk-path`
SIMULATOR_TARGET="x86_64-apple-ios7.1"
SIMULATOR_TARGET2="i386-apple-ios7.1"

all: lib$(MODULE_NAME).a modules

objs: $(SRCS)
	mkdir -p $(BUILD)$(DEVICE_TARGET)-out/
	mkdir -p $(BUILD)$(DEVICE_TARGET2)-out/
	mkdir -p $(BUILD)$(SIMULATOR_TARGET)-out/
	mkdir -p $(BUILD)$(SIMULATOR_TARGET2)-out/
	cd $(BUILD)$(DEVICE_TARGET)-out/ && xcrun swiftc -emit-library -emit-object $^ -sdk $(DEVICE_SDK_PATH) -target $(DEVICE_TARGET) -module-name $(MODULE_NAME)
	cd $(BUILD)$(DEVICE_TARGET2)-out/ && xcrun swiftc -emit-library -emit-object $^ -sdk $(DEVICE_SDK_PATH) -target $(DEVICE_TARGET2) -module-name $(MODULE_NAME)
	cd $(BUILD)$(SIMULATOR_TARGET)-out/ && xcrun swiftc -emit-library -emit-object $^ -sdk $(SIMULATOR_SDK_PATH) -target $(SIMULATOR_TARGET)-out/ -module-name $(MODULE_NAME)
	cd $(BUILD)$(SIMULATOR_TARGET2)-out/ && xcrun swiftc -emit-library -emit-object $^ -sdk $(SIMULATOR_SDK_PATH) -target $(SIMULATOR_TARGET2)-out/ -module-name $(MODULE_NAME)

$(BUILD)lib$(MODULE_NAME)-$(DEVICE_TARGET).a: objs
	ar rcs $@ $(BUILD)$(DEVICE_TARGET)-out/*.o

$(BUILD)lib$(MODULE_NAME)-$(SIMULATOR_TARGET).a: objs
	ar rcs $@ $(BUILD)$(SIMULATOR_TARGET)-out/*.o

$(BUILD)lib$(MODULE_NAME)-$(SIMULATOR_TARGET2).a: objs
	ar rcs $@ $(BUILD)$(SIMULATOR_TARGET2)-out/*.o

$(BUILD)lib$(MODULE_NAME)-$(DEVICE_TARGET2).a: objs
	ar rcs $@ $(BUILD)$(DEVICE_TARGET2)-out/*.o

lib$(MODULE_NAME).a: $(BUILD)lib$(MODULE_NAME)-$(DEVICE_TARGET).a $(BUILD)lib$(MODULE_NAME)-$(DEVICE_TARGET2).a $(BUILD)lib$(MODULE_NAME)-$(SIMULATOR_TARGET).a $(BUILD)lib$(MODULE_NAME)-$(SIMULATOR_TARGET2).a
	lipo -create $^ -output $(BUILD)$@

modules: $(SRCS)
		#cd $(BUILD)$(DEVICE_TARGET)-out/ && xcrun swiftc -emit-module $(SRCS) -sdk $(DEVICE_SDK_PATH) -target $(DEVICE_TARGET) -module-name $(MODULE_NAME)
		#cd $(BUILD)$(DEVICE_TARGET2)-out/ && xcrun swiftc -emit-module $(SRCS) -sdk $(DEVICE_SDK_PATH) -target $(DEVICE_TARGET2) -module-name $(MODULE_NAME)
		#cd $(BUILD)$(SIMULATOR_TARGET)-out/ && xcrun swiftc -emit-module $(SRCS) -sdk $(DEVICE_SDK_PATH) -target $(SIMULATOR_TARGET) -module-name $(MODULE_NAME)
		#cd $(BUILD)$(SIMULATOR_TARGET2)-out/ && xcrun swiftc -emit-module $(SRCS) -sdk $(DEVICE_SDK_PATH) -target $(SIMULATOR_TARGET2) -module-name $(MODULE_NAME)
	xcrun swiftc -emit-module $(SRCS) -sdk $(SIMULATOR_SDK_PATH) -target $(SIMULATOR_TARGET) -module-name $(MODULE_NAME) #-o $(BUILD) #NOTE: using -o omits the *.swiftdoc for some reason
	mv $(MODULE_NAME).swiftmodule $(BUILD)
	mv $(MODULE_NAME).swiftdoc $(BUILD)

clean:
	rm -rf $(BUILD)

install:
	mkdir -p ../../apps/Roll/$(MODULE_NAME)
	cp $(BUILD)/lib$(MODULE_NAME).a ../../apps/Roll/$(MODULE_NAME)
	cp $(BUILD)/$(MODULE_NAME).swiftdoc ../../apps/Roll/$(MODULE_NAME)
	cp $(BUILD)/$(MODULE_NAME).swiftmodule ../../apps/Roll/$(MODULE_NAME)

