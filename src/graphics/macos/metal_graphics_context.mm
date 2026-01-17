#import "graphics/macos/metal_graphics_context.h"
#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>

namespace drite {

    /**
     * @brief Construct a new Metal Graphics Context object.
     * @param view The MTKView to render into.
     */
    MetalGraphicsContext::MetalGraphicsContext(MTKView* view)
        : m_view(view)
        , m_device(nil)
        , m_commandQueue(nil) {
        [m_view retain];
    }


    /**
     * @brief Destroy the Metal Graphics Context object.
     */
    MetalGraphicsContext::~MetalGraphicsContext() {
        if (m_commandQueue) {
            [m_commandQueue release];
            m_commandQueue = nil;
        }

        if (m_device) {
            [m_device release];
            m_device = nil;
        }

        if (m_view) {
            [m_view release];
            m_view = nil;
        }
    }


    /**
     * @brief Initialize the Metal graphics context.
     * @return True if initialization was successful, false otherwise.
     */
    bool MetalGraphicsContext::initialize() {
        if (m_initialized) {
            return true;
        }

        @autoreleasepool {
            // Create Metal device
            m_device = MTLCreateSystemDefaultDevice();
            if (!m_device) {
                return false;
            }
            [m_device retain];

            // Create command queue
            m_commandQueue = [m_device newCommandQueue];
            if (!m_commandQueue) {
                return false;
            }

            // Configure MTKView
            m_view.device = m_device;
            m_view.colorPixelFormat = MTLPixelFormatBGRA8Unorm;
            m_view.depthStencilPixelFormat = MTLPixelFormatDepth32Float;
            m_view.clearColor = MTLClearColorMake(m_clearColor.r, m_clearColor.g,
                                                m_clearColor.b, m_clearColor.a);

            m_initialized = true;
            return true;
        }
    }


    /**
     * @brief Begin a new frame for rendering.
     */
    void MetalGraphicsContext::beginFrame() {
        // Frame setup is handled by MTKView's draw callback
    }

    /**
     * @brief End the current frame and present it to the screen.
     */
    void MetalGraphicsContext::endFrame() {
        // Frame presentation is handled automatically by MTKView
    }

    /**
     * @brief Clear the screen with the specified color.
     * @param color The color to clear the screen with.
     */
    void MetalGraphicsContext::clear(const ClearColor& color) {
        m_clearColor = color;
        if (m_view) {
            m_view.clearColor = MTLClearColorMake(color.r, color.g, color.b, color.a);
        }
    }

    /**
     * @brief Enable or disable vertical synchronization (VSync).
     * @param enabled True to enable VSync, false to disable.
     */
    void MetalGraphicsContext::setVSync(bool enabled) {
        if (m_view) {
            m_view.preferredFramesPerSecond = enabled ? 60 : 0;
        }
    }

    /**
     * @brief Get the current viewport or drawable size.
     * @param width Reference to store the width.
     * @param height Reference to store the height.
     */
    void MetalGraphicsContext::getViewportSize(int& width, int& height) const {
        if (m_view) {
            const CGSize drawableSize = m_view.drawableSize;
            width = static_cast<int>(drawableSize.width);
            height = static_cast<int>(drawableSize.height);
        } else {
            width = 0;
            height = 0;
        }
    }

    /**
     * @brief Get the native Metal device handle.
     * @return Pointer to the native Metal device.
     */
    void* MetalGraphicsContext::getNativeDevice() {
        return (__bridge void*)m_device;
    }

    /**
     * @brief Get the native Metal command queue handle.
     * @return Pointer to the native Metal command queue.
     */
    void* MetalGraphicsContext::getNativeCommandQueue() {
        return (__bridge void*)m_commandQueue;
    }
}
