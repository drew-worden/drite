#pragma once

#include "platform/platform.h"
#include <memory>

namespace drite {

    /**
     * @brief Factory for creating platform-specific implementations.
     */
    class PlatformFactory {
        public:
            /**
             * @brief Create platform instance for current OS.
             * @return A unique pointer to the created platform instance.
             */
            [[nodiscard]] static std::unique_ptr<Platform> create();

            /**
             * @brief Get singleton platform instance.
             * @return Pointer to the singleton platform instance.
             */
            [[nodiscard]] static Platform* getInstance();

        private:

            /**
             * @brief Singleton instance of the platform.
             */
            static std::unique_ptr<Platform> instance;
    };

}
