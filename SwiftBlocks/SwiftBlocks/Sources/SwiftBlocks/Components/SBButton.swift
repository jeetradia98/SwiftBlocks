// SBButton.swift
// SwiftBlocks — Button Components

import SwiftUI

// MARK: - Button Style Enum

public enum SBButtonStyle {
    case primary
    case secondary
    case outline
    case ghost
    case destructive
    case glass          // iOS 26 glass effect
}

public enum SBButtonSize {
    case small
    case medium
    case large

    var height: CGFloat {
        switch self {
        case .small:  return 36
        case .medium: return 50
        case .large:  return 56
        }
    }

    var font: Font {
        switch self {
        case .small:  return .system(size: 14, weight: .semibold)
        case .medium: return .system(size: 16, weight: .semibold, design: .rounded)
        case .large:  return .system(size: 18, weight: .bold, design: .rounded)
        }
    }

    var horizontalPadding: CGFloat {
        switch self {
        case .small:  return 14
        case .medium: return 20
        case .large:  return 28
        }
    }
}

// MARK: - SBButton

public struct SBButton: View {
    let title: String
    let icon: String?
    let style: SBButtonStyle
    let size: SBButtonSize
    let isFullWidth: Bool
    let isLoading: Bool
    let isDisabled: Bool
    let action: () -> Void

    @Environment(\.sbTheme) private var theme
    @State private var isPressed = false

    public init(
        _ title: String,
        icon: String? = nil,
        style: SBButtonStyle = .primary,
        size: SBButtonSize = .medium,
        isFullWidth: Bool = false,
        isLoading: Bool = false,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.style = style
        self.size = size
        self.isFullWidth = isFullWidth
        self.isLoading = isLoading
        self.isDisabled = isDisabled
        self.action = action
    }

    public var body: some View {
        Button(action: { if !isDisabled && !isLoading { action() } }) {
            buttonContent
                .frame(height: size.height)
                .frame(maxWidth: isFullWidth ? .infinity : nil)
                .padding(.horizontal, size.horizontalPadding)
                .background(backgroundView)
                .overlay(overlayView)
                .opacity(isDisabled ? 0.45 : 1.0)
                .scaleEffect(isPressed ? 0.97 : 1.0)
                .animation(.spring(response: 0.2, dampingFraction: 0.7), value: isPressed)
        }
        .buttonStyle(.plain)
        .disabled(isDisabled || isLoading)
        ._onButtonGesture(pressing: { isPressed = $0 }, perform: {})
    }

    @ViewBuilder
    private var buttonContent: some View {
        Group {
            if isLoading {
                HStack(spacing: 8) {
                    ProgressView()
                        .tint(foregroundColor)
                        .scaleEffect(0.85)
                    Text("Loading...")
                        .font(size.font)
                        .foregroundStyle(foregroundColor)
                }
            } else {
                HStack(spacing: 8) {
                    if let icon {
                        Image(systemName: icon)
                            .font(size.font)
                    }
                    Text(title)
                        .font(size.font)
                }
                .foregroundStyle(foregroundColor)
            }
        }
    }

    @ViewBuilder
    private var backgroundView: some View {
        switch style {
        case .primary:
            Capsule()
                .fill(theme.primary)
        case .secondary:
            Capsule()
                .fill(theme.secondary.opacity(0.15))
        case .outline:
            Capsule()
                .fill(Color.clear)
        case .ghost:
            Capsule()
                .fill(Color.clear)
        case .destructive:
            Capsule()
                .fill(theme.error)
        case .glass:
            if #available(iOS 26.0, *) {
                Capsule()
                    .glassEffect(.regular)
            } else {
                Capsule()
                    .fill(.regularMaterial)
            }
        }
    }

    @ViewBuilder
    private var overlayView: some View {
        if case .outline = style {
            Capsule()
                .strokeBorder(theme.primary, lineWidth: 1.5)
        }
    }

    private var foregroundColor: Color {
        switch style {
        case .primary:     return .white
        case .secondary:   return theme.secondary
        case .outline:     return theme.primary
        case .ghost:       return theme.primary
        case .destructive: return .white
        case .glass:       return .primary
        }
    }
}

// MARK: - SBIconButton

public struct SBIconButton: View {
    let icon: String
    let style: SBButtonStyle
    let size: CGFloat
    let action: () -> Void

    @Environment(\.sbTheme) private var theme

    public init(
        _ icon: String,
        style: SBButtonStyle = .primary,
        size: CGFloat = 44,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.style = style
        self.size = size
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: size * 0.4, weight: .semibold))
                .foregroundStyle(style == .primary ? .white : theme.primary)
                .frame(width: size, height: size)
                .background {
                    if #available(iOS 26.0, *), style == .glass {
                        Circle().glassEffect(.regular)
                    } else if style == .primary {
                        Circle().fill(theme.primary)
                    } else {
                        Circle().fill(theme.primary.opacity(0.1))
                    }
                }
        }
        .buttonStyle(.plain)
    }
}
