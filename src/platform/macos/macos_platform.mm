#import "platform/macos/macos_platform.h"
#import "window/macos/macos_window.h"
#import <Cocoa/Cocoa.h>
#import <thread>

/* 
 * @brief Application delegate to handle app-level events like Command+Q
 */
@interface MacOSAppDelegate : NSObject<NSApplicationDelegate>
@end
    
/* 
 * @brief Application delegate to handle app-level events like Command+Q
 */
@implementation MacOSAppDelegate
- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication*)sender {
    // Post a window close event to all windows instead of terminating directly
    for (NSWindow* window in [NSApp windows]) {
        [window performClose:nil];
    }
    return NSTerminateCancel;
}

/**
 * @brief Determine if the application should terminate after the last window is closed.
 * @param sender The NSApplication instance.
 * @return True if the application should terminate, false otherwise.
 */
- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication*)sender {
    return YES;
}
@end

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
        if (m_appDelegate) {
            [m_appDelegate release];
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

            // Create and set application delegate to handle Command+Q
            m_appDelegate = [[MacOSAppDelegate alloc] init];
            [NSApp setDelegate:m_appDelegate];

            // Set activation policy to regular app (appears in Dock)
            [NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];

            // Create menu bar for Command+Q to work
            NSMenu* mainMenu = [[NSMenu alloc] init];

            // App menu
            NSMenuItem* appMenuItem = [[NSMenuItem alloc] init];
            NSMenu* appMenu = [[NSMenu alloc] init];

            // Quit menu item (Command+Q)
            NSMenuItem* quitMenuItem = [[NSMenuItem alloc] initWithTitle:@"Quit Drite"
                                                                  action:@selector(terminate:)
                                                           keyEquivalent:@"q"];
            [appMenu addItem:quitMenuItem];
            [appMenuItem setSubmenu:appMenu];
            [mainMenu addItem:appMenuItem];

            [NSApp setMainMenu:mainMenu];

            [quitMenuItem release];
            [appMenu release];
            [appMenuItem release];
            [mainMenu release];

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
