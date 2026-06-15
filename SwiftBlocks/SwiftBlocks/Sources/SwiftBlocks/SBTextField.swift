// SBTextField.swift
// SwiftBlocks — Input Components

import SwiftUI

// MARK: - Input Style

public enum SBInputStyle {
    case outlined
    case filled
    case underlined
    case glass
}

// MARK: - SBTextField

public struct SBTextField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    let style: SBInputStyle
    let leadingIcon: String?
    let trailingIcon: String?
    let isSecure: Bool
    let errorMessage: String?
    let helperText: String?
    let isDisabled: Bool

    @Environment(\.sbTheme) private var theme
    @FocusState private var isFocused: Bool
    @State private var isRevealed: Bool = false

    public init(
        _ title: String,
        placeholder: String = "",
        text: Binding<String>,
        style: SBInputStyle = .outlined,
        leadingIcon: String? = nil,
        trailingIcon: String? = nil,
        isSecure: Bool = false,
        errorMessage: String? = nil,
        helperText: String? = nil,
        isDisabled: Bool = false
    ) {
        self.title = title
        self.placeholder = placeholder
        self._text = text
        self.style = style
        self.leadingIcon = leadingIcon
        self.trailingIcon = trailingIcon
        self.isSecure = isSecure
        self.errorMessage = errorMessage
        self.helperText = helperText
        self.isDisabled = isDisabled
    }

    private var borderColor: Color {
        if let _ = errorMessage { return theme.error }
        if isFocused { return theme.primary }
        return Color.primary.opacity(0.2)
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Label
            if !title.isEmpty {
                Text(title)
                    .font(theme.fontCaption)
                    .foregroundStyle(isFocused ? theme.primary : .secondary)
                    .animation(.easeInOut(duration: 0.2), value: isFocused)
            }

            // Input row
            HStack(spacing: 10) {
                if let leadingIcon {
                    Image(systemName: leadingIcon)
                        .font(.system(size: 16))
                        .foregroundStyle(isFocused ? theme.primary : .secondary)
                }

                Group {
                    if isSecure && !isRevealed {
                        SecureField(placeholder, text: $text)
                    } else {
                        TextField(placeholder, text: $text)
                    }
                }
                .font(theme.fontBody)
                .focused($isFocused)
                .disabled(isDisabled)

                if isSecure {
                    Button {
                        isRevealed.toggle()
                    } label: {
                        Image(systemName: isRevealed ? "eye.slash" : "eye")
                            .font(.system(size: 16))
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                } else if let trailingIcon {
                    Image(systemName: trailingIcon)
                        .font(.system(size: 16))
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 13)
            .background { inputBackground }
            .opacity(isDisabled ? 0.5 : 1.0)

            // Helper / Error
            if let error = errorMessage {
                Label(error, systemImage: "exclamationmark.circle.fill")
                    .font(theme.fontCaption)
                    .foregroundStyle(theme.error)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            } else if let helper = helperText {
                Text(helper)
                    .font(theme.fontCaption)
                    .foregroundStyle(.secondary)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: errorMessage)
    }

    @ViewBuilder
    private var inputBackground: some View {
        switch style {
        case .outlined:
            RoundedRectangle(cornerRadius: theme.radiusMD, style: .continuous)
                .fill(theme.background)
                .overlay(
                    RoundedRectangle(cornerRadius: theme.radiusMD, style: .continuous)
                        .strokeBorder(borderColor, lineWidth: isFocused ? 2 : 1)
                )
        case .filled:
            RoundedRectangle(cornerRadius: theme.radiusMD, style: .continuous)
                .fill(theme.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: theme.radiusMD, style: .continuous)
                        .strokeBorder(isFocused ? theme.primary : .clear, lineWidth: 2)
                )
        case .underlined:
            VStack(spacing: 0) {
                Spacer()
                Rectangle()
                    .fill(borderColor)
                    .frame(height: isFocused ? 2 : 1)
            }
        case .glass:
            if #available(iOS 26.0, *) {
                RoundedRectangle(cornerRadius: theme.radiusMD, style: .continuous)
                    .glassEffect(.regular)
            } else {
                RoundedRectangle(cornerRadius: theme.radiusMD, style: .continuous)
                    .fill(.regularMaterial)
            }
        }
    }
}

// MARK: - SBSearchBar

public struct SBSearchBar: View {
    @Binding var text: String
    let placeholder: String
    let style: SBInputStyle

    @FocusState private var isFocused: Bool
    @Environment(\.sbTheme) private var theme

    public init(
        text: Binding<String>,
        placeholder: String = "Search...",
        style: SBInputStyle = .filled
    ) {
        self._text = text
        self.placeholder = placeholder
        self.style = style
    }

    public var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.secondary)

            TextField(placeholder, text: $text)
                .font(theme.fontBody)
                .focused($isFocused)

            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 11)
        .background {
            if #available(iOS 26.0, *), style == .glass {
                Capsule().glassEffect(.regular)
            } else {
                Capsule().fill(theme.surface)
            }
        }
        .animation(.spring(response: 0.3), value: text.isEmpty)
    }
}
