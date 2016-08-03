# Makefile for Extensions

include $(SOURCE_ROOT_DIR)/Extensions/TestHandler/Makefile

$(ExtensionName)-install:
	@cp $(SOURCE_ROOT_DIR)/Extensions/$(ExtensionName)/$(ExtensionName).so $(BUILD_ROOT_DIR)/extensions/lib$(ExtensionName).dylib

$(ExtensionName)-modulecache:
	@mkdir -p $(MODULE_CACHE_PATH)/Extensions/$(ExtensionName)
	
ExtensionMake: $(ExtensionName)-modulecache $(ExtensionName).so $(ExtensionName)-install
	
$(ExtensionName).so: $($(ExtensionName)_Obj) $(ExtensionName).swiftmodule
	$(CLANG) $($(ExtensionName)_Obj) $($(ExtensionName)_LFLAGS) -o $(SOURCE_ROOT_DIR)/Extensions/$(ExtensionName)/$(ExtensionName).so
	
$(ExtensionName).swiftmodule:
	$(SWIFT) -frontend $($(ExtensionName)_SWIFTC_FLAGS) -emit-module $($(ExtensionName)_Modules) \
	-parse-as-library \
	-emit-module-doc-path $(SOURCE_ROOT_DIR)/Extensions/$(ExtensionName)/$(ExtensionName).swiftdoc \
	-o $(SOURCE_ROOT_DIR)/Extensions/$(ExtensionName)/$(ExtensionName).swiftmodule

ExtensionClean:
	@rm -rf $(SOURCE_ROOT_DIR)/Extensions/$(ExtensionName)/*.o $(SOURCE_ROOT_DIR)/Extensions/$(ExtensionName)/*.so \
	$(SOURCE_ROOT_DIR)/Extensions/$(ExtensionName)/*.swiftmodule $(SOURCE_ROOT_DIR)/Extensions/$(ExtensionName)/*.swiftdoc \
	$(SOURCE_ROOT_DIR)/Extensions/$(ExtensionName)/*.d $(MODULE_CACHE_PATH)/Extensions/$(ExtensionName) $(BUILD_ROOT_DIR)/extensions/$(ExtensionName)*
	
Extensions-dist:
	@cp -r $(BUILD_ROOT_DIR)/extensions/*.dylib $(BUILD_ROOT_DIR)/dist/lib/extensions/available

AllExtensions-Clean: 
	@eval make ExtensionClean ExtensionName=TestHandler
	
Extensions/$(ExtensionName)/%.o : Extensions/$(ExtensionName)/%.swift
	$(SWIFT) -frontend -c $(subst $<,,$($(ExtensionName)_Src)) -primary-file $< \
	-emit-module-path $(MODULE_CACHE_PATH)/$(subst .o,.swiftmodule,$@) \
	-emit-module-doc-path $(MODULE_CACHE_PATH)/$(subst .o,.swiftdoc,$@) \
	-emit-dependencies-path $(MODULE_CACHE_PATH)/$(subst .swift,.d,$<) \
	-emit-reference-dependencies-path $(MODULE_CACHE_PATH)/$(subst .swift,.swiftdeps,$<) \
	$($(ExtensionName)_SWIFTC_FLAGS) \
	-o $@

AllExtensions:
	$(eval TEST_HANDLER_EXISTS := $(shell [ -e $(BUILD_ROOT_DIR)/extensions/libTestHandler.dylib ] && echo 1 || echo 0 ))
	@if [ $(TEST_HANDLER_EXISTS) = 0 ]; then\
		eval make ExtensionMake ExtensionName=TestHandler; \
	fi