// SBFeedback.swift
// SwiftBlocks — Feedback Components (Toast, Badge, EmptyState, StatusBanner)

import SwiftUI

// MARK: - Toast

public enum SBToastType {
    case success, error, warning, info

    var icon: String {
        switch self {
        case .success: return "checkmark.circle.fill"
        case .error:   return "xmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .info:    return "info.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .success: return Color(red: 0.2, green: 0.78, blue: 0.35)
        case .error:   return Color(red: 1.0, green: 0.25, blue: 0.25)
        case .warning: return Color(red: 1.0, green: 0.75, blue: 0.0)
        case .info:    return Color(red: 0.2, green: 0.4, blue: 1.0)
        }
    }
}

public struct SBToast: View {
    let message: String
    let type: SBToastType

    public init(_ message: String, type: SBToastType = .info) {
        self.message = message
        self.type = type
    }

    public var body: some View {
        HStack(spacing: 10) {
            Image(systemName: type.icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(type.color)

            Text(message)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.primary)
                .lineLimit(2)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background {
            if #available(iOS 26.0, *) {
                Capsule().glassEffect(.regular)
            } else {
                Capsule().fill(.regularMaterial)
            }
        }
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
        .padding(.horizontal, 20)
    }
}

// MARK: - Toast ViewModifier

// MARK: - Toast ViewModifier

struct SBToastModifier: ViewModifier {
    @Binding var isPresented: Bool
    let message: String
    let type: SBToastType

    func body(content: Content) -> some View {
        ZStack {
            content
        }
        .overlay(alignment: .top) {
            if isPresented {
                SBToast(message, type: type)
                    // ✅ Push below the navigation bar + status bar
                    .padding(.top, {
                        if #available(iOS 26, *) {
                            return 0.0
                        } else {
                            return 60.0
                        }
                    }())
                    .padding(.horizontal, 16)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(999)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            withAnimation(.spring(response: 0.4)) {
                                isPresented = false
                            }
                        }
                    }
            }
        }
        .animation(.spring(response: 0.4), value: isPresented)
    }
}

public extension View {
    func sbToast(
        isPresented: Binding<Bool>,
        message: String,
        type: SBToastType = .info,
        duration: Double = 3.0
    ) -> some View {
        modifier(SBToastModifier(
            isPresented: isPresented,
            message: message,
            type: type
        ))
    }
}

// MARK: - SBBadge

public enum SBBadgeStyle {
    case filled, outlined, soft
}

public struct SBBadge: View {
    let label: String
    let color: Color
    let style: SBBadgeStyle

    public init(
        _ label: String,
        color: Color = Color(red: 0.2, green: 0.4, blue: 1.0),
        style: SBBadgeStyle = .soft
    ) {
        self.label = label
        self.color = color
        self.style = style
    }

    public var body: some View {
        Text(label)
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(foregroundColor)
            .padding(.horizontal, 9)
            .padding(.vertical, 4)
            .background(backgroundView)
    }

    private var foregroundColor: Color {
        switch style {
        case .filled:   return .white
        case .outlined: return color
        case .soft:     return color
        }
    }

    @ViewBuilder
    private var backgroundView: some View {
        switch style {
        case .filled:
            Capsule().fill(color)
        case .outlined:
            Capsule()
                .strokeBorder(color, lineWidth: 1.5)
        case .soft:
            Capsule().fill(color.opacity(0.15))
        }
    }
}

// MARK: - SBEmptyState

public struct SBEmptyState: View {
    let icon: String
    let title: String
    let description: String
    let actionTitle: String?
    let action: (() -> Void)?

    @Environment(\.sbTheme) private var theme

    public init(
        icon: String = "tray",
        title: String,
        description: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.description = description
        self.actionTitle = actionTitle
        self.action = action
    }

    public var body: some View {
        VStack(spacing: theme.spacingMD) {
            Spacer()

            Image(systemName: icon)
                .font(.system(size: 52, weight: .light))
                .foregroundStyle(theme.primary.opacity(0.5))
                .symbolEffect(.pulse)

            VStack(spacing: 8) {
                Text(title)
                    .font(theme.fontHeadline)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)

                Text(description)
                    .font(theme.fontBody)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, theme.spacingXL)
            }

            if let actionTitle, let action {
                SBButton(actionTitle, style: .primary, action: action)
                    .padding(.top, 8)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - SBStatusBanner

public struct SBStatusBanner: View {
    let message: String
    let type: SBToastType
    let isDismissible: Bool
    @State private var isDismissed = false

    public init(
        _ message: String,
        type: SBToastType = .info,
        isDismissible: Bool = true
    ) {
        self.message = message
        self.type = type
        self.isDismissible = isDismissible
    }

    public var body: some View {
        if !isDismissed {
            HStack(spacing: 10) {
                Image(systemName: type.icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(type.color)

                Text(message)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if isDismissible {
                    Button {
                        withAnimation { isDismissed = true }
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(type.color.opacity(0.1))
            .overlay(
                Rectangle()
                    .fill(type.color)
                    .frame(width: 4),
                alignment: .leading
            )
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }
}
