#include "platform/platform_factory.h"

/**
 * @brief Implementation of the PlatformFactory class for creating platform-specific platform instances.
 */
#ifdef __APPLE__
#include "platform/macos/macos_platform.h"
#endif

namespace drite {

    /**
     * @brief Singleton instance of the platform.
     */
    std::unique_ptr<Platform> PlatformFactory::instance = nullptr;


    /**
     * @brief Create platform instance for current OS.
     * @return A unique pointer to the created platform instance.
     */
    std::unique_ptr<Platform> PlatformFactory::create() {
    #ifdef __APPLE__
        return std::make_unique<MacOSPlatform>();
    #else
        #error "Unsupported platform"
    #endif
    }

    /**
     * @brief Get singleton platform instance.
     * @return Pointer to the singleton platform instance.
     */
    Platform* PlatformFactory::getInstance() {
        if (!instance) {
            instance = create();
        }
        return instance.get();
    }

}
