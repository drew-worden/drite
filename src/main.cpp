#include "application/application.h"
#include <print>

int main() {
    // Create the application instance
    drite::Application app;

    // Set up the window configuration
    drite::WindowConfig config;

    // Initialize the application
    if (!app.initialize(config)) {
        std::println("Failed to initialize {}.", config.title);
        return 1;
    }

    std::println("Initialized {} successfully.", config.title);

    // Run the main loop
    app.run();

    // Shutdown the application
    app.shutdown();
}
