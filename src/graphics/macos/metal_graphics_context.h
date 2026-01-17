#pragma once

#include "graphics/graphics_context.h"

/**
 * Forward declarations for Metal objects used in the graphics context.
 */
#ifdef __OBJC__
@protocol MTLDevice;
@protocol MTLCommandQueue;
@class MTKView;
#else
typedef struct objc_object MTLDevice;
typedef struct objc_object MTLCommandQueue;
typedef struct objc_object MTKView;
#endif

namespace drite {

    /**
    * @class MetalGraphicsContext
    * @brief Metal-based graphics context for macOS.
    * 
    * Implements the GraphicsContext interface using Apple's Metal API.
    * Manages the Metal device, command queue, and drawable view for rendering.
    */
    class MetalGraphicsContext : public GraphicsContext {
        public:

            /**
            * @brief Construct a new Metal Graphics Context object.
            * @param view The MTKView to render into.
            */
            explicit MetalGraphicsContext(MTKView* view);

            /**
            * @brief Destroy the Metal Graphics Context object.
            */
            ~MetalGraphicsContext() override;

            /**
            * @brief Initialize the Metal graphics context.
            * @return True if initialization was successful, false otherwise.
            */
            [[nodiscard]] bool initialize() override;

            /**
            * @brief Begin a new frame for rendering.
            */
            void beginFrame() override;

            /**
            * @brief End the current frame and present it to the screen.
            */
            void endFrame() override;

            /**
            * @brief Clear the screen with the specified color.
            * @param color The color to clear the screen with.
            */
            void clear(const ClearColor& color) override;

            /**
            * @brief Enable or disable vertical synchronization (VSync).
            * @param enabled True to enable VSync, false to disable.
            */
            void setVSync(bool enabled) override;

            /**
            * @brief Get the current viewport or drawable size.
            * @param width Reference to store the width.
            * @param height Reference to store the height.
            */
            void getViewportSize(int& width, int& height) const override;

            /**
            * @brief Get the native Metal device handle.
            * @return Pointer to the native Metal device.
            */
            [[nodiscard]] void* getNativeDevice() override;

            /**
            * @brief Get the native Metal command queue handle.
            * @return Pointer to the native Metal command queue.
            */
            [[nodiscard]] void* getNativeCommandQueue() override;

        /**
        * @brief Private members for the Metal graphics context.
        */
        private:
            MTKView* m_view{nullptr};
            id<MTLDevice> m_device;
            id<MTLCommandQueue> m_commandQueue;
            ClearColor m_clearColor{0.1f, 0.1f, 0.2f, 1.0f};
            bool m_initialized{false};
    };
};