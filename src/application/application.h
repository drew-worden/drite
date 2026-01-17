#pragma once

#include "platform/platform.h"
#include "window/window.h"
#include <memory>

namespace drite {

    /**
     * @brief Main application class that manages the application lifecycle, window,
     * platform abstraction, and the main run loop for the editor.
     */
    class Application {
        public:

            /**
             * @brief Construct a new Application object.
             */
            Application();

            /**
             * @brief Destroy the Application object.
             */
            ~Application();

            /**
             * @brief Initialize the application with the given window configuration.
             * @param config The window configuration.
             * @return True if initialization was successful, false otherwise.
             */
            [[nodiscard]] bool initialize(const WindowConfig& config = WindowConfig());

            /**
             * @brief Run the main application loop.
             */
            void run();

            /**
             * @brief Shutdown the application and clean up resources.
             */
            void shutdown();

            /**
             * @brief Get the main window instance.
             * @return Pointer to the main window.
             */
            [[nodiscard]] Window* getWindow() const noexcept { return window.get(); }

            /**
             * @brief Get the platform abstraction instance.
             * @return Pointer to the platform abstraction.
             */
            [[nodiscard]] Platform* getPlatform() const noexcept { return platform; }

        private:
            /**
             * @brief Handle window resize events.
             * @param width The new width of the window in points.
             * @param height The new height of the window in points.
             */
            void onResize(int width, int height);

            /**
             * @brief Handle window close events.
             */
            void onClose();

            /**
             * @brief Handle key events.
             * @param event The key event.
             */
            void onKey(const KeyEvent& event);

            /**
             * @brief Handle mouse events.
             * @param event The mouse event.
             */
            void onMouse(const MouseEvent& event);

            /**
             * @brief Handle scroll events.
             * @param event The scroll event.
             */
            void onScroll(const ScrollEvent& event);

            /**
             * @brief Update the application state.
             * @param deltaTime The time elapsed since the last frame in seconds.
             */
            void update(double deltaTime);

            /**
             * @brief Render the application.
             */
            void render();

        private:
            /**
             * @brief The platform abstraction instance.
             */
            Platform* platform{nullptr};

            /**
             * @brief The main window instance.
             */
            std::unique_ptr<Window> window{nullptr};

            /**
             * @brief Flag indicating whether the application is running.
             */
            bool running{false};

            /**
             * @brief The time of the last frame in seconds.
             */
            double lastFrameTime{0.0};
        };

}
