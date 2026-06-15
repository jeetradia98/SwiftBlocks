// SBCard.swift
// SwiftBlocks — Card Components

import SwiftUI

// MARK: - Card Style

public enum SBCardStyle {
    case elevated
    case filled
    case outlined
    case glass          // iOS 26 Liquid Glass
}

// MARK: - SBCard

public struct SBCard<Content: View>: View {
    let content: Content
    let style: SBCardStyle
    let radius: CGFloat
    let padding: CGFloat

    @Environment(\.sbTheme) private var theme

    public init(
        style: SBCardStyle = .elevated,
        radius: CGFloat = 16,
        padding: CGFloat = 16,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.style = style
        self.radius = radius
        self.padding = padding
    }

    public var body: some View {
        content
            .padding(padding)
            .background { cardBackground }
            .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
            .shadow(
                color: shadowColor,
                radius: shadowRadius,
                x: 0, y: shadowY
            )
    }

    @ViewBuilder
    private var cardBackground: some View {
        switch style {
        case .elevated:
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .fill(theme.surface)
        case .filled:
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .fill(theme.surface)
        case .outlined:
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .fill(theme.background)
                .overlay(
                    RoundedRectangle(cornerRadius: radius, style: .continuous)
                        .strokeBorder(Color.primary.opacity(0.12), lineWidth: 1)
                )
        case .glass:
            if #available(iOS 26.0, *) {
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .glassEffect(.regular)
            } else {
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .fill(.regularMaterial)
            }
        }
    }

    private var shadowColor: Color {
        switch style {
        case .elevated: return Color.black.opacity(0.08)
        case .glass:    return Color.black.opacity(0.05)
        default:        return .clear
        }
    }

    private var shadowRadius: CGFloat {
        switch style {
        case .elevated: return 12
        case .glass:    return 8
        default:        return 0
        }
    }

    private var shadowY: CGFloat {
        switch style {
        case .elevated: return 4
        case .glass:    return 2
        default:        return 0
        }
    }
}

// MARK: - SBStatCard

/// A metric/stat card for dashboards
public struct SBStatCard: View {
    let title: String
    let value: String
    let subtitle: String?
    let icon: String?
    let trend: SBTrend?
    let style: SBCardStyle

    @Environment(\.sbTheme) private var theme

    public init(
        title: String,
        value: String,
        subtitle: String? = nil,
        icon: String? = nil,
        trend: SBTrend? = nil,
        style: SBCardStyle = .elevated
    ) {
        self.title = title
        self.value = value
        self.subtitle = subtitle
        self.icon = icon
        self.trend = trend
        self.style = style
    }

    public var body: some View {
        SBCard(style: style) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    if let icon {
                        Image(systemName: icon)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(theme.primary)
                            .frame(width: 36, height: 36)
                            .background(theme.primary.opacity(0.12))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    Spacer()
                    if let trend {
                        SBTrendBadge(trend: trend)
                    }
                }

                Text(value)
                    .font(theme.fontTitle)
                    .foregroundStyle(.primary)

                Text(title)
                    .font(theme.fontCaption)
                    .foregroundStyle(.secondary)

                if let subtitle {
                    Text(subtitle)
                        .font(theme.fontCaption)
                        .foregroundStyle(.tertiary)
                }
            }
        }
    }
}

// MARK: - SBTrend

public enum SBTrend {
    case up(String)
    case down(String)
    case neutral(String)

    var icon: String {
        switch self {
        case .up:      return "arrow.up.right"
        case .down:    return "arrow.down.right"
        case .neutral: return "arrow.right"
        }
    }

    var color: Color {
        switch self {
        case .up:      return Color(red: 0.2, green: 0.78, blue: 0.35)
        case .down:    return Color(red: 1.0, green: 0.25, blue: 0.25)
        case .neutral: return .secondary
        }
    }

    var label: String {
        switch self {
        case .up(let s), .down(let s), .neutral(let s): return s
        }
    }
}

public struct SBTrendBadge: View {
    let trend: SBTrend

    public init(trend: SBTrend) {
        self.trend = trend
    }

    public var body: some View {
        HStack(spacing: 3) {
            Image(systemName: trend.icon)
                .font(.system(size: 10, weight: .bold))
            Text(trend.label)
                .font(.system(size: 11, weight: .semibold))
        }
        .foregroundStyle(trend.color)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(trend.color.opacity(0.12))
        .clipShape(Capsule())
    }
}

// MARK: - SBListCard (horizontal scrollable cards)

public struct SBInfoCard: View {
    let title: String
    let description: String
    let icon: String
    let style: SBCardStyle

    @Environment(\.sbTheme) private var theme

    public init(
        title: String,
        description: String,
        icon: String,
        style: SBCardStyle = .elevated
    ) {
        self.title = title
        self.description = description
        self.icon = icon
        self.style = style
    }

    public var body: some View {
        SBCard(style: style) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(theme.primary)
                    .frame(width: 48, height: 48)
                    .background(theme.primary.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 14))

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(theme.fontHeadline)
                        .foregroundStyle(.primary)
                    Text(description)
                        .font(theme.fontCaption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
                Spacer()
            }
        }
    }
}
