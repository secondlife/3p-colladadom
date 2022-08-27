include make/common.mk

src := $(wildcard src/dae/*.cpp)

src += src/modules/stdErrPlugin/stdErrPlugin.cpp \
       src/modules/STLDatabase/daeSTLDatabase.cpp \
       src/modules/LIBXMLPlugin/daeLIBXMLPlugin.cpp \

src += $(wildcard src/$(colladaVersion)/dom/*.cpp)

includeOpts := -Istage/packages/include \
	-Istage/packages/include/zlib-ng \
	-Istage/packages/include/pcre \
	-Istage/packages/include/libxml2 \
	-Istage/packages/include/minizip-ng \
	-Iinclude \
	-Iinclude/$(colladaVersion)

# Favor autobuild dependencies
libOpts += -Lstage/packages/lib/$(conf)/

ifneq ($(findstring $(os),linux mac),)
ccFlags += -fPIC
else 
ifeq ($(os),windows)
ccFlags += -DDOM_DYNAMIC -DDOM_EXPORT
endif
endif

ifneq ($(findstring libxml,$(xmlparsers)),)
ccFlags += -DDOM_INCLUDE_LIBXML
ifeq ($(os),windows)
libOpts += -lxml2 -lws2_32 -lz
else
ifeq ($(os),linux)
libOpts += -lxml2
else
libOpts += -lxml2 -liconv
endif
endif
endif

ifneq ($(findstring tinyxml,$(xmlparsers)),)
ccFlags += -DDOM_INCLUDE_TINYXML
includeOpts += -Iexternal-libs/tinyxml/
libOpts += external-libs/tinyxml/lib/$(buildID)/libtinyxml.a
endif

# On Mac, Windows and PS3 we need to be told where to find pcre
ifeq ($(os),windows)
ccFlags += -DPCRE_STATIC
else
includeOpts += -Istage/packages/include/pcre
libOpts += $(addprefix stage/packages/lib/release/,libpcrecpp.a libpcre.a )
endif

# For mingw: add boost
ifneq ($(findstring $(os),linux mac),)
includeOpts += -Istage/packages/include
ifeq ($(conf),debug)
debug_suffix = "-d"
else
debug_suffix = ""
endif
# Boost 1.72 delivers libboost_[file]system-mt-x64.a, and we're getting link
# errors about missing libboost_[file]system-mt.a. Hence $(archsupport).
libOpts += stage/packages/lib/$(conf)/libboost_system-mt$(archsupport)$(debug_suffix).a
libOpts += stage/packages/lib/$(conf)/libboost_filesystem-mt$(archsupport)$(debug_suffix).a 
endif

# minizip
libOpts += -lminizip
# as we link minizip static on osx, we need to link against zlib, too.
ifneq ($(findstring $(os),linux mac),)
libOpts += -lz
endif

# output
libName := libcollada$(colladaVersionNoDots)dom$(debugSuffix)
libVersion := $(domVersion)
libVersionNoDots := $(subst .,,$(libVersion))

targets :=
ifeq ($(os),linux)
# On Linux we build a static lib and a shared lib
targets += $(addprefix $(outPath),$(libName).a)
targets += $(addprefix $(outPath),$(libName).so)

else 
ifeq ($(os),windows)
# On Windows we build a static lib and a DLL
windowsLibName := libcollada$(colladaVersionNoDots)dom
targets += $(addprefix $(outPath),$(windowsLibName)$(debugSuffix).a)
targets += $(addprefix $(outPath),$(windowsLibName)$(libVersionNoDots)$(debugSuffix).dll)

else 
ifeq ($(os),mac)
# On Mac we build an archive and a framework
targets += $(addprefix $(outPath),libcollada$(colladaVersionNoDots)dom$(debugSuffix).a)
targets += $(addprefix $(outPath),libcollada$(colladaVersionNoDots)dom$(debugSuffix).framework)
frameworkHeadersPath = $(framework)/Versions/$(libVersion)/Headers
copyFrameworkHeadersCommand = cp -R include/* $(frameworkHeadersPath) && \
  mv $(frameworkHeadersPath)/$(colladaVersion)/dom $(frameworkHeadersPath)/dom && \
  find -E $(frameworkHeadersPath) -maxdepth 1 -type d -regex '.*[0-9]+\.[0-9]+' | xargs rm -r
frameworkResourcesPath = $(framework)/Versions/$(libVersion)/Resources
sedReplaceExpression := -e 's/(colladaVersionNoDots)/$(colladaVersionNoDots)/g' \
                        -e 's/(domVersion)/$(domVersion)/g' \
                        -e 's/(debugSuffix)/$(debugSuffix)/g'
copyFrameworkResourcesCommand = cp -R make/macFrameworkResources/* $(frameworkResourcesPath) && \
  sed $(sedReplaceExpression) make/macFrameworkResources/Info.plist > $(frameworkResourcesPath)/Info.plist && \
  sed $(sedReplaceExpression) make/macFrameworkResources/English.lproj/InfoPlist.strings > $(frameworkResourcesPath)/English.lproj/InfoPlist.strings

else 
ifeq ($(os),ps3)
# On PS3 we build a static lib, since PS3 doesn't support shared libs
targets += $(addprefix $(outPath),$(libName).a)
endif
endif
endif
endif

ifeq ($(os),ps3)
# PS3 doesn't support C++ locales, so tell boost not to use them
ccFlags += -DBOOST_NO_STD_LOCALE -DNO_BOOST -DNO_ZAE
endif

include make/rules.mk
