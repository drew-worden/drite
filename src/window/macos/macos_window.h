#pragma once

#include "window/window.h"
#include "graphics/macos/metal_graphics_context.h"
#include <memory>

#ifdef __OBJC__
@class NSWindow;
@class MTKView;
@class MacOSWindowDelegate;
@class MacOSMetalView;
#else
typedef struct objc_object NSWindow;
typedef struct objc_object MTKView;
typedef struct objc_object MacOSWindowDelegate;
typedef struct objc_object MacOSMetalView;
#endif

namespace drite {

// macOS-specific window implementation using Cocoa and Metal
class MacOSWindow : public Window {
public:
    MacOSWindow();
    ~MacOSWindow() override;

    [[nodiscard]] bool initialize(const WindowConfig& config) override;

    void show() override;
    void close() override;
    [[nodiscard]] bool shouldClose() const override;

    void getSize(int& width, int& height) const override;
    void getFramebufferSize(int& width, int& height) const override;
    void getPosition(int& x, int& y) const override;

    void setTitle(const std::string& title) override;
    void setSize(int width, int height) override;

    [[nodiscard]] bool isFocused() const override;
    [[nodiscard]] bool isMinimized() const override;

    [[nodiscard]] GraphicsContext* getGraphicsContext() override;

    void setKeyCallback(KeyCallback callback) override;
    void setMouseCallback(MouseCallback callback) override;
    void setScrollCallback(ScrollCallback callback) override;
    void setResizeCallback(ResizeCallback callback) override;
    void setCloseCallback(CloseCallback callback) override;

    // Internal methods called by delegate and view
    void handleKeyEvent(const KeyEvent& event);
    void handleMouseEvent(const MouseEvent& event);
    void handleScrollEvent(const ScrollEvent& event);
    void handleResize(int width, int height);
    void handleCloseRequest();

private:
    NSWindow* m_window{nullptr};
    MacOSMetalView* m_view{nullptr};
    MacOSWindowDelegate* m_delegate{nullptr};
    std::unique_ptr<MetalGraphicsContext> m_graphicsContext{nullptr};

    KeyCallback m_keyCallback;
    MouseCallback m_mouseCallback;
    ScrollCallback m_scrollCallback;
    ResizeCallback m_resizeCallback;
    CloseCallback m_closeCallback;

    bool m_shouldClose{false};
};

} // namespace drite
