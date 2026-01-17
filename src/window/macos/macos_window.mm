#import "window/macos/macos_window.h"
#import <Cocoa/Cocoa.h>
#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>

namespace drite {
    class MacOSWindow;
}

// Custom MTKView subclass
@interface MacOSMetalView : MTKView {
    drite::MacOSWindow* window;
}
- (id)initWithFrame:(NSRect)frame window:(drite::MacOSWindow*)win;
@end

// Window delegate
@interface MacOSWindowDelegate : NSObject<NSWindowDelegate> {
    drite::MacOSWindow* window;
}
- (id)initWithWindow:(drite::MacOSWindow*)win;
@end

namespace drite {

// Key code conversion
static KeyCode convertKeyCode(unsigned short keyCode) {
    switch (keyCode) {
        case 0x00: return KeyCode::A;
        case 0x0B: return KeyCode::B;
        case 0x08: return KeyCode::C;
        case 0x02: return KeyCode::D;
        case 0x0E: return KeyCode::E;
        case 0x03: return KeyCode::F;
        case 0x05: return KeyCode::G;
        case 0x04: return KeyCode::H;
        case 0x22: return KeyCode::I;
        case 0x26: return KeyCode::J;
        case 0x28: return KeyCode::K;
        case 0x25: return KeyCode::L;
        case 0x2E: return KeyCode::M;
        case 0x2D: return KeyCode::N;
        case 0x1F: return KeyCode::O;
        case 0x23: return KeyCode::P;
        case 0x0C: return KeyCode::Q;
        case 0x0F: return KeyCode::R;
        case 0x01: return KeyCode::S;
        case 0x11: return KeyCode::T;
        case 0x20: return KeyCode::U;
        case 0x09: return KeyCode::V;
        case 0x0D: return KeyCode::W;
        case 0x07: return KeyCode::X;
        case 0x10: return KeyCode::Y;
        case 0x06: return KeyCode::Z;

        case 0x1D: return KeyCode::Num0;
        case 0x12: return KeyCode::Num1;
        case 0x13: return KeyCode::Num2;
        case 0x14: return KeyCode::Num3;
        case 0x15: return KeyCode::Num4;
        case 0x17: return KeyCode::Num5;
        case 0x16: return KeyCode::Num6;
        case 0x1A: return KeyCode::Num7;
        case 0x1C: return KeyCode::Num8;
        case 0x19: return KeyCode::Num9;

        case 0x35: return KeyCode::Escape;
        case 0x30: return KeyCode::Tab;
        case 0x31: return KeyCode::Space;
        case 0x24: return KeyCode::Enter;
        case 0x33: return KeyCode::Backspace;
        case 0x75: return KeyCode::Delete;

        case 0x7B: return KeyCode::Left;
        case 0x7C: return KeyCode::Right;
        case 0x7E: return KeyCode::Up;
        case 0x7D: return KeyCode::Down;

        case 0x73: return KeyCode::Home;
        case 0x77: return KeyCode::End;
        case 0x74: return KeyCode::PageUp;
        case 0x79: return KeyCode::PageDown;

        case 0x7A: return KeyCode::F1;
        case 0x78: return KeyCode::F2;
        case 0x63: return KeyCode::F3;
        case 0x76: return KeyCode::F4;
        case 0x60: return KeyCode::F5;
        case 0x61: return KeyCode::F6;
        case 0x62: return KeyCode::F7;
        case 0x64: return KeyCode::F8;
        case 0x65: return KeyCode::F9;
        case 0x6D: return KeyCode::F10;
        case 0x67: return KeyCode::F11;
        case 0x6F: return KeyCode::F12;

        default: return KeyCode::Unknown;
    }
}

static KeyModifiers convertModifiers(NSEventModifierFlags flags) {
    KeyModifiers mods;
    mods.shift = (flags & NSEventModifierFlagShift) != 0;
    mods.control = (flags & NSEventModifierFlagControl) != 0;
    mods.alt = (flags & NSEventModifierFlagOption) != 0;
    mods.command = (flags & NSEventModifierFlagCommand) != 0;
    return mods;
}

MacOSWindow::MacOSWindow() = default;

MacOSWindow::~MacOSWindow() {
    if (m_window) {
        [m_window close];
        [m_window release];
    }
    if (m_delegate) {
        [m_delegate release];
    }
}

bool MacOSWindow::initialize(const WindowConfig& config) {
    @autoreleasepool {
        // Create window
        NSRect contentRect = NSMakeRect(100, 100, config.width, config.height);
        NSWindowStyleMask styleMask = NSWindowStyleMaskTitled |
                                      NSWindowStyleMaskClosable |
                                      NSWindowStyleMaskMiniaturizable;

        if (config.resizable) {
            styleMask |= NSWindowStyleMaskResizable;
        }

        m_window = [[NSWindow alloc] initWithContentRect:contentRect
                                               styleMask:styleMask
                                                 backing:NSBackingStoreBuffered
                                                   defer:NO];

        if (!m_window) {
            return false;
        }

        [m_window setTitle:@(config.title.c_str())];
        [m_window setAcceptsMouseMovedEvents:YES];

        // Create Metal view
        m_view = [[MacOSMetalView alloc] initWithFrame:contentRect window:this];
        if (!m_view) {
            return false;
        }

        [m_window setContentView:m_view];

        // Create graphics context
        m_graphicsContext = std::make_unique<MetalGraphicsContext>(m_view);
        if (!m_graphicsContext->initialize()) {
            return false;
        }

        m_graphicsContext->setVSync(config.vsync);

        // Create and set delegate
        m_delegate = [[MacOSWindowDelegate alloc] initWithWindow:this];
        [m_window setDelegate:m_delegate];

        return true;
    }
}

void MacOSWindow::show() {
    if (m_window) {
        [m_window makeKeyAndOrderFront:nil];
        [NSApp activateIgnoringOtherApps:YES];
    }
}

void MacOSWindow::close() {
    m_shouldClose = true;
}

bool MacOSWindow::shouldClose() const {
    return m_shouldClose;
}

void MacOSWindow::getSize(int& width, int& height) const {
    if (m_window) {
        NSRect frame = [[m_window contentView] frame];
        width = static_cast<int>(frame.size.width);
        height = static_cast<int>(frame.size.height);
    }
}

void MacOSWindow::getFramebufferSize(int& width, int& height) const {
    m_graphicsContext->getViewportSize(width, height);
}

void MacOSWindow::getPosition(int& x, int& y) const {
    if (m_window) {
        NSRect frame = [m_window frame];
        x = static_cast<int>(frame.origin.x);
        y = static_cast<int>(frame.origin.y);
    }
}

void MacOSWindow::setTitle(const std::string& title) {
    if (m_window) {
        [m_window setTitle:@(title.c_str())];
    }
}

void MacOSWindow::setSize(int width, int height) {
    if (m_window) {
        NSRect frame = [m_window frame];
        frame.size = NSMakeSize(width, height);
        [m_window setFrame:frame display:YES];
    }
}

bool MacOSWindow::isFocused() const {
    return m_window && [m_window isKeyWindow];
}

bool MacOSWindow::isMinimized() const {
    return m_window && [m_window isMiniaturized];
}

GraphicsContext* MacOSWindow::getGraphicsContext() {
    return m_graphicsContext.get();
}

void MacOSWindow::setKeyCallback(KeyCallback callback) {
    m_keyCallback = callback;
}

void MacOSWindow::setMouseCallback(MouseCallback callback) {
    m_mouseCallback = callback;
}

void MacOSWindow::setScrollCallback(ScrollCallback callback) {
    m_scrollCallback = callback;
}

void MacOSWindow::setResizeCallback(ResizeCallback callback) {
    m_resizeCallback = callback;
}

void MacOSWindow::setCloseCallback(CloseCallback callback) {
    m_closeCallback = callback;
}

void MacOSWindow::handleKeyEvent(const KeyEvent& event) {
    if (m_keyCallback) {
        m_keyCallback(event);
    }
}

void MacOSWindow::handleMouseEvent(const MouseEvent& event) {
    if (m_mouseCallback) {
        m_mouseCallback(event);
    }
}

void MacOSWindow::handleScrollEvent(const ScrollEvent& event) {
    if (m_scrollCallback) {
        m_scrollCallback(event);
    }
}

void MacOSWindow::handleResize(int width, int height) {
    if (m_resizeCallback) {
        m_resizeCallback(width, height);
    }
}

void MacOSWindow::handleCloseRequest() {
    m_shouldClose = true;
    if (m_closeCallback) {
        m_closeCallback();
    }
}

} // namespace drite

// MacOSMetalView implementation
@implementation MacOSMetalView

- (id)initWithFrame:(NSRect)frame window:(drite::MacOSWindow*)win {
    // Create a default Metal device for initialization
    id<MTLDevice> device = MTLCreateSystemDefaultDevice();
    self = [super initWithFrame:frame device:device];
    if (self) {
        window = win;
        self.colorPixelFormat = MTLPixelFormatBGRA8Unorm;
        self.depthStencilPixelFormat = MTLPixelFormatDepth32Float;
    }
    return self;
}

- (BOOL)acceptsFirstResponder {
    return YES;
}

- (void)keyDown:(NSEvent*)event {
    drite::KeyEvent keyEvent;
    keyEvent.key = drite::convertKeyCode([event keyCode]);
    keyEvent.action = [event isARepeat] ? drite::KeyAction::Repeat : drite::KeyAction::Press;
    keyEvent.modifiers = drite::convertModifiers([event modifierFlags]);
    keyEvent.scancode = [event keyCode];
    window->handleKeyEvent(keyEvent);
}

- (void)keyUp:(NSEvent*)event {
    drite::KeyEvent keyEvent;
    keyEvent.key = drite::convertKeyCode([event keyCode]);
    keyEvent.action = drite::KeyAction::Release;
    keyEvent.modifiers = drite::convertModifiers([event modifierFlags]);
    keyEvent.scancode = [event keyCode];
    window->handleKeyEvent(keyEvent);
}

- (void)mouseDown:(NSEvent*)event {
    NSPoint point = [self convertPoint:[event locationInWindow] fromView:nil];
    drite::MouseEvent mouseEvent;
    mouseEvent.action = drite::MouseAction::Press;
    mouseEvent.button = drite::MouseButton::Left;
    mouseEvent.x = point.x;
    mouseEvent.y = point.y;
    mouseEvent.modifiers = drite::convertModifiers([event modifierFlags]);
    window->handleMouseEvent(mouseEvent);
}

- (void)mouseUp:(NSEvent*)event {
    NSPoint point = [self convertPoint:[event locationInWindow] fromView:nil];
    drite::MouseEvent mouseEvent;
    mouseEvent.action = drite::MouseAction::Release;
    mouseEvent.button = drite::MouseButton::Left;
    mouseEvent.x = point.x;
    mouseEvent.y = point.y;
    mouseEvent.modifiers = drite::convertModifiers([event modifierFlags]);
    window->handleMouseEvent(mouseEvent);
}

- (void)mouseMoved:(NSEvent*)event {
    NSPoint point = [self convertPoint:[event locationInWindow] fromView:nil];
    drite::MouseEvent mouseEvent;
    mouseEvent.action = drite::MouseAction::Move;
    mouseEvent.button = drite::MouseButton::Left;
    mouseEvent.x = point.x;
    mouseEvent.y = point.y;
    mouseEvent.modifiers = drite::convertModifiers([event modifierFlags]);
    window->handleMouseEvent(mouseEvent);
}

- (void)scrollWheel:(NSEvent*)event {
    NSPoint point = [self convertPoint:[event locationInWindow] fromView:nil];
    drite::ScrollEvent scrollEvent;
    scrollEvent.xOffset = [event scrollingDeltaX];
    scrollEvent.yOffset = [event scrollingDeltaY];
    scrollEvent.x = point.x;
    scrollEvent.y = point.y;
    window->handleScrollEvent(scrollEvent);
}

- (void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    window->handleResize(newSize.width, newSize.height);
}

@end

// MacOSWindowDelegate implementation
@implementation MacOSWindowDelegate

- (id)initWithWindow:(drite::MacOSWindow*)win {
    self = [super init];
    if (self) {
        window = win;
    }
    return self;
}

- (BOOL)windowShouldClose:(NSWindow*)sender {
    window->handleCloseRequest();
    return NO;
}

@end
