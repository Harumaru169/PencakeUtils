EXECUTABLE_NAME = pencake
PREFIX = /usr/local
INSTALL_PATH = $(PREFIX)/bin/$(EXECUTABLE_NAME)
EXECUTABLE_PATH = $(shell swift build $(SWIFT_BUILD_FLAGS) --show-bin-path)/$(EXECUTABLE_NAME)

SWIFT_BUILD_FLAGS = --configuration release --arch arm64 --arch x86_64

build:
	swift build $(SWIFT_BUILD_FLAGS)

install: build
	mkdir -p $(PREFIX)/bin
	cp -f $(EXECUTABLE_PATH) $(INSTALL_PATH)

uninstall:
	rm -f $(INSTALL_PATH)

archive: build
	./Scripts/archive.swift $(EXECUTABLE_PATH)
