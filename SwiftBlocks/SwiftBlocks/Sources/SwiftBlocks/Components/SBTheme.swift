// SBTheme.swift
// SwiftBlocks — Core Theme Engine
// iOS 17+ compatible, iOS 26 optimized

import SwiftUI

// MARK: - Theme Model

public struct SBTheme: Sendable {

    // MARK: Colors
    public var primary: Color
    public var secondary: Color
    public var accent: Color
    public var background: Color
    public var surface: Color
    public var error: Color
    public var success: Color
    public var warning: Color

    // MARK: Typography
    public var fontTitle: Font
    public var fontHeadline: Font
    public var fontBody: Font
    public var fontCaption: Font
    public var fontButton: Font

    // MARK: Spacing
    public var spacingXS: CGFloat
    public var spacingSM: CGFloat
    public var spacingMD: CGFloat
    public var spacingLG: CGFloat
    public var spacingXL: CGFloat

    // MARK: Radius
    public var radiusSM: CGFloat
    public var radiusMD: CGFloat
    public var radiusLG: CGFloat
    public var radiusFull: CGFloat

    // MARK: Default Theme
    public static let `default` = SBTheme(
        primary:    Color(red: 0.2, green: 0.4, blue: 1.0),
        secondary:  Color(red: 0.5, green: 0.3, blue: 0.9),
        accent:     Color(red: 0.0, green: 0.8, blue: 0.7),
        background: Color(.systemBackground),
        surface:    Color(.secondarySystemBackground),
        error:      Color(red: 1.0, green: 0.25, blue: 0.25),
        success:    Color(red: 0.2, green: 0.78, blue: 0.35),
        warning:    Color(red: 1.0, green: 0.75, blue: 0.0),

        fontTitle:    .system(size: 28, weight: .bold, design: .rounded),
        fontHeadline: .system(size: 17, weight: .semibold),
        fontBody:     .system(size: 15, weight: .regular),
        fontCaption:  .system(size: 12, weight: .regular),
        fontButton:   .system(size: 16, weight: .semibold, design: .rounded),

        spacingXS: 4,
        spacingSM: 8,
        spacingMD: 16,
        spacingLG: 24,
        spacingXL: 32,

        radiusSM:   8,
        radiusMD:   14,
        radiusLG:   20,
        radiusFull: 999
    )

    // MARK: Dark Theme
    public static let dark = SBTheme(
        primary:    Color(red: 0.4, green: 0.6, blue: 1.0),
        secondary:  Color(red: 0.7, green: 0.5, blue: 1.0),
        accent:     Color(red: 0.0, green: 0.9, blue: 0.8),
        background: Color(.systemBackground),
        surface:    Color(.secondarySystemBackground),
        error:      Color(red: 1.0, green: 0.4, blue: 0.4),
        success:    Color(red: 0.3, green: 0.9, blue: 0.5),
        warning:    Color(red: 1.0, green: 0.85, blue: 0.2),

        fontTitle:    .system(size: 28, weight: .bold, design: .rounded),
        fontHeadline: .system(size: 17, weight: .semibold),
        fontBody:     .system(size: 15, weight: .regular),
        fontCaption:  .system(size: 12, weight: .regular),
        fontButton:   .system(size: 16, weight: .semibold, design: .rounded),

        spacingXS: 4,
        spacingSM: 8,
        spacingMD: 16,
        spacingLG: 24,
        spacingXL: 32,

        radiusSM:   8,
        radiusMD:   14,
        radiusLG:   20,
        radiusFull: 999
    )
}

// MARK: - Environment Key

private struct SBThemeKey: EnvironmentKey {
    static let defaultValue: SBTheme = .dark
}

public extension EnvironmentValues {
    var sbTheme: SBTheme {
        get { self[SBThemeKey.self] }
        set { self[SBThemeKey.self] = newValue }
    }
}

// MARK: - View Extension

public extension View {
    /// Apply a SwiftBlocks theme to the entire view hierarchy
    func sbTheme(_ theme: SBTheme) -> some View {
        environment(\.sbTheme, theme)
    }
}
