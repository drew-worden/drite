# Configuration
COMPILER = g++
COMPILER_FLAGS = -Wall -Wextra -std=c++23
TARGET = drite
SOURCE_DIRECTORY = src
BUILD_DIRECTORY = build
SOURCE_FILES = $(shell find $(SOURCE_DIRECTORY) -name '*.cpp')
OBJECT_FILES = $(patsubst $(SOURCE_DIRECTORY)/%.cpp,$(BUILD_DIRECTORY)/%.o,$(SOURCE_FILES))
OBJECT_DIRECTORIES = $(sort $(dir $(OBJECT_FILES)))

# Build the final executable
all: $(BUILD_DIRECTORY)/$(TARGET)

# Create build directory structure
$(OBJECT_DIRECTORIES):
	mkdir -p $@

# Compile each source file to an object file in the build directory
$(BUILD_DIRECTORY)/%.o: $(SOURCE_DIRECTORY)/%.cpp | $(OBJECT_DIRECTORIES)
	$(COMPILER) $(COMPILER_FLAGS) -c $< -o $@

# Link all object files into final executable
$(BUILD_DIRECTORY)/$(TARGET): $(OBJECT_FILES)
	$(COMPILER) $(COMPILER_FLAGS) $(OBJECT_FILES) -o $@

# Clean the build directory
clean:
	rm -rf $(BUILD_DIRECTORY)

# Run the final executable
run: $(BUILD_DIRECTORY)/$(TARGET)
	./$(BUILD_DIRECTORY)/$(TARGET)