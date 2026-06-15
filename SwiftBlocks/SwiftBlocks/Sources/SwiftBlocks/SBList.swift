// SBList.swift
// SwiftBlocks — List & Row Components

import SwiftUI

// MARK: - SBListRow

/// A styled list row with leading icon, title, subtitle, and optional trailing content
public struct SBListRow: View {
    let icon: String?
    let iconColor: Color?
    let title: String
    let subtitle: String?
    let trailingText: String?
    let trailingIcon: String?
    let showChevron: Bool
    let action: (() -> Void)?

    @Environment(\.sbTheme) private var theme

    public init(
        icon: String? = nil,
        iconColor: Color? = nil,
        title: String,
        subtitle: String? = nil,
        trailingText: String? = nil,
        trailingIcon: String? = nil,
        showChevron: Bool = false,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.iconColor = iconColor
        self.title = title
        self.subtitle = subtitle
        self.trailingText = trailingText
        self.trailingIcon = trailingIcon
        self.showChevron = showChevron
        self.action = action
    }

    public var body: some View {
        Button {
            action?()
        } label: {
            HStack(spacing: 14) {
                // Leading icon
                if let icon {
                    let color = iconColor ?? theme.primary
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 36, height: 36)
                        .background(color)
                        .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
                }

                // Title + subtitle
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(theme.fontBody)
                        .foregroundStyle(.primary)
                    if let subtitle {
                        Text(subtitle)
                            .font(theme.fontCaption)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                // Trailing
                if let trailingText {
                    Text(trailingText)
                        .font(theme.fontCaption)
                        .foregroundStyle(.secondary)
                }
                if let trailingIcon {
                    Image(systemName: trailingIcon)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.secondary)
                }
                if showChevron {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color(.tertiaryLabel))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - SBListSection

/// A grouped section with header + rows, matching iOS Settings style
public struct SBListSection<Content: View>: View {
    let header: String?
    let footer: String?
    let content: Content

    @Environment(\.sbTheme) private var theme

    public init(
        header: String? = nil,
        footer: String? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.header = header
        self.footer = footer
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            if let header {
                Text(header.uppercased())
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 6)
            }

            // Rows
            VStack(spacing: 0) {
                content
                    .background(Color(.secondarySystemGroupedBackground))
            }
            .clipShape(RoundedRectangle(cornerRadius: theme.radiusMD, style: .continuous))

            // Dividers between rows handled via _VariadicView or overlay in practice
            // Footer
            if let footer {
                Text(footer)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 16)
                    .padding(.top, 6)
            }
        }
    }
}

// MARK: - SBToggleRow

/// A list row with a toggle switch
public struct SBToggleRow: View {
    let icon: String?
    let iconColor: Color?
    let title: String
    let subtitle: String?
    @Binding var isOn: Bool

    @Environment(\.sbTheme) private var theme

    public init(
        icon: String? = nil,
        iconColor: Color? = nil,
        title: String,
        subtitle: String? = nil,
        isOn: Binding<Bool>
    ) {
        self.icon = icon
        self.iconColor = iconColor
        self.title = title
        self.subtitle = subtitle
        self._isOn = isOn
    }

    public var body: some View {
        HStack(spacing: 14) {
            if let icon {
                let color = iconColor ?? theme.primary
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 36, height: 36)
                    .background(color)
                    .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(theme.fontBody)
                    .foregroundStyle(.primary)
                if let subtitle {
                    Text(subtitle)
                        .font(theme.fontCaption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(theme.primary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

// MARK: - SBSelectRow

/// A list row with a checkmark selection indicator
public struct SBSelectRow: View {
    let title: String
    let subtitle: String?
    let isSelected: Bool
    let action: () -> Void

    @Environment(\.sbTheme) private var theme

    public init(
        title: String,
        subtitle: String? = nil,
        isSelected: Bool,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.subtitle = subtitle
        self.isSelected = isSelected
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(theme.fontBody)
                        .foregroundStyle(.primary)
                    if let subtitle {
                        Text(subtitle)
                            .font(theme.fontCaption)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(theme.primary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - SBContactRow

/// A row for displaying a contact/user with avatar, name, and role
public struct SBContactRow: View {
    let name: String
    let role: String?
    let initials: String
    let avatarColor: Color?
    let trailingIcon: String?
    let action: (() -> Void)?

    @Environment(\.sbTheme) private var theme

    public init(
        name: String,
        role: String? = nil,
        initials: String? = nil,
        avatarColor: Color? = nil,
        trailingIcon: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.name = name
        self.role = role
        self.initials = initials ?? String(name.prefix(2)).uppercased()
        self.avatarColor = avatarColor
        self.trailingIcon = trailingIcon
        self.action = action
    }

    public var body: some View {
        Button {
            action?()
        } label: {
            HStack(spacing: 12) {
                // Avatar circle
                Text(initials)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(avatarColor ?? theme.primary)
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 2) {
                    Text(name)
                        .font(theme.fontBody)
                        .foregroundStyle(.primary)
                    if let role {
                        Text(role)
                            .font(theme.fontCaption)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                if let trailingIcon {
                    Image(systemName: trailingIcon)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(theme.primary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
