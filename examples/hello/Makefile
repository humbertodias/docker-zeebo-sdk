# On the host this re-enters the SDK image. Inside the image the toolchain
# rules below build hello.mod and hello.mif.
IMAGE ?= hldtux/zeebo-sdk
HERE  := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))

ifeq ($(wildcard /opt/brew-toolset/bin/elf2mod.exe),)

.PHONY: all
all:
	docker run --rm --platform linux/amd64 \
		-v "$(HERE)":/src -w /src \
		$(IMAGE) \
		make $(MAKECMDGOALS)

ifneq ($(MAKECMDGOALS),)
.PHONY: $(MAKECMDGOALS)
$(MAKECMDGOALS): all
	@:
endif

else

# BREW 4.0.2 SP19 lives in the image. sdk/inc is the legacy applet API;
# headers there include /opt/brew/inc with a relative path.
BREWDIR ?= /opt/brew/sdk

CC       = arm-none-eabi-gcc
ELF2MOD  ?= wine /opt/brew-toolset/bin/elf2mod.exe
CIFC     ?= wine /opt/brew-toolset/bin/cifc.exe
LDSCRIPT ?= /opt/brew-toolset/bin/elf2mod/src/gnu/elf2mod.x

CFLAGS := -marm -march=armv6 -mtune=arm1136j-s -mfloat-abi=soft \
	-fno-short-enums -ffunction-sections -fdata-sections -Os \
	-DDYNAMIC_APP -I$(BREWDIR)/inc -I.

LDFLAGS := -nostartfiles -Wl,--entry=AEEMod_Load -Wl,--emit-relocs \
	-Wl,--default-script=$(LDSCRIPT) -Wl,--no-wchar-size-warning \
	-static-libgcc -Wl,--gc-sections

SRCS := hello.c $(BREWDIR)/src/AEEModGen.c $(BREWDIR)/src/AEEAppGen.c

.PHONY: all clean

all: hello.mod hello.mif

hello.mod: hello.elf
	$(ELF2MOD) -output $@ $<

hello.mif: hello.cif hello.bid
	$(CIFC) -I . hello.cif -mif $@

hello.elf: $(SRCS) hello.bid
	@test -f $(BREWDIR)/src/AEEAppGen.c || { echo "BREW SDK not found at $(BREWDIR)."; exit 1; }
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(SRCS)

clean:
	rm -f hello.elf hello.mod hello.mif

endif
