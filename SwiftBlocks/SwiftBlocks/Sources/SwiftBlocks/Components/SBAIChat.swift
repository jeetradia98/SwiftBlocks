// SBAIChat.swift
// SwiftBlocks — AI & Chat Components

import SwiftUI

// MARK: - SBChatMessage


public enum SBRadius {
   public static let card:    CGFloat = 20
    public static let tabBar:  CGFloat = 28
    public static let button:  CGFloat = 14
    public static let chip:    CGFloat = 99
    public static let sheet:   CGFloat = 24
}

public struct SBChatMessage: Identifiable {
    public let id = UUID()
    public let content: String
    public let isUser: Bool
    public let timestamp: Date

    public init(content: String, isUser: Bool, timestamp: Date = .now) {
        self.content = content
        self.isUser = isUser
        self.timestamp = timestamp
    }
}

// MARK: - SBChatBubble

/// A chat bubble — user (trailing) or assistant (leading)
public struct SBChatBubble: View {
    let message: SBChatMessage
    let showTimestamp: Bool

    @Environment(\.sbTheme) private var theme

    public init(_ message: SBChatMessage, showTimestamp: Bool = false) {
        self.message = message
        self.showTimestamp = showTimestamp
    }

    public var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if message.isUser { Spacer(minLength: 50) }

            if !message.isUser {
                ZStack {
                    Circle()
                        .fill(theme.primary.opacity(0.15))
                        .frame(width: 30, height: 30)
                    Image(systemName: "sparkles")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(theme.primary)
                }
            }

            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .font(theme.fontBody)
                    .foregroundStyle(message.isUser ? .white : .primary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background {
                        if message.isUser {
                            // ✅ Solid fill — always clear, never glass
                            BubbleShape(isUser: true)
                                .fill(theme.primary)
                        } else {
                            // ✅ Simple filled surface — no glass-on-glass conflict
                            BubbleShape(isUser: false)
                                .fill(Color(.systemGray5))
                        }
                    }

                if showTimestamp {
                    Text(message.timestamp, style: .time)
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                }
            }

            if !message.isUser { Spacer(minLength: 50) }
        }
    }
}

private struct BubbleShape: Shape {
    let isUser: Bool
    func path(in rect: CGRect) -> Path {
        let r: CGFloat = 16
        let tailR: CGFloat = 4
        var path = Path()
        if isUser {
            path.addRoundedRect(in: rect, cornerSize: CGSize(width: r, height: r))
        } else {
            path.addRoundedRect(in: rect, cornerSize: CGSize(width: r, height: r))
        }
        return path
    }
}

// MARK: - SBTypingIndicator

/// An animated "..." typing indicator for AI responses
public struct SBTypingIndicator: View {
    @State private var phase = 0
    @Environment(\.sbTheme) private var theme

    public init() {}

    public var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            ZStack {
                Circle()
                    .fill(theme.primary.opacity(0.15))
                    .frame(width: 30, height: 30)
                Image(systemName: "sparkles")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(theme.primary)
            }

            HStack(spacing: 4) {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .fill(Color(.systemGray3))
                        .frame(width: 7, height: 7)
                        .scaleEffect(phase == index ? 1.3 : 0.8)
                        .animation(
                            .easeInOut(duration: 0.4)
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.15),
                            value: phase
                        )
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background {
                if #available(iOS 26.0, *) {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .glassEffect(.regular)
                } else {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(.regularMaterial)
                }
            }

            Spacer()
        }
        .onAppear {
            withAnimation { phase = 1 }
        }
    }
}

// MARK: - SBChatInputBar

/// The bottom input bar for a chat interface
public struct SBChatInputBar: View {
    @Binding var text: String
    let placeholder: String
    let isLoading: Bool
    let onSend: () -> Void

    @FocusState private var isFocused: Bool
    @Environment(\.sbTheme) private var theme

    public init(
        text: Binding<String>,
        placeholder: String = "Message...",
        isLoading: Bool = false,
        onSend: @escaping () -> Void
    ) {
        self._text = text
        self.placeholder = placeholder
        self.isLoading = isLoading
        self.onSend = onSend
    }

    private var canSend: Bool { !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isLoading }

    public var body: some View {
        HStack(spacing: 10) {
            TextField(placeholder, text: $text, axis: .vertical)
                .font(theme.fontBody)
                .focused($isFocused)
                .lineLimit(1...5)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background {
                    if #available(iOS 26.0, *) {
                        Capsule().glassEffect(.regular)
                    } else {
                        Capsule().fill(theme.surface)
                    }
                }

            Button {
                guard canSend else { return }
                onSend()
            } label: {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                        .frame(width: 44, height: 44)
                        .background(theme.primary)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                        .background(canSend ? theme.primary : Color(.systemGray4))
                        .clipShape(Circle())
                        .animation(.spring(response: 0.25), value: canSend)
                }
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background {
            if #available(iOS 26.0, *) {
                Rectangle().glassEffect(.regular)
            } else {
                Rectangle().fill(.regularMaterial)
            }
        }
    }
}

// MARK: - SBAIFeatureCard

/// A card showcasing an AI feature with icon, title, and description
public struct SBAIFeatureCard: View {
    let icon: String
    let title: String
    let description: String
    let accentColor: Color?
    let action: (() -> Void)?

    @Environment(\.sbTheme) private var theme

    public init(
        icon: String,
        title: String,
        description: String,
        accentColor: Color? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.description = description
        self.accentColor = accentColor
        self.action = action
    }

    public var body: some View {
        Button {
            action?()
        } label: {
            SBCard(style: .glass, radius: 16) {
                HStack(spacing: 14) {
                    let color = accentColor ?? theme.primary
                    ZStack {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(color.opacity(0.15))
                            .frame(width: 48, height: 48)
                        Image(systemName: icon)
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundStyle(color)
                    }

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

                    if action != nil {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(.tertiary)
                    }
                }
                
            }
            // ✅ Single nativeGlass call — one shape, one radius, no double border
            .nativeGlass(cornerRadius: SBRadius.card)
        }
        .buttonStyle(.plain)
    }
}

extension View {
    @ViewBuilder
    public func nativeGlass(cornerRadius: CGFloat = SBRadius.card) -> some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        if #available(iOS 26, *) {
            self.glassEffect(in: shape)
        } else {
            self
                .background(
                    shape.fill(.ultraThinMaterial)
                        .overlay(shape.strokeBorder(.white.opacity(0.12), lineWidth: 0.5))
                )
                .clipShape(shape)
        }
    }
}

// MARK: - SBPromptSuggestion

/// A row of tappable prompt suggestion pills
public struct SBPromptSuggestions: View {
    let prompts: [String]
    let onSelect: (String) -> Void

    @Environment(\.sbTheme) private var theme

    public init(prompts: [String], onSelect: @escaping (String) -> Void) {
        self.prompts = prompts
        self.onSelect = onSelect
    }

    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(prompts, id: \.self) { prompt in
                    Button { onSelect(prompt) } label: {
                        Text(prompt)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(theme.primary)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background {
                                if #available(iOS 26.0, *) {
                                    Capsule().glassEffect(.regular)
                                } else {
                                    Capsule().fill(theme.primary.opacity(0.08))
                                        .overlay(Capsule().strokeBorder(theme.primary.opacity(0.2), lineWidth: 1))
                                }
                            }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
        }
    }
}
