#pragma once

#include "window/window.h"
#include <memory>

namespace drite {

    /**
     * @brief Platform abstraction layer - handles OS-specific initialization,
     * event polling, timing, and window creation.
     */
    class Platform {
    public:
        /**
         * @brief Destroy the platform.
         */
        virtual ~Platform() = default;

        /**
         * @brief Initialize the platform.
         * @return True if initialization was successful, false otherwise.
         */
        [[nodiscard]] virtual bool initialize() = 0;

        /**
         * @brief Shutdown the platform.
         */
        virtual void shutdown() = 0;

        /**
         * @brief Create a window with the specified configuration.
         * @param config The window configuration.
         * @return A unique pointer to the created window.
         */
        [[nodiscard]] virtual std::unique_ptr<Window> createWindow(const WindowConfig& config) = 0;

        /**
         * @brief Poll for events (process pending events).
         */
        virtual void pollEvents() = 0;

        /**
         * @brief Wait for events (block until events arrive).
         */
        virtual void waitEvents() = 0;

        /**
         * @brief Get time in seconds since platform initialization.
         * @return Time in seconds.
         */
        [[nodiscard]] virtual double getTime() const = 0;

        /**
         * @brief Sleep for specified milliseconds.
         * @param milliseconds Time to sleep in milliseconds.
         */
        virtual void sleep(int milliseconds) = 0;

        /**
         * @brief Get the name of the platform.
         * @return The platform name as a C-string.
         */
        [[nodiscard]] virtual const char* getPlatformName() const = 0;
    };
}
