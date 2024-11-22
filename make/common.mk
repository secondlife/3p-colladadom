ifeq ($(os),ps3)
cc := ppu-lv2-g++
ar := ppu-lv2-ar rcs
exeSuffix := .elf
else
cc := $(CXX)
ar := ar rcs
exeSuffix :=
endif

# Put -Wall at the *front* of the ccFlags list. That way if CXXFLAGS specifies
# any -Wno-something warning suppression flags, they won't be overridden.
ccFlags := -Wall $(CXXFLAGS)
ifeq ($(conf),debug)
ccFlags += -g -D_DEBUG
debugSuffix := -d
else
ccFlags += -O3 -DNDEBUG
debugSuffix :=
endif

ifeq ($(arch),x86_64)
archsupport := -x64
else ifeq ($(arch),arm64)
archsupport := -a64
else
archsupport :=
endif

ifeq ($(os),mac)
# Add the -arch flags to specify what architectures we're building for.
ccFlags += $(addprefix -arch ,$(archs))
endif

libOpts := $(LDFLAGS)
ifeq ($(os),windows)
# In case we're using the Cygwin compiler/linker, instruct cygwin to use the
# MinGW compiler to get a native Windows build. If you actually want a
# Cygwin-ized build you should comment this out.
ccFlags += -mno-cygwin
libOpts += -mno-cygwin
endif

ifeq ($(os),linux)
#enforce 32-bit builds, even when building on 64-bit machines
## no, don't - nat 2016-03-29
##ccFlags += -m32
endif

ifeq ($(colladaVersion),1.4)
ccFlags += -DCOLLADA14
endif
ifeq ($(colladaVersion),1.5)
ccFlags += -DCOLLADA15
endif

# Clear out a bunch of variables that may have previously been set
src :=
targets :=
includeOpts :=
sharedLibSearchPaths :=
dependentLibs :=
postCreateExeCommand :=

buildID := $(os)
ifeq ($(os),windows)
buildID := mingw
endif

outPath := build/$(buildID)-$(colladaVersion)$(if $(findstring debug,$(conf)),$(debugSuffix))/
objPath := $(outPath)obj/
colladaVersionNoDots := $(subst .,,$(colladaVersion))
xmlparsers := $(if $(findstring ps3,$(os)),tinyxml,$(parsers))

