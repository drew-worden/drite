#pragma once

namespace drite {

    /**
     * @struct ClearColor
     * @brief Represents a color value used for clearing the graphics buffer.
     * 
     * Stores RGBA color components as floating-point values, typically in the range [0.0, 1.0].
     * Default alpha value is 1.0 (fully opaque).
     * 
     * @member r Red component (default: 0.0f)
     * @member g Green component (default: 0.0f)
     * @member b Blue component (default: 0.0f)
     * @member a Alpha component (default: 1.0f)
     */
    struct ClearColor {
        float r{0.0f};
        float g{0.0f};
        float b{0.0f};
        float a{1.0f};

        constexpr ClearColor() = default;
        constexpr ClearColor(float r, float g, float b, float a)
            : r(r), g(g), b(b), a(a) {}
    };

    
    /**
     * @class GraphicsContext
     * @brief Abstract base class for a graphics context.
     * 
     * Provides an interface for initializing the graphics API, managing frames,
     * clearing the screen, and accessing native handles for platform-specific operations.
     */
    class GraphicsContext {
    public:
        virtual ~GraphicsContext() = default;

        /**
         * @brief Initialize the graphics context.
         * @return True if initialization was successful, false otherwise.
         */
        [[nodiscard]] virtual bool initialize() = 0;

        /**
         * @brief Begin a new frame for rendering.
         */
        virtual void beginFrame() = 0;

        /**
         * @brief End the current frame and present it to the screen.
         */
        virtual void endFrame() = 0;

        /**
         * @brief Clear the screen with the specified color.
         * @param color The color to clear the screen with.
         */
        virtual void clear(const ClearColor& color) = 0;

        /**
         * @brief Enable or disable vertical synchronization (VSync).
         * @param enabled True to enable VSync, false to disable.
         */
        virtual void setVSync(bool enabled) = 0;

        /**
         * @brief Get the current viewport or drawable size.
         * @param width Reference to store the width.
         * @param height Reference to store the height.
         */
        virtual void getViewportSize(int& width, int& height) const = 0;

        /**
         * @brief Get the native graphics device handle.
         * @return Pointer to the native device.
         */
        [[nodiscard]] virtual void* getNativeDevice() = 0;
        
        /**
         * @brief Get the native graphics command queue handle.
         * @return Pointer to the native command queue.
         */
        [[nodiscard]] virtual void* getNativeCommandQueue() = 0;
    };

}
