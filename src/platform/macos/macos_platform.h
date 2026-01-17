#pragma once

#include "platform/platform.h"
#include <chrono>

/**
 * @brief macOS-specific autorelease pool wrapper.
 */
#ifdef __OBJC__
@class NSAutoreleasePool;
#else
typedef struct objc_object NSAutoreleasePool;
#endif

namespace drite {

    /**
     * @brief macOS-specific platform implementation using Cocoa.
     */
    class MacOSPlatform : public Platform {
        public:
            /**
             * @brief Construct a new MacOSPlatform object.
             */
            MacOSPlatform();

            /**
             * @brief Destroy the MacOSPlatform object.
             */
            ~MacOSPlatform() override;

            /**
             * @brief Initialize the MacOSPlatform.
             * @return True if initialization was successful, false otherwise.
             */
            [[nodiscard]] bool initialize() override;

            /**
             * @brief Shutdown the MacOSPlatform.
             */
            void shutdown() override;

            /**
             * @brief Create a new window with the specified configuration.
             * @param config The configuration for the window.
             * @return A unique pointer to the created window.
             */
            [[nodiscard]] std::unique_ptr<Window> createWindow(const WindowConfig& config) override;

            /**
             * @brief Poll for events without blocking.
             */
            void pollEvents() override;

            /**
             * @brief Wait for events, blocking until an event is available.
             */
            void waitEvents() override;

            /**
             * @brief Get the current time in seconds since the platform was initialized.
             * @return The current time in seconds.
             */
            [[nodiscard]] double getTime() const override;

            /**
             * @brief Sleep for the specified number of milliseconds.
             * @param milliseconds The number of milliseconds to sleep.
             */
            void sleep(int milliseconds) override;

            /**
             * @brief Get the name of the platform.
             * @return The name of the platform.
             */
            [[nodiscard]] const char* getPlatformName() const override;

        private:
            /**
             * @brief The macOS autorelease pool used for memory management.
             */
            NSAutoreleasePool* m_autoreleasePool{nullptr};

            /**
             * @brief The time point when the platform was initialized.
             */
            std::chrono::steady_clock::time_point m_startTime;

            /**
             * @brief Whether the platform has been initialized.
             */
            bool m_initialized{false};
        };

}
