#pragma once

#include <cstdint>

namespace drite {

    /**
     * @brief Keyboard key codes.
     */
    enum class KeyCode {
        Unknown = 0,

        // Letters
        A, B, C, D, E, F, G, H, I, J, K, L, M,
        N, O, P, Q, R, S, T, U, V, W, X, Y, Z,

        // Numbers
        Num0, Num1, Num2, Num3, Num4, Num5, Num6, Num7, Num8, Num9,

        // Function keys
        F1, F2, F3, F4, F5, F6, F7, F8, F9, F10, F11, F12,

        // Special keys
        Escape, Tab, CapsLock, Shift, Control, Alt, Command,
        Space, Enter, Backspace, Delete,

        // Navigation
        Left, Right, Up, Down,
        Home, End, PageUp, PageDown,

        // Punctuation
        Minus, Equal, LeftBracket, RightBracket,
        Semicolon, Quote, Comma, Period, Slash, Backslash, Grave
    };

    /**
     * @brief Key action types.
     */
    enum class KeyAction {
        Press,
        Release,
        Repeat
    };

    /**
     * @brief Mouse button types.
     */
    enum class MouseButton {
        Left = 0,
        Right = 1,
        Middle = 2,
        Button4 = 3,
        Button5 = 4
    };

    /**
     * @brief Mouse action types.
     */
    enum class MouseAction {
        Press,
        Release,
        Move
    };

    /**
     * @brief Keyboard modifier keys state.
     */
    struct KeyModifiers {
        bool shift{false};
        bool control{false};
        bool alt{false};
        bool command{false};

        constexpr KeyModifiers() = default;
        constexpr KeyModifiers(bool shift, bool control, bool alt, bool command)
            : shift(shift), control(control), alt(alt), command(command) {}
    };

    /**
     * @brief Keyboard event.
     */
    struct KeyEvent {
        KeyCode key{KeyCode::Unknown};
        KeyAction action{KeyAction::Press};
        KeyModifiers modifiers;
        uint32_t scancode{0};
    };

    /**
     * @brief Mouse event.
     */
    struct MouseEvent {
        MouseAction action{MouseAction::Move};
        MouseButton button{MouseButton::Left};
        double x{0.0};
        double y{0.0};
        KeyModifiers modifiers;
    };

    /**
     * @brief Scroll event.
     */
    struct ScrollEvent {
        double xOffset{0.0};
        double yOffset{0.0};
        double x{0.0};
        double y{0.0};
    };

}
