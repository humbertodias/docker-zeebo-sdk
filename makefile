IMAGE=zeebo-sdk

docker/shell:
	docker run --platform=linux/amd64 --rm -it -v "$(PWD)":/src -v "$(PWD)/sdk/brew":/opt/brew $(IMAGE)

docker/build:
	docker build --platform=linux/amd64 . -t $(IMAGE)

# Unpack BREW 4.0.2 SP19 headers into sdk/brew.
# make sdk/unzip INSTALLER=/path/to/BMP_BREWPLATFORM_4.0.2.20_SETUP_0.exe
.PHONY: sdk/unzip
sdk/unzip:
	@test -n "$(INSTALLER)" || { echo 'usage: make sdk/unzip INSTALLER=/path/to/BMP_BREWPLATFORM_4.0.2.20_SETUP_0.exe'; exit 1; }
	@test -f "$(INSTALLER)" || { echo "installer not found: $(INSTALLER)"; exit 1; }
	rm -rf sdk/brew/inc sdk/brew/sdk
	7z x "$(INSTALLER)" -osdk/brew \
		"BREW 4.0.2 SP19/inc" \
		"BREW 4.0.2 SP19/sdk"
	mv "sdk/brew/BREW 4.0.2 SP19/inc" sdk/brew/inc
	mv "sdk/brew/BREW 4.0.2 SP19/sdk" sdk/brew/sdk
	rmdir "sdk/brew/BREW 4.0.2 SP19"
	test -f sdk/brew/sdk/inc/AEE.h
	test -f sdk/brew/sdk/src/AEEAppGen.c
	@echo "sdk/brew is ready"
