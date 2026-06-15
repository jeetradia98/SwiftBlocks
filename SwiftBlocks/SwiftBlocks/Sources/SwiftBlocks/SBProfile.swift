// SBProfile.swift
// SwiftBlocks — Profile & Avatar Components

import SwiftUI

// MARK: - SBAvatar

public enum SBAvatarSize {
    case small, medium, large, xlarge

    var diameter: CGFloat {
        switch self {
        case .small:  return 32
        case .medium: return 48
        case .large:  return 72
        case .xlarge: return 100
        }
    }

    var fontSize: CGFloat {
        switch self {
        case .small:  return 12
        case .medium: return 18
        case .large:  return 26
        case .xlarge: return 36
        }
    }
}

/// A circular avatar showing initials or a system icon
public struct SBAvatar: View {
    let name: String
    let icon: String?
    let size: SBAvatarSize
    let color: Color?
    let showBadge: Bool
    let badgeColor: Color

    @Environment(\.sbTheme) private var theme

    public init(
        name: String,
        icon: String? = nil,
        size: SBAvatarSize = .medium,
        color: Color? = nil,
        showBadge: Bool = false,
        badgeColor: Color = Color(red: 0.2, green: 0.78, blue: 0.35)
    ) {
        self.name = name
        self.icon = icon
        self.size = size
        self.color = color
        self.showBadge = showBadge
        self.badgeColor = badgeColor
    }

    private var initials: String {
        let parts = name.split(separator: " ")
        if parts.count >= 2 {
            return String(parts[0].prefix(1) + parts[1].prefix(1)).uppercased()
        }
        return String(name.prefix(2)).uppercased()
    }

    private var bg: Color { color ?? theme.primary }

    public var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Circle()
                .fill(bg.opacity(0.2))
                .frame(width: size.diameter, height: size.diameter)
                .overlay {
                    if let icon {
                        Image(systemName: icon)
                            .font(.system(size: size.fontSize, weight: .semibold))
                            .foregroundStyle(bg)
                    } else {
                        Text(initials)
                            .font(.system(size: size.fontSize, weight: .bold))
                            .foregroundStyle(bg)
                    }
                }

            // Online badge
            if showBadge {
                Circle()
                    .fill(badgeColor)
                    .frame(width: size.diameter * 0.22, height: size.diameter * 0.22)
                    .overlay(Circle().strokeBorder(.white, lineWidth: 1.5))
            }
        }
    }
}

// MARK: - SBAvatarStack

/// A horizontal stack of overlapping avatars
public struct SBAvatarStack: View {
    let names: [String]
    let colors: [Color]
    let size: SBAvatarSize
    let maxVisible: Int

    @Environment(\.sbTheme) private var theme

    public init(
        names: [String],
        colors: [Color] = [],
        size: SBAvatarSize = .small,
        maxVisible: Int = 4
    ) {
        self.names = names
        self.colors = colors
        self.size = size
        self.maxVisible = maxVisible
    }

    private let palette: [Color] = [
        Color(red: 0.2, green: 0.4, blue: 1.0),
        Color(red: 0.5, green: 0.3, blue: 0.9),
        Color(red: 0.0, green: 0.8, blue: 0.7),
        Color(red: 1.0, green: 0.5, blue: 0.2),
        Color(red: 0.9, green: 0.2, blue: 0.5)
    ]

    public var body: some View {
        let visible = Array(names.prefix(maxVisible))
        let overflow = names.count - maxVisible

        HStack(spacing: -(size.diameter * 0.3)) {
            ForEach(visible.indices, id: \.self) { index in
                let c = colors.indices.contains(index) ? colors[index] : palette[index % palette.count]
                SBAvatar(name: visible[index], size: size, color: c)
                    .overlay(Circle().strokeBorder(.white, lineWidth: 2))
                    .zIndex(Double(visible.count - index))
            }

            if overflow > 0 {
                Circle()
                    .fill(Color(.systemGray4))
                    .frame(width: size.diameter, height: size.diameter)
                    .overlay {
                        Text("+\(overflow)")
                            .font(.system(size: size.fontSize * 0.8, weight: .semibold))
                            .foregroundStyle(.secondary)
                    }
                    .overlay(Circle().strokeBorder(.white, lineWidth: 2))
            }
        }
    }
}

// MARK: - SBProfileHeader

/// Full profile header: avatar, name, bio, stats
public struct SBProfileHeader: View {
    let name: String
    let username: String?
    let bio: String?
    let stats: [SBProfileStat]
    let avatarColor: Color?
    let actionTitle: String?
    let action: (() -> Void)?

    @Environment(\.sbTheme) private var theme

    public init(
        name: String,
        username: String? = nil,
        bio: String? = nil,
        stats: [SBProfileStat] = [],
        avatarColor: Color? = nil,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.name = name
        self.username = username
        self.bio = bio
        self.stats = stats
        self.avatarColor = avatarColor
        self.actionTitle = actionTitle
        self.action = action
    }

    public var body: some View {
        VStack(spacing: theme.spacingMD) {
            // Avatar
            SBAvatar(name: name, size: .xlarge, color: avatarColor)

            // Name + username
            VStack(spacing: 4) {
                Text(name)
                    .font(theme.fontTitle)
                    .foregroundStyle(.primary)
                if let username {
                    Text("@\(username)")
                        .font(theme.fontBody)
                        .foregroundStyle(.secondary)
                }
                if let bio {
                    Text(bio)
                        .font(theme.fontBody)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.top, 4)
                }
            }

            // Stats row
            if !stats.isEmpty {
                HStack(spacing: 0) {
                    ForEach(stats.indices, id: \.self) { index in
                        SBProfileStatView(stat: stats[index])
                        if index < stats.count - 1 {
                            Divider().frame(height: 32)
                        }
                    }
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .background(theme.surface)
                .clipShape(RoundedRectangle(cornerRadius: theme.radiusMD, style: .continuous))
            }

            // Action button
            if let actionTitle, let action {
                SBButton(actionTitle, style: .primary, isFullWidth: true, action: action)
            }
        }
        .padding(theme.spacingMD)
    }
}

// MARK: - SBProfileStat

public struct SBProfileStat {
    public let value: String
    public let label: String

    public init(value: String, label: String) {
        self.value = value
        self.label = label
    }
}

struct SBProfileStatView: View {
    let stat: SBProfileStat
    @Environment(\.sbTheme) private var theme

    var body: some View {
        VStack(spacing: 2) {
            Text(stat.value)
                .font(theme.fontHeadline)
                .foregroundStyle(.primary)
            Text(stat.label)
                .font(theme.fontCaption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}
