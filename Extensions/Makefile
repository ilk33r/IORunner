# Makefile for Extensions

include $(SOURCE_ROOT_DIR)/Extensions/MakefileSub

ext-%-install:
	@cp $(SOURCE_ROOT_DIR)/Extensions/$(*)/$(*).so $(BUILD_ROOT_DIR)/extensions/lib$(*).dylib

ext-%-modulecache:
	@mkdir -p $(MODULE_CACHE_PATH)/Extensions/$(*)

ext-%.so: ext-%-objects ext-%.swiftmodule
	$(CLANG) $($(*)_Obj) $($(*)_LFLAGS) -o $(SOURCE_ROOT_DIR)/Extensions/$(*)/$(*).so
	
ext-%.swiftmodule:
	$(SWIFT) -frontend $($(*)_SWIFTC_FLAGS) -emit-module $($(*)_Modules) \
	-parse-as-library \
	-emit-module-doc-path $(SOURCE_ROOT_DIR)/Extensions/$(*)/$(*).swiftdoc \
	-o $(SOURCE_ROOT_DIR)/Extensions/$(*)/$(*).swiftmodule

ext-%-clean:
	@rm -rf $(SOURCE_ROOT_DIR)/Extensions/$(*)/*.o $(SOURCE_ROOT_DIR)/Extensions/$(*)/*.so \
	$(SOURCE_ROOT_DIR)/Extensions/$(*)/*.swiftmodule $(SOURCE_ROOT_DIR)/Extensions/$(*)/*.swiftdoc \
	$(SOURCE_ROOT_DIR)/Extensions/$(*)/*.d $(MODULE_CACHE_PATH)/Extensions/$(*) $(BUILD_ROOT_DIR)/extensions/$(*)*
	
Extensions/%.o : Extensions/%.swift
	$(SWIFT) -frontend -c $(subst $<,,$($(notdir $(*))_Src)) -primary-file $< \
	-emit-module-path $(MODULE_CACHE_PATH)/$(subst .o,.swiftmodule,$@) \
	-emit-module-doc-path $(MODULE_CACHE_PATH)/$(subst .o,.swiftdoc,$@) \
	-emit-dependencies-path $(MODULE_CACHE_PATH)/$(subst .swift,.d,$<) \
	-emit-reference-dependencies-path $(MODULE_CACHE_PATH)/$(subst .swift,.swiftdeps,$<) \
	$($(notdir $(*))_SWIFTC_FLAGS) \
	-o $@
