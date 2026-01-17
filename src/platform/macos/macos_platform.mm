#import "platform/macos/macos_platform.h"
#import "window/macos/macos_window.h"
#import <Cocoa/Cocoa.h>
#import <thread>

namespace drite {
    /**
     * @brief Construct a new MacOSPlatform object.
     */
    MacOSPlatform::MacOSPlatform() = default;

    /**
     * @brief Destroy the MacOSPlatform object.
     */
    MacOSPlatform::~MacOSPlatform() {
        if (m_initialized) {
            shutdown();
        }
    }

    /**
     * @brief Initialize the MacOSPlatform.
     * @return True if initialization was successful, false otherwise.
     */
    bool MacOSPlatform::initialize() {
        if (m_initialized) {
            return true;
        }

        @autoreleasepool {
            // Initialize NSApplication
            [NSApplication sharedApplication];

            // Set activation policy to regular app (appears in Dock)
            [NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];

            // Finish launching
            [NSApp finishLaunching];

            // Record start time
            m_startTime = std::chrono::steady_clock::now();

            m_initialized = true;
            return true;
        }
    }

    /**
     * @brief Shutdown the MacOSPlatform.
     */
    void MacOSPlatform::shutdown() {
        if (!m_initialized) {
            return;
        }

        @autoreleasepool {
            // Cleanup would go here
        }

        m_initialized = false;
    }

    std::unique_ptr<Window> MacOSPlatform::createWindow(const WindowConfig& config) {
        /**
         * @brief Create a new window with the specified configuration.
         * @param config The configuration for the window.
         * @return A unique pointer to the created window.
         */
        if (!m_initialized) {
            return nullptr;
        }

        auto window = std::make_unique<MacOSWindow>();
        if (!window->initialize(config)) {
            return nullptr;
        }

        return window;
    }

    void MacOSPlatform::pollEvents() {
        /**
         * @brief Poll for events without blocking.
         */
        @autoreleasepool {
            for (;;) {
                NSEvent* event = [NSApp nextEventMatchingMask:NSEventMaskAny
                                                    untilDate:[NSDate distantPast]
                                                    inMode:NSDefaultRunLoopMode
                                                    dequeue:YES];
                if (!event) {
                    break;
                }

                [NSApp sendEvent:event];
            }
        }
    }

    /**
     * @brief Wait for events, blocking until an event is available.
     */
    void MacOSPlatform::waitEvents() {
        @autoreleasepool {
            NSEvent* event = [NSApp nextEventMatchingMask:NSEventMaskAny
                                                untilDate:[NSDate distantFuture]
                                                inMode:NSDefaultRunLoopMode
                                                dequeue:YES];
            if (event) {
                [NSApp sendEvent:event];
            }

            // Process any other pending events
            pollEvents();
        }
    }

    /**
     * @brief Get the current time in seconds since the platform was initialized.
     * @return The current time in seconds.
     */
    double MacOSPlatform::getTime() const {
        auto now = std::chrono::steady_clock::now();
        auto duration = std::chrono::duration_cast<std::chrono::microseconds>(now - m_startTime);
        return duration.count() / 1000000.0;
    }

    /**
     * @brief Sleep for the specified number of milliseconds.
     * @param milliseconds The number of milliseconds to sleep.
     */
    void MacOSPlatform::sleep(int milliseconds) {
        std::this_thread::sleep_for(std::chrono::milliseconds(milliseconds));
    }

    /**
     * @brief Get the name of the platform.
     * @return The name of the platform.
     */
    const char* MacOSPlatform::getPlatformName() const {
        return "macOS";
    }

}
