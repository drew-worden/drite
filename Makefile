# Configuration
COMPILER = clang++
COMPILER_FLAGS = -Wall -Wextra -Werror -std=c++23 -Isrc
TARGET = drite
SOURCE_DIRECTORY = src
BUILD_DIRECTORY = build

# Source files (C++ and Objective-C++)
CPP_SOURCE_FILES = $(shell find $(SOURCE_DIRECTORY) -name '*.cpp')
MM_SOURCE_FILES = $(shell find $(SOURCE_DIRECTORY) -name '*.mm')

# Object files
CPP_OBJECT_FILES = $(patsubst $(SOURCE_DIRECTORY)/%.cpp,$(BUILD_DIRECTORY)/%.o,$(CPP_SOURCE_FILES))
MM_OBJECT_FILES = $(patsubst $(SOURCE_DIRECTORY)/%.mm,$(BUILD_DIRECTORY)/%.o,$(MM_SOURCE_FILES))
OBJECT_FILES = $(CPP_OBJECT_FILES) $(MM_OBJECT_FILES)
OBJECT_DIRECTORIES = $(sort $(dir $(OBJECT_FILES)))

# macOS Frameworks
FRAMEWORKS = -framework Cocoa -framework Metal -framework MetalKit -framework QuartzCore

# Linker flags
LINKER_FLAGS = $(FRAMEWORKS)

# Build the final executable
all: $(BUILD_DIRECTORY)/$(TARGET)

# Compile C++ source files to object files
$(BUILD_DIRECTORY)/%.o: $(SOURCE_DIRECTORY)/%.cpp
	@mkdir -p $(dir $@)
	$(COMPILER) $(COMPILER_FLAGS) -c $< -o $@

# Compile Objective-C++ source files to object files
$(BUILD_DIRECTORY)/%.o: $(SOURCE_DIRECTORY)/%.mm
	@mkdir -p $(dir $@)
	$(COMPILER) $(COMPILER_FLAGS) -c $< -o $@

# Link all object files into final executable
$(BUILD_DIRECTORY)/$(TARGET): $(OBJECT_FILES)
	$(COMPILER) $(COMPILER_FLAGS) $(OBJECT_FILES) $(LINKER_FLAGS) -o $@

# Clean the build directory
clean:
	rm -rf $(BUILD_DIRECTORY)

# Run the final executable
run: $(BUILD_DIRECTORY)/$(TARGET)
	./$(BUILD_DIRECTORY)/$(TARGET)