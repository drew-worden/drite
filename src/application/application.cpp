#include "application.h"
#include "platform/platform_factory.h"
#include <print>

namespace drite {
    
    /**
     * @brief Construct a new Application object.
     */
    Application::Application() = default;

    /**
     * @brief Destroy the Application object.
     */
    Application::~Application() {
        shutdown();
    }

    /**
     * @brief Initialize the application with the given window configuration.
     * @param config The window configuration.
     * @return True if initialization was successful, false otherwise.
     */
    bool Application::initialize(const WindowConfig& config) {
        // Get platform instance
        platform = PlatformFactory::getInstance();
        if (!platform) {
            std::println(stderr, "Failed to create platform");
            return false;
        }

        // Initialize platform
        if (!platform->initialize()) {
            std::println(stderr, "Failed to initialize platform");
            return false;
        }

        std::println("Platform: {}", platform->getPlatformName());

        // Create window
        window = platform->createWindow(config);
        if (!window) {
            std::println(stderr, "Failed to create window");
            return false;
        }

        // Set up event callbacks
        window->setResizeCallback([this](int w, int h) { onResize(w, h); });
        window->setCloseCallback([this]() { onClose(); });
        window->setKeyCallback([this](const KeyEvent& e) { onKey(e); });
        window->setMouseCallback([this](const MouseEvent& e) { onMouse(e); });
        window->setScrollCallback([this](const ScrollEvent& e) { onScroll(e); });

        // Show window
        window->show();

        // Log window and drawable sizes
        int windowWidth{0}, windowHeight{0};
        int drawableWidth{0}, drawableHeight{0};
        window->getSize(windowWidth, windowHeight);
        window->getFramebufferSize(drawableWidth, drawableHeight);

        std::println("Window size: {}x{} points", windowWidth, windowHeight);
        std::print("Drawable size: {}x{} pixels", drawableWidth, drawableHeight);

        if (drawableWidth != windowWidth || drawableHeight != windowHeight) {
            const float scale = static_cast<float>(drawableWidth) / windowWidth;
            std::print(" (Retina {:.1f}x scaling)", scale);
        }
        std::println("");

        running = true;
        lastFrameTime = platform->getTime();

        return true;
    }

    /**
     * @brief Run the main application loop.
     */
    void Application::run() {
        while (running && !window->shouldClose()) {
            // Poll events
            platform->pollEvents();

            // Calculate delta time
            double currentTime = platform->getTime();
            double deltaTime = currentTime - lastFrameTime;
            lastFrameTime = currentTime;

            // Update and render
            update(deltaTime);
            render();
        }
    }

    /**
     * @brief Shutdown the application and release resources.
     */
    void Application::shutdown() {
        if (window) {
            window.reset();
        }

        if (platform) {
            platform->shutdown();
        }

        running = false;
    }

    /**
     * @brief Handle window resize events.
     * @param width The new width of the window in points.
     * @param height The new height of the window in points.
     */
    void Application::onResize(int width, int height) {
        int drawableWidth{0}, drawableHeight{0};
        window->getFramebufferSize(drawableWidth, drawableHeight);

        std::print("Window resized to: {}x{} points", width, height);
        if (drawableWidth != width || drawableHeight != height) {
            std::print(" ({}x{} pixels)", drawableWidth, drawableHeight);
        }
        std::println("");

        // Graphics context automatically handles viewport updates
    }

    /**
     * @brief Handle window close events.
     */
    void Application::onClose() {
        std::println("Window close requested");
        running = false;
    }

    /**
     * @brief Handle key events.
     * @param event The key event.
     */
    void Application::onKey(const KeyEvent& event) {
        if (event.action == KeyAction::Press) {
            std::println("Key pressed: {}", static_cast<int>(event.key));

            // Quit on Escape
            if (event.key == KeyCode::Escape) {
                running = false;
            }
        }
    }

    /**
     * @brief Handle mouse events.
     * @param event The mouse event.
     */
    void Application::onMouse(const MouseEvent& event) {
        if (event.action == MouseAction::Press) {
            std::println("Mouse click at: {}, {}", event.x, event.y);
        }
    }

    /**
     * @brief Handle scroll events.
     * @param event The scroll event.
     */
    void Application::onScroll(const ScrollEvent& event) {
        std::println("Scroll: {}, {}", event.xOffset, event.yOffset);
    }

    /**
     * @brief Update the application state.
     * @param deltaTime The time elapsed since the last frame in seconds.
     */
    void Application::update(double /* deltaTime */) {
        // Update logic here
        // deltaTime will be used when implementing editor updates
    }

    /**
     * @brief Render the application.
     */
    void Application::render() {
        auto* ctx = window->getGraphicsContext();

        // Clear the screen with the specified color
        constexpr ClearColor clearColor{0.1f, 0.1f, 0.2f, 1.0f};
        ctx->clear(clearColor);
    }

}
