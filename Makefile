TOPTARGETS := all clean update

$(TOPTARGETS): pre_build make_roothelper make_purestore make_trollhelper_embedded make_trollhelper_package assemble_purestore build_installer15 build_installer64e make_purestore_lite

pre_build:
	@rm -rf ./_build 2>/dev/null || true
	@mkdir -p ./_build

make_fastPathSign:
	@echo "Skipping fastPathSign (incompatible with current ChOma version)"

make_roothelper:
	@$(MAKE) -C ./RootHelper DEBUG=0 $(MAKECMDGOALS)

make_purestore:
	@$(MAKE) -C ./PureStore FINALPACKAGE=1 $(MAKECMDGOALS)

ifneq ($(MAKECMDGOALS),clean)

make_trollhelper_package:
	@$(MAKE) clean -C ./PureHelper
	@cp ./RootHelper/.theos/obj/purestorehelper ./PureHelper/Resources/purestorehelper
	@$(MAKE) -C ./PureHelper FINALPACKAGE=1 package $(MAKECMDGOALS)
	@$(MAKE) clean -C ./PureHelper
	@$(MAKE) -C ./PureHelper THEOS_PACKAGE_SCHEME=rootless FINALPACKAGE=1 package $(MAKECMDGOALS)
	@rm ./PureHelper/Resources/purestorehelper

make_trollhelper_embedded:
	@$(MAKE) clean -C ./PureHelper
	@$(MAKE) -C ./PureHelper FINALPACKAGE=1 EMBEDDED_ROOT_HELPER=1 $(MAKECMDGOALS)
	@cp ./PureHelper/.theos/obj/PureStorePersistenceHelper.app/PureStorePersistenceHelper ./_build/PersistenceHelper_Embedded
	@$(MAKE) clean -C ./PureHelper
	@$(MAKE) -C ./PureHelper FINALPACKAGE=1 EMBEDDED_ROOT_HELPER=1 LEGACY_CT_BUG=1 $(MAKECMDGOALS)
	@cp ./PureHelper/.theos/obj/PureStorePersistenceHelper.app/PureStorePersistenceHelper ./_build/PersistenceHelper_Embedded_Legacy_arm64
	@$(MAKE) clean -C ./PureHelper
	@$(MAKE) -C ./PureHelper FINALPACKAGE=1 EMBEDDED_ROOT_HELPER=1 CUSTOM_ARCHS=arm64e $(MAKECMDGOALS)
	@cp ./PureHelper/.theos/obj/PureStorePersistenceHelper.app/PureStorePersistenceHelper ./_build/PersistenceHelper_Embedded_Legacy_arm64e
	@$(MAKE) clean -C ./PureHelper

assemble_purestore:
	@cp ./RootHelper/.theos/obj/purestorehelper ./PureStore/.theos/obj/PureStore.app/purestorehelper
	@cp ./PureHelper/.theos/obj/PureStorePersistenceHelper.app/PureStorePersistenceHelper ./PureStore/.theos/obj/PureStore.app/PersistenceHelper
	@export COPYFILE_DISABLE=1
	@tar -czvf ./_build/PureStore.tar -C ./PureStore/.theos/obj PureStore.app

build_installer15:
	@mkdir -p ./_build/tmp15
	@unzip ./Victim/InstallerVictim.ipa -d ./_build/tmp15
	@cp ./_build/PersistenceHelper_Embedded_Legacy_arm64 ./_build/PureStorePersistenceHelperToInject
	@pwnify set-cpusubtype ./_build/PureStorePersistenceHelperToInject 1
	@ldid -s -K./Victim/victim.p12 ./_build/PureStorePersistenceHelperToInject
	APP_PATH=$$(find ./_build/tmp15/Payload -name "*" -depth 1) ; \
	APP_NAME=$$(basename $$APP_PATH) ; \
	BINARY_NAME=$$(echo "$$APP_NAME" | cut -f 1 -d '.') ; \
	echo $$BINARY_NAME ; \
	pwnify pwn ./_build/tmp15/Payload/$$APP_NAME/$$BINARY_NAME ./_build/PureStorePersistenceHelperToInject
	@pushd ./_build/tmp15 ; \
	zip -vrD ../../_build/PureHelper_iOS15.ipa * ; \
	popd
	@rm ./_build/PureStorePersistenceHelperToInject
	@rm -rf ./_build/tmp15

build_installer64e:
	@mkdir -p ./_build/tmp64e
	@unzip ./Victim/InstallerVictim.ipa -d ./_build/tmp64e
	APP_PATH=$$(find ./_build/tmp64e/Payload -name "*" -depth 1) ; \
	APP_NAME=$$(basename $$APP_PATH) ; \
	BINARY_NAME=$$(echo "$$APP_NAME" | cut -f 1 -d '.') ; \
	echo $$BINARY_NAME ; \
	pwnify pwn64e ./_build/tmp64e/Payload/$$APP_NAME/$$BINARY_NAME ./_build/PersistenceHelper_Embedded_Legacy_arm64e
	@pushd ./_build/tmp64e ; \
	zip -vrD ../../_build/PureHelper_arm64e.ipa * ; \
	popd
	@rm -rf ./_build/tmp64e

make_purestore_lite:
	@$(MAKE) -C ./RootHelper DEBUG=0 TROLLSTORE_LITE=1
	@rm -rf ./PureStoreLite/Resources/purestorehelper
	@cp ./RootHelper/.theos/obj/purestorehelper_lite ./PureStoreLite/Resources/purestorehelper
	@$(MAKE) -C ./PureStoreLite package FINALPACKAGE=1
	@$(MAKE) -C ./RootHelper TROLLSTORE_LITE=1 clean
	@$(MAKE) -C ./PureStoreLite clean
	@$(MAKE) -C ./RootHelper DEBUG=0 TROLLSTORE_LITE=1 THEOS_PACKAGE_SCHEME=rootless
	@rm -rf ./PureStoreLite/Resources/purestorehelper
	@cp ./RootHelper/.theos/obj/purestorehelper_lite ./PureStoreLite/Resources/purestorehelper
	@$(MAKE) -C ./PureStoreLite package FINALPACKAGE=1 THEOS_PACKAGE_SCHEME=rootless

else
make_purestore_lite:
	@$(MAKE) -C ./PureStoreLite $(MAKECMDGOALS)
endif

.PHONY: $(TOPTARGETS) pre_build assemble_purestore make_trollhelper_package make_trollhelper_embedded build_installer15 build_installer64e