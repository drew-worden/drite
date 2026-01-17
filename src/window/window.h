#pragma once

#include "graphics/graphics_context.h"
#include "input/input_types.h"
#include <functional>
#include <memory>
#include <string>

namespace drite {

// Window configuration structure
struct WindowConfig {
    std::string title = "Drite";
    int width = 1280;
    int height = 720;
    bool resizable = true;
    bool vsync = true;
};

// Window abstraction layer - handles OS-specific window management,
// input events, and graphics context creation
class Window {
public:
    virtual ~Window() = default;

    // Initialize the window with given configuration
    [[nodiscard]] virtual bool initialize(const WindowConfig& config) = 0;

    // Show the window
    virtual void show() = 0;

    // Close the window
    virtual void close() = 0;

    // Check if window should close
    [[nodiscard]] virtual bool shouldClose() const = 0;

    // Get window dimensions
    virtual void getSize(int& width, int& height) const = 0;
    virtual void getFramebufferSize(int& width, int& height) const = 0;

    // Get window position
    virtual void getPosition(int& x, int& y) const = 0;

    // Set window properties
    virtual void setTitle(const std::string& title) = 0;
    virtual void setSize(int width, int height) = 0;

    // Check window state
    [[nodiscard]] virtual bool isFocused() const = 0;
    [[nodiscard]] virtual bool isMinimized() const = 0;

    // Get graphics context
    [[nodiscard]] virtual GraphicsContext* getGraphicsContext() = 0;

    // Event callbacks
    using KeyCallback = std::function<void(const KeyEvent&)>;
    using MouseCallback = std::function<void(const MouseEvent&)>;
    using ScrollCallback = std::function<void(const ScrollEvent&)>;
    using ResizeCallback = std::function<void(int width, int height)>;
    using CloseCallback = std::function<void()>;

    virtual void setKeyCallback(KeyCallback callback) = 0;
    virtual void setMouseCallback(MouseCallback callback) = 0;
    virtual void setScrollCallback(ScrollCallback callback) = 0;
    virtual void setResizeCallback(ResizeCallback callback) = 0;
    virtual void setCloseCallback(CloseCallback callback) = 0;
};

} // namespace drite
