// SBGlass.swift
// SwiftBlocks — iOS 26 Liquid Glass Effect System
// Uses .glassEffect(_:in:) on iOS 26+, falls back to material on iOS 17–25

import SwiftUI

// MARK: - Glass Style

public enum SBGlassStyle {
    case regular
    case thick
    case thin
    case ultraThin
    case ultraThick
    case tinted(Color)
}

// MARK: - Glass Shape

public enum SBGlassShape {
    case rectangle
    case roundedRectangle(radius: CGFloat)
    case capsule
    case circle
}

// MARK: - Glass ViewModifier

public struct SBGlassModifier: ViewModifier {
    let style: SBGlassStyle
    let shape: SBGlassShape
    let padding: CGFloat

    public init(
        style: SBGlassStyle = .regular,
        shape: SBGlassShape = .roundedRectangle(radius: 20),
        padding: CGFloat = 16
    ) {
        self.style = style
        self.shape = shape
        self.padding = padding
    }

    public func body(content: Content) -> some View {
        content
            .padding(padding)
            .background { glassBackground }
    }

    @ViewBuilder
    private var glassBackground: some View {
        if #available(iOS 26.0, *) {
            iOS26Glass
        } else {
            fallbackGlass
        }
    }

    @available(iOS 26.0, *)
    @ViewBuilder
    private var iOS26Glass: some View {
        switch shape {
        case .rectangle:
            Rectangle()
                .glassEffect(.regular)
        case .roundedRectangle(let radius):
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .glassEffect(.regular)
        case .capsule:
            Capsule()
                .glassEffect(.regular)
        case .circle:
            Circle()
                .glassEffect(.regular)
        }
    }

    @ViewBuilder
    private var fallbackGlass: some View {
        let material: Material = {
            switch style {
            case .ultraThin:  return .ultraThinMaterial
            case .thin:       return .thinMaterial
            case .regular:    return .regularMaterial
            case .thick:      return .thickMaterial
            case .ultraThick: return .ultraThickMaterial
            case .tinted:     return .regularMaterial
            }
        }()

        switch shape {
        case .rectangle:
            Rectangle().fill(material)
        case .roundedRectangle(let radius):
            RoundedRectangle(cornerRadius: radius, style: .continuous).fill(material)
        case .capsule:
            Capsule().fill(material)
        case .circle:
            Circle().fill(material)
        }
    }
}

// MARK: - View Extension

public extension View {
    /// Apply iOS 26 Liquid Glass effect. Falls back to material blur on iOS 17–25.
    func sbGlass(
        style: SBGlassStyle = .regular,
        shape: SBGlassShape = .roundedRectangle(radius: 20),
        padding: CGFloat = 16
    ) -> some View {
        modifier(SBGlassModifier(style: style, shape: shape, padding: padding))
    }

    /// Quick glass card style
    func sbGlassCard(radius: CGFloat = 20) -> some View {
        sbGlass(shape: .roundedRectangle(radius: radius))
    }

    /// Quick glass capsule style (for pills, tags, buttons)
    func sbGlassCapsule() -> some View {
        sbGlass(shape: .capsule, padding: 12)
    }
}

// MARK: - SBGlassCard Container

/// A ready-to-use Glass card container
public struct SBGlassCard<Content: View>: View {
    let content: Content
    let radius: CGFloat
    let padding: CGFloat

    public init(
        radius: CGFloat = 20,
        padding: CGFloat = 20,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.radius = radius
        self.padding = padding
    }

    public var body: some View {
        content
            .sbGlass(
                shape: .roundedRectangle(radius: radius),
                padding: padding
            )
    }
}

// MARK: - SBGlassButton

/// A glass-effect button — perfect for floating action buttons on iOS 26
public struct SBGlassButton: View {
    let label: String
    let icon: String?
    let action: () -> Void

    @Environment(\.sbTheme) private var theme

    public init(_ label: String, icon: String? = nil, action: @escaping () -> Void) {
        self.label = label
        self.icon = icon
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                }
                Text(label)
                    .font(theme.fontButton)
            }
            .foregroundStyle(.primary)
            .sbGlass(shape: .capsule, padding: 14)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - SBFloatingGlassBar

/// Glass floating tab bar — iOS 26 style bottom navigation
public struct SBFloatingGlassBar: View {
    let items: [SBTabItem]
    @Binding var selection: Int

    public init(items: [SBTabItem], selection: Binding<Int>) {
        self.items = items
        self._selection = selection
    }

    public var body: some View {
        HStack(spacing: 0) {
            ForEach(items.indices, id: \.self) { index in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selection = index
                    }
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: selection == index
                              ? items[index].iconFilled
                              : items[index].icon)
                            .font(.system(size: 22, weight: .semibold))
                            .symbolEffect(.bounce, value: selection == index)
                        Text(items[index].title)
                            .font(.system(size: 10, weight: .medium))
                    }
                    .foregroundStyle(selection == index ? .primary : .secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                }
                .buttonStyle(.plain)
            }
        }
        .sbGlass(
            style: .thick,
            shape: .roundedRectangle(radius: 28),
            padding: 4
        )
        .padding(.horizontal, 24)
    }
}

public struct SBTabItem {
    public let title: String
    public let icon: String
    public let iconFilled: String

    public init(title: String, icon: String, iconFilled: String) {
        self.title = title
        self.icon = icon
        self.iconFilled = iconFilled
    }
}
