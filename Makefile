# ===================================================================
# Platform Detection
# ===================================================================
UNAME_S := $(shell uname -s)

ifeq ($(UNAME_S),Darwin)
    PLATFORM := macos
    PLATFORM_DISPLAY := macOS
else ifeq ($(UNAME_S),Linux)
    PLATFORM := linux
    PLATFORM_DISPLAY := Linux
else ifeq ($(OS),Windows_NT)
    PLATFORM := windows
    PLATFORM_DISPLAY := Windows
else
    $(error Unsupported platform: $(UNAME_S))
endif

# ===================================================================
# Common Configuration
# ===================================================================
TARGET = drite
APP_NAME = Drite
SOURCE_DIRECTORY = src
BUILD_DIRECTORY = build
RESOURCES_DIR = resources

# Compiler settings
CXX := clang++
CXXFLAGS := -Wall -Wextra -Werror -std=c++23 -Isrc

# ===================================================================
# Platform-Specific Configuration
# ===================================================================

# macOS Settings
ifeq ($(PLATFORM),macos)
    # Source files
    CPP_SOURCE_FILES = $(shell find $(SOURCE_DIRECTORY) -name '*.cpp')
    MM_SOURCE_FILES = $(shell find $(SOURCE_DIRECTORY) -name '*.mm')

    # Object files
    CPP_OBJECT_FILES = $(patsubst $(SOURCE_DIRECTORY)/%.cpp,$(BUILD_DIRECTORY)/%.o,$(CPP_SOURCE_FILES))
    MM_OBJECT_FILES = $(patsubst $(SOURCE_DIRECTORY)/%.mm,$(BUILD_DIRECTORY)/%.o,$(MM_SOURCE_FILES))
    OBJECT_FILES = $(CPP_OBJECT_FILES) $(MM_OBJECT_FILES)

    # Frameworks and linker flags
    FRAMEWORKS = -framework Cocoa -framework Metal -framework MetalKit -framework QuartzCore
    LDFLAGS := $(FRAMEWORKS)

    # Package settings
    APP_BUNDLE = $(BUILD_DIRECTORY)/$(APP_NAME).app
    PACKAGE_TARGET = app
    DIST_TARGET = dmg
endif

# Linux Settings
ifeq ($(PLATFORM),linux)
    # Source files (no .mm files on Linux)
    CPP_SOURCE_FILES = $(shell find $(SOURCE_DIRECTORY) -name '*.cpp' ! -path "*/macos/*")
    OBJECT_FILES = $(patsubst $(SOURCE_DIRECTORY)/%.cpp,$(BUILD_DIRECTORY)/%.o,$(CPP_SOURCE_FILES))

    # Libraries
    LDFLAGS := -lX11 -lGL -lvulkan

    # Package settings
    PACKAGE_TARGET = linux-package
    DIST_TARGET = deb
endif

# Windows Settings
ifeq ($(PLATFORM),windows)
    # Source files (no .mm files on Windows)
    CPP_SOURCE_FILES = $(shell find $(SOURCE_DIRECTORY) -name '*.cpp' ! -path "*/macos/*")
    OBJECT_FILES = $(patsubst $(SOURCE_DIRECTORY)/%.cpp,$(BUILD_DIRECTORY)/%.o,$(CPP_SOURCE_FILES))

    # Libraries
    LDFLAGS := -lgdi32 -ld3d12

    # Package settings
    PACKAGE_TARGET = windows-package
    DIST_TARGET = installer
endif

# ===================================================================
# Build Targets
# ===================================================================

# Default target
all: $(BUILD_DIRECTORY)/$(TARGET)
	@echo "Built $(TARGET) for $(PLATFORM_DISPLAY)"

# Compile C++ source files
$(BUILD_DIRECTORY)/%.o: $(SOURCE_DIRECTORY)/%.cpp
	@mkdir -p $(dir $@)
	@echo "Compiling $<..."
	@$(CXX) $(CXXFLAGS) -c $< -o $@

# Compile Objective-C++ source files (macOS only)
ifeq ($(PLATFORM),macos)
$(BUILD_DIRECTORY)/%.o: $(SOURCE_DIRECTORY)/%.mm
	@mkdir -p $(dir $@)
	@echo "Compiling $<..."
	@$(CXX) $(CXXFLAGS) -c $< -o $@
endif

# Link executable
$(BUILD_DIRECTORY)/$(TARGET): $(OBJECT_FILES)
	@echo "Linking $(TARGET)..."
	@$(CXX) $(CXXFLAGS) $(OBJECT_FILES) $(LDFLAGS) -o $@

# ===================================================================
# Platform-Specific Package Targets
# ===================================================================

# macOS: Create .app bundle
ifeq ($(PLATFORM),macos)
app: $(APP_BUNDLE)

$(APP_BUNDLE): $(BUILD_DIRECTORY)/$(TARGET)
	@echo "Creating macOS app bundle..."
	@mkdir -p $(APP_BUNDLE)/Contents/MacOS
	@mkdir -p $(APP_BUNDLE)/Contents/Resources
	@mkdir -p $(APP_BUNDLE)/Contents/Resources/bin
	@cp $(BUILD_DIRECTORY)/$(TARGET) $(APP_BUNDLE)/Contents/MacOS/$(TARGET)
	@cp $(RESOURCES_DIR)/macos/Info.plist $(APP_BUNDLE)/Contents/Info.plist
	@cp $(RESOURCES_DIR)/macos/drite-cli $(APP_BUNDLE)/Contents/Resources/bin/drite
	@chmod +x $(APP_BUNDLE)/Contents/Resources/bin/drite
	@if [ -f "$(RESOURCES_DIR)/macos/AppIcon.icns" ]; then \
		cp "$(RESOURCES_DIR)/macos/AppIcon.icns" $(APP_BUNDLE)/Contents/Resources/AppIcon.icns; \
		echo "Icon copied to app bundle"; \
	else \
		echo "Warning: AppIcon.icns not found at $(RESOURCES_DIR)/macos/AppIcon.icns"; \
		echo "Run 'make icon' to generate it"; \
	fi
	@echo "App bundle created: $(APP_BUNDLE)"

# Generate icon from source PNG (macOS only)
icon:
	@echo "Generating macOS icon..."
	@if [ -f $(RESOURCES_DIR)/icon.png ]; then \
		cd $(RESOURCES_DIR)/macos && ./generate_icon.sh ../icon.png; \
	else \
		echo "Error: $(RESOURCES_DIR)/icon.png not found"; \
		exit 1; \
	fi

# Create DMG for distribution
dmg: app
	@echo "Creating DMG..."
	@mkdir -p $(BUILD_DIRECTORY)/dmg
	@cp -r $(APP_BUNDLE) $(BUILD_DIRECTORY)/dmg/
	@cp "$(RESOURCES_DIR)/macos/Install CLI Tool.command" $(BUILD_DIRECTORY)/dmg/
	@ln -sf /Applications $(BUILD_DIRECTORY)/dmg/Applications
	@hdiutil create -volname "$(APP_NAME)" -srcfolder $(BUILD_DIRECTORY)/dmg \
		-ov -format UDZO $(BUILD_DIRECTORY)/$(APP_NAME).dmg
	@rm -rf $(BUILD_DIRECTORY)/dmg
	@echo "DMG created: $(BUILD_DIRECTORY)/$(APP_NAME).dmg"

# Install to /Applications and CLI to /usr/local/bin
install: app
	@echo "Installing to /Applications..."
	@rm -rf /Applications/$(APP_NAME).app
	@cp -r $(APP_BUNDLE) /Applications/
	@echo "Installing CLI tool to /usr/local/bin (requires sudo)..."
	@sudo mkdir -p /usr/local/bin
	@sudo cp $(RESOURCES_DIR)/macos/drite-cli /usr/local/bin/drite
	@sudo chmod +x /usr/local/bin/drite
	@echo "Refreshing icon cache and Launch Services database..."
	@touch /Applications/$(APP_NAME).app
	@/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f /Applications/$(APP_NAME).app
	@killall Dock 2>/dev/null || true
	@echo ""
	@echo "✓ Installed $(APP_NAME).app to /Applications"
	@echo "✓ Installed 'drite' command to /usr/local/bin"
	@echo ""
	@echo "You can now run 'drite' from the command line!"
	@echo "Note: Dock has been restarted to refresh the icon"

# Uninstall from /Applications and remove CLI
uninstall:
	@echo "Uninstalling from /Applications..."
	@rm -rf /Applications/$(APP_NAME).app
	@echo "Removing CLI tool from /usr/local/bin (requires sudo)..."
	@sudo rm -f /usr/local/bin/drite
	@echo ""
	@echo "✓ Uninstalled $(APP_NAME).app"
	@echo "✓ Removed 'drite' command"
endif

# Linux: Create package structure
ifeq ($(PLATFORM),linux)
linux-package: $(BUILD_DIRECTORY)/$(TARGET)
	@echo "Creating Linux package structure..."
	@mkdir -p $(BUILD_DIRECTORY)/package/usr/bin
	@mkdir -p $(BUILD_DIRECTORY)/package/usr/share/applications
	@mkdir -p $(BUILD_DIRECTORY)/package/usr/share/icons/hicolor/256x256/apps
	@cp $(BUILD_DIRECTORY)/$(TARGET) $(BUILD_DIRECTORY)/package/usr/bin/
	@echo "Linux package structure created"

# Create .deb package
deb: linux-package
	@echo "Creating .deb package..."
	@echo "TODO: Implement .deb packaging"

# Install to system
install: $(BUILD_DIRECTORY)/$(TARGET)
	@echo "Installing to /usr/local/bin..."
	@sudo cp $(BUILD_DIRECTORY)/$(TARGET) /usr/local/bin/
	@echo "Installed $(TARGET)"

uninstall:
	@echo "Uninstalling from /usr/local/bin..."
	@sudo rm -f /usr/local/bin/$(TARGET)
	@echo "Uninstalled $(TARGET)"
endif

# Windows: Create package structure
ifeq ($(PLATFORM),windows)
windows-package: $(BUILD_DIRECTORY)/$(TARGET)
	@echo "Creating Windows package structure..."
	@mkdir -p $(BUILD_DIRECTORY)/package
	@cp $(BUILD_DIRECTORY)/$(TARGET) $(BUILD_DIRECTORY)/package/
	@echo "Windows package structure created"

installer: windows-package
	@echo "Creating Windows installer..."
	@echo "TODO: Implement NSIS or WiX installer"
endif

# ===================================================================
# Common Targets
# ===================================================================

# Package for current platform
package: $(PACKAGE_TARGET)

# Create distribution package
dist: $(DIST_TARGET)

# Run the executable
run: $(BUILD_DIRECTORY)/$(TARGET)
	@echo "Running $(TARGET)..."
	@./$(BUILD_DIRECTORY)/$(TARGET)

# Run the packaged application
ifeq ($(PLATFORM),macos)
run-package: app
	@echo "Running $(APP_NAME).app..."
	@open $(APP_BUNDLE)
else
run-package: $(BUILD_DIRECTORY)/$(TARGET)
	@echo "Running $(TARGET)..."
	@./$(BUILD_DIRECTORY)/$(TARGET)
endif

# Clean build artifacts
clean:
	@echo "Cleaning build directory..."
	@rm -rf $(BUILD_DIRECTORY)
	@echo "Clean complete"

# Display build information
info:
	@echo "Build Configuration:"
	@echo "  Platform:     $(PLATFORM_DISPLAY)"
	@echo "  Compiler:     $(CXX)"
	@echo "  Target:       $(TARGET)"
	@echo "  Source Dir:   $(SOURCE_DIRECTORY)"
	@echo "  Build Dir:    $(BUILD_DIRECTORY)"
	@echo "  Package Type: $(PACKAGE_TARGET)"
	@echo "  Dist Type:    $(DIST_TARGET)"

# Help target
help:
	@echo "Drite Editor - Build System"
	@echo ""
	@echo "Platform: $(PLATFORM_DISPLAY)"
	@echo ""
	@echo "Common Targets:"
	@echo "  make              - Build the executable"
	@echo "  make run          - Build and run the executable"
	@echo "  make package      - Create platform package"
	@echo "  make dist         - Create distribution package"
	@echo "  make install      - Install to system"
	@echo "  make uninstall    - Uninstall from system"
	@echo "  make clean        - Remove build artifacts"
	@echo "  make info         - Display build configuration"
	@echo "  make help         - Show this help message"
	@echo ""
ifeq ($(PLATFORM),macos)
	@echo "macOS-Specific Targets:"
	@echo "  make app          - Create .app bundle"
	@echo "  make dmg          - Create .dmg installer"
	@echo "  make icon         - Generate app icon from assets/icon.png"
	@echo "  make run-package  - Run the .app bundle"
	@echo ""
endif
ifeq ($(PLATFORM),linux)
	@echo "Linux-Specific Targets:"
	@echo "  make linux-package - Create package structure"
	@echo "  make deb          - Create .deb package"
	@echo ""
endif
ifeq ($(PLATFORM),windows)
	@echo "Windows-Specific Targets:"
	@echo "  make windows-package - Create package structure"
	@echo "  make installer    - Create Windows installer"
	@echo ""
endif

.PHONY: all package dist run run-package clean info help install uninstall

ifeq ($(PLATFORM),macos)
.PHONY: app icon dmg
endif

ifeq ($(PLATFORM),linux)
.PHONY: linux-package deb
endif

ifeq ($(PLATFORM),windows)
.PHONY: windows-package installer
endif
