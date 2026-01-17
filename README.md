# Drite Code Editor

A modern C++ code editor built with a fully abstracted, platform-independent architecture.

## Architecture Overview

Drite is designed with clean separation between application logic and OS-specific implementations, enabling scalable development focused on editor functionality.

### Architectural Layers

```mermaid
graph TB
    subgraph Application["APPLICATION LAYER"]
        App[Application<br/>- Lifecycle management<br/>- Event handling<br/>- Main loop<br/>- Editor logic]
    end

    subgraph Abstraction["ABSTRACTION LAYER"]
        Platform[Platform<br/>- initialize<br/>- shutdown<br/>- createWindow<br/>- pollEvents<br/>- getTime]
        Window[Window<br/>- initialize<br/>- show/close<br/>- setCallbacks<br/>- getSize]
        Graphics[GraphicsContext<br/>- initialize<br/>- beginFrame<br/>- endFrame<br/>- clear<br/>- setVSync]
        Input[Input Types<br/>- KeyCode/KeyEvent<br/>- MouseEvent<br/>- ScrollEvent]
    end

    subgraph Implementation["IMPLEMENTATION LAYER"]
        subgraph macOS["macOS"]
            MacPlatform[MacOSPlatform<br/>Cocoa/NSApp]
            MacWindow[MacOSWindow<br/>NSWindow/NSView]
            Metal[MetalGraphicsContext<br/>MTKView/MTLDevice]
        end

        subgraph Future["Future Support"]
            Win[Windows<br/>Win32/D3D12]
            Linux[Linux<br/>X11/Vulkan]
        end
    end

    App -->|uses interfaces only| Platform
    App -->|uses interfaces only| Window
    App -->|uses interfaces only| Graphics
    App -->|uses| Input

    Platform -.->|implements| MacPlatform
    Window -.->|implements| MacWindow
    Graphics -.->|implements| Metal

    Platform -.->|future| Win
    Platform -.->|future| Linux

    style App fill:#e1f5ff
    style Platform fill:#fff4e1
    style Window fill:#fff4e1
    style Graphics fill:#fff4e1
    style Input fill:#fff4e1
    style MacPlatform fill:#e8f5e9
    style MacWindow fill:#e8f5e9
    style Metal fill:#e8f5e9
    style Win fill:#f3e5f5
    style Linux fill:#f3e5f5
```

### Component Relationships

```mermaid
graph LR
    Main[main.cpp] --> App[Application]

    App --> Factory[PlatformFactory]
    App --> Win[Window]
    App --> GFX[GraphicsContext]

    Factory -->|creates| Plat[Platform]
    Plat -->|creates| Win
    Win -->|owns| GFX

    subgraph macOS Implementation
        Plat -.->|implements| MacPlat[MacOSPlatform]
        Win -.->|implements| MacWin[MacOSWindow]
        GFX -.->|implements| Metal[MetalGraphicsContext]
    end

    style App fill:#e1f5ff
    style Factory fill:#fff4e1
    style Win fill:#fff4e1
    style GFX fill:#fff4e1
    style Plat fill:#fff4e1
    style MacPlat fill:#e8f5e9
    style MacWin fill:#e8f5e9
    style Metal fill:#e8f5e9
```

### Data Flow - Initialization

```mermaid
sequenceDiagram
    participant Main
    participant App as Application
    participant Factory as PlatformFactory
    participant Platform as MacOSPlatform
    participant Window as MacOSWindow
    participant Graphics as MetalGraphicsContext

    Main->>App: create()
    Main->>App: initialize(config)
    App->>Factory: getInstance()
    Factory->>Platform: create MacOSPlatform
    Factory-->>App: Platform*
    App->>Platform: initialize()
    Platform->>Platform: Setup NSApplication
    Platform-->>App: success
    App->>Platform: createWindow(config)
    Platform->>Window: create MacOSWindow
    Window->>Graphics: create MetalGraphicsContext
    Graphics->>Graphics: Setup MTLDevice
    Graphics-->>Window: ready
    Window-->>Platform: Window*
    Platform-->>App: Window*
    App->>Window: show()
    Window-->>App: visible
```

### Data Flow - Event Handling

```mermaid
sequenceDiagram
    participant macOS as macOS Event
    participant View as MacOSMetalView
    participant Window as MacOSWindow
    participant App as Application
    participant Editor as Editor Logic

    macOS->>View: NSEvent (keyDown)
    View->>View: convertKeyCode()
    View->>Window: handleKeyEvent(KeyEvent)
    Window->>Window: KeyCallback λ
    Window->>App: onKey(event)
    App->>Editor: process key input
    Editor-->>App: command executed
```

### Data Flow - Render Loop

```mermaid
graph LR
    A[Application::run] --> B[pollEvents]
    B --> C[calculate deltaTime]
    C --> D[update]
    D --> E[render]
    E --> F[getGraphicsContext]
    F --> G[clear color]
    G --> H[MTKView presents]
    H --> I{shouldClose?}
    I -->|No| B
    I -->|Yes| J[shutdown]

    style A fill:#e1f5ff
    style E fill:#e1f5ff
    style G fill:#e8f5e9
    style H fill:#e8f5e9
```

## Project Structure

```
src/
├── application/              # Application layer
│   ├── application.h
│   └── application.cpp
│
├── platform/                 # Platform abstraction
│   ├── platform.h           # Abstract interface
│   ├── platform_factory.h
│   ├── platform_factory.cpp
│   └── macos/               # macOS implementation
│       ├── macos_platform.h
│       └── macos_platform.mm
│
├── window/                   # Window abstraction
│   ├── window.h             # Abstract interface
│   └── macos/               # macOS implementation
│       ├── macos_window.h
│       └── macos_window.mm
│
├── graphics/                 # Graphics abstraction
│   ├── graphics_context.h   # Abstract interface
│   └── macos/               # Metal implementation
│       ├── metal_graphics_context.h
│       └── metal_graphics_context.mm
│
├── input/                    # Input type definitions
│   └── input_types.h
│
└── main.cpp                  # Entry point
```

## Key Design Principles

### 1. Abstraction Through Interfaces
- All OS-specific functionality hidden behind abstract base classes
- Application layer only interacts with abstract interfaces
- No platform-specific types or APIs exposed to higher layers

### 2. Factory Pattern
- `PlatformFactory` creates appropriate platform implementation
- Compile-time platform detection (`#ifdef __APPLE__`)
- Single point of platform selection

### 3. Modern C++ (C++23)
- `std::print`/`std::println` for formatted output
- `[[nodiscard]]` attributes for important return values
- `constexpr` for compile-time constants
- `std::unique_ptr` for ownership management
- `= default` for constructors
- Default member initializers: `bool m_running{false}`
- Strongly-typed enums (`enum class`)

### 4. Clean Include Paths
- Base include directory: `src/`
- Compiler flag: `-Isrc`
- Clean includes: `#include "platform/platform.h"`
- No relative paths like `../platform.h`

## Building

```bash
# Build the project
make

# Clean build files
make clean

# Build and run
make run
```

## Requirements

- C++23 compatible compiler (clang++ on macOS)
- macOS (Metal support required)
- Xcode Command Line Tools

## Architecture Benefits

1. **Platform Independence**: Application code has zero platform-specific code
2. **Testability**: Interfaces can be mocked for unit testing
3. **Maintainability**: Clear separation of concerns
4. **Extensibility**: New platforms add implementations without changing abstractions
5. **Performance**: No runtime overhead - virtual calls only at layer boundaries
6. **Scalability**: Editor features can be added without touching platform code

## Adding New Platforms

To add Windows or Linux support:

1. Implement `Platform` interface → `Win32Platform` / `LinuxPlatform`
2. Implement `Window` interface → `Win32Window` / `X11Window`
3. Implement `GraphicsContext` interface → `D3D12GraphicsContext` / `VulkanGraphicsContext`
4. Update `PlatformFactory` with `#ifdef _WIN32` / `#ifdef __linux__`
5. Update build system

**Application layer requires ZERO changes!**

## Future Editor Features

### Text Buffer System
- Line buffer management
- Gap buffer or piece table
- Syntax highlighting
- Multi-cursor support

### UI System
- Command palette
- Status bar
- Sidebar/file tree
- Text rendering with ligatures

### Command System
- File operations (open, save, close)
- Edit operations (cut, copy, paste, undo/redo)
- View operations (split, zoom, theme)

## License

MIT License - Copyright (c) 2026 Drew Worden

See [LICENSE](LICENSE) for details. 