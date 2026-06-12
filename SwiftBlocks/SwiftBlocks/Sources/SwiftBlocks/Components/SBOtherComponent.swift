//
//  SBOtherComponent.swift
//  SwiftBlocks
//
//  Created by priyal on 11/06/26.
//

import SwiftUI

// MARK: - SBChip

/// Tappable chip/tag — dismissible or selectable
public struct SBChip: View {
    let label: String
    let icon: String?
    let isSelected: Bool
    let onTap: () -> Void
    let onDismiss: (() -> Void)?

    @Environment(\.sbTheme) private var theme

    public init(
        _ label: String,
        icon: String? = nil,
        isSelected: Bool = false,
        onDismiss: (() -> Void)? = nil,
        onTap: @escaping () -> Void = {}
    ) {
        self.label = label
        self.icon = icon
        self.isSelected = isSelected
        self.onDismiss = onDismiss
        self.onTap = onTap
    }

    public var body: some View {
        Button(action: onTap) {
            HStack(spacing: 6) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 12, weight: .medium))
                }
                Text(label)
                    .font(.system(size: 13, weight: .medium))
                if let onDismiss {
                    Button(action: onDismiss) {
                        Image(systemName: "xmark")
                            .font(.system(size: 10, weight: .bold))
                    }
                    .buttonStyle(.plain)
                }
            }
            .foregroundStyle(isSelected ? .white : theme.primary)
            .padding(.horizontal, 14)
            .padding(.vertical, 7)
            .background(
                Capsule()
                    .fill(isSelected ? theme.primary : theme.primary.opacity(0.1))
                    .overlay(
                        Capsule()
                            .strokeBorder(theme.primary.opacity(isSelected ? 0 : 0.25), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - SBOTPInput
public struct SBOTPInput: View {
    let length: Int
    @Binding var code: String
    let onComplete: (String) -> Void

    @FocusState private var isFocused: Bool
    @State private var cursorVisible = true
    @Environment(\.sbTheme) private var theme

    public init(length: Int = 6, code: Binding<String>, onComplete: @escaping (String) -> Void = { _ in }) {
        self.length = length
        self._code = code
        self.onComplete = onComplete
    }

    public var body: some View {
        ZStack {
            // ✅ Real TextField — full size, truly transparent, sits on top of everything
            TextField("", text: Binding(
                get: { code },
                set: { new in
                    let filtered = String(new.filter(\.isNumber).prefix(length))
                    code = filtered
                    if filtered.count == length { onComplete(filtered) }
                }
            ))
            .keyboardType(.numberPad)
            .textContentType(.oneTimeCode)
            .focused($isFocused)
            // ✅ Make text invisible — the boxes show the characters instead
            .foregroundStyle(.clear)
            .tint(.clear)
            .accentColor(.clear)
            // ✅ Fill entire ZStack so any tap anywhere hits it
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            // ✅ No opacity trick — fully present in hit-test tree
            .background(Color.clear)

            // Visual boxes — pointer events disabled, TextField above handles all taps
            HStack(spacing: 10) {
                ForEach(0..<length, id: \.self) { i in
                    let char: String = i < code.count
                        ? String(code[code.index(code.startIndex, offsetBy: i)])
                        : ""
                    let isActive = isFocused && i == min(code.count, length - 1)

                    ZStack {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color(.secondarySystemBackground))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .strokeBorder(
                                        isActive ? theme.primary : Color(.systemGray4),
                                        lineWidth: isActive ? 2 : 1
                                    )
                            )

                        if char.isEmpty && isActive {
                            // Blinking cursor
                            Rectangle()
                                .fill(theme.primary)
                                .frame(width: 2, height: 26)
                                .opacity(cursorVisible ? 1 : 0)
                        } else {
                            Text(char)
                                .font(.system(size: 22, weight: .semibold, design: .monospaced))
                                .foregroundStyle(.primary)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .animation(.spring(response: 0.2), value: isActive)
                }
            }
            // ✅ Boxes sit below TextField in ZStack — they're visual only
            .allowsHitTesting(false)
        }
        // ✅ Fixed height so ZStack doesn't collapse
        .frame(height: 56)
        .onTapGesture { isFocused = true }
        .onAppear {
            // Start cursor blink loop
            withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                cursorVisible = false
            }
        }
        .onChange(of: isFocused) { _, focused in
            if focused {
                withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                    cursorVisible = false
                }
            }
        }
    }
}

// MARK: - SBSnackbar

public enum SBSnackbarAction {
    case none
    case button(label: String, action: () -> Void)
}

/// Bottom snackbar — brief message with optional action
public struct SBSnackbar: View {
    let message: String
    let action: SBSnackbarAction
    @Binding var isPresented: Bool

    @Environment(\.sbTheme) private var theme

    public init(message: String, action: SBSnackbarAction = .none, isPresented: Binding<Bool>) {
        self.message = message
        self.action = action
        self._isPresented = isPresented
    }

    public var body: some View {
        HStack(spacing: 12) {
            Text(message)
                .font(theme.fontBody)
                .foregroundStyle(.white)
                .lineLimit(2)

            Spacer()

            if case .button(let label, let act) = action {
                Button(label, action: act)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(theme.primary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: SBRadius.button, style: .continuous)
                .fill(Color(.label))
        )
        .padding(.horizontal, 16)
    }
}

// Modifier
struct SBSnackbarModifier: ViewModifier {
    @Binding var isPresented: Bool
    let message: String
    let action: SBSnackbarAction

    func body(content: Content) -> some View {
        ZStack {
            content
            if isPresented {
                VStack {
                    Spacer()
                    SBSnackbar(message: message, action: action, isPresented: $isPresented)
                        .padding(.bottom, 100)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                withAnimation(.spring(response: 0.4)) { isPresented = false }
                            }
                        }
                }
                .animation(.spring(response: 0.4), value: isPresented)
            }
        }
    }
}

extension View {
    public func sbSnackbar(isPresented: Binding<Bool>, message: String, action: SBSnackbarAction = .none) -> some View {
        modifier(SBSnackbarModifier(isPresented: isPresented, message: message, action: action))
    }
}

// MARK: - SBAlert

/// Custom in-app alert overlay
public struct SBAlert: View {
    let title: String
    let message: String
    let icon: String?
    let iconColor: Color
    let primaryLabel: String
    let primaryAction: () -> Void
    let secondaryLabel: String?
    let secondaryAction: (() -> Void)?
    @Binding var isPresented: Bool

    @Environment(\.sbTheme) private var theme

    public init(
        title: String,
        message: String,
        icon: String? = nil,
        iconColor: Color = .blue,
        primaryLabel: String = "OK",
        primaryAction: @escaping () -> Void = {},
        secondaryLabel: String? = nil,
        secondaryAction: (() -> Void)? = nil,
        isPresented: Binding<Bool>
    ) {
        self.title = title
        self.message = message
        self.icon = icon
        self.iconColor = iconColor
        self.primaryLabel = primaryLabel
        self.primaryAction = primaryAction
        self.secondaryLabel = secondaryLabel
        self.secondaryAction = secondaryAction
        self._isPresented = isPresented
    }

    public var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture { withAnimation { isPresented = false } }

            VStack(spacing: 20) {
                if let icon {
                    ZStack {
                        Circle()
                            .fill(iconColor.opacity(0.12))
                            .frame(width: 64, height: 64)
                        Image(systemName: icon)
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundStyle(iconColor)
                    }
                }

                VStack(spacing: 8) {
                    Text(title)
                        .font(theme.fontTitle)
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.center)
                    Text(message)
                        .font(theme.fontBody)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }

                VStack(spacing: 10) {
                    Button {
                        primaryAction()
                        withAnimation { isPresented = false }
                    } label: {
                        Text(primaryLabel)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(theme.primary)
                            .clipShape(RoundedRectangle(cornerRadius: SBRadius.button, style: .continuous))
                    }

                    if let secondaryLabel {
                        Button {
                            secondaryAction?()
                            withAnimation { isPresented = false }
                        } label: {
                            Text(secondaryLabel)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color(.secondarySystemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: SBRadius.button, style: .continuous))
                        }
                    }
                }
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: SBRadius.sheet, style: .continuous)
                    .fill(Color(.systemBackground))
            )
            .padding(.horizontal, 32)
            .transition(.scale(scale: 0.9).combined(with: .opacity))
        }
    }
}

// Modifier
struct SBAlertModifier: ViewModifier {
    @Binding var isPresented: Bool
    let title: String
    let message: String
    let icon: String?
    let iconColor: Color
    let primaryLabel: String
    let primaryAction: () -> Void
    let secondaryLabel: String?
    let secondaryAction: (() -> Void)?

    func body(content: Content) -> some View {
        ZStack {
            content
            if isPresented {
                SBAlert(
                    title: title, message: message,
                    icon: icon, iconColor: iconColor,
                    primaryLabel: primaryLabel, primaryAction: primaryAction,
                    secondaryLabel: secondaryLabel, secondaryAction: secondaryAction,
                    isPresented: $isPresented
                )
                .zIndex(999)
                .animation(.spring(response: 0.35), value: isPresented)
            }
        }
    }
}

extension View {
    public func sbAlert(
        isPresented: Binding<Bool>,
        title: String,
        message: String,
        icon: String? = nil,
        iconColor: Color = .blue,
        primaryLabel: String = "OK",
        primaryAction: @escaping () -> Void = {},
        secondaryLabel: String? = nil,
        secondaryAction: (() -> Void)? = nil
    ) -> some View {
        modifier(SBAlertModifier(
            isPresented: isPresented,
            title: title, message: message,
            icon: icon, iconColor: iconColor,
            primaryLabel: primaryLabel, primaryAction: primaryAction,
            secondaryLabel: secondaryLabel, secondaryAction: secondaryAction
        ))
    }
}

// MARK: - SBSuccessState

public struct SBSuccessState: View {
    let title: String
    let description: String
    let actionTitle: String?
    let action: (() -> Void)?

    @Environment(\.sbTheme) private var theme

    public init(
        title: String = "All Done!",
        description: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.description = description
        self.actionTitle = actionTitle
        self.action = action
    }

    public var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle().fill(Color.green.opacity(0.12)).frame(width: 72, height: 72)
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(.green)
            }
            Text(title).font(theme.fontTitle).foregroundStyle(.primary)
            Text(description).font(theme.fontBody).foregroundStyle(.secondary).multilineTextAlignment(.center)
            if let actionTitle, let action {
                SBButton(actionTitle, style: .primary) { action() }
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - SBErrorState

public struct SBErrorState: View {
    let title: String
    let description: String
    let actionTitle: String?
    let action: (() -> Void)?

    @Environment(\.sbTheme) private var theme

    public init(
        title: String = "Something went wrong",
        description: String,
        actionTitle: String? = "Try Again",
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.description = description
        self.actionTitle = actionTitle
        self.action = action
    }

    public var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle().fill(Color.red.opacity(0.12)).frame(width: 72, height: 72)
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(.red)
            }
            Text(title).font(theme.fontTitle).foregroundStyle(.primary)
            Text(description).font(theme.fontBody).foregroundStyle(.secondary).multilineTextAlignment(.center)
            if let actionTitle, let action {
                SBButton(actionTitle, style: .destructive) { action() }
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - SBAIPromptBar

/// Standalone AI prompt input bar — simpler than SBChatInputBar,
/// designed for single-shot prompts (not conversation threads)
public struct SBAIPromptBar: View {
    @Binding var text: String
    let placeholder: String
    let suggestions: [String]
    let isLoading: Bool
    let onSubmit: (String) -> Void

    @FocusState private var isFocused: Bool
    @Environment(\.sbTheme) private var theme

    public init(
        text: Binding<String>,
        placeholder: String = "Ask AI anything...",
        suggestions: [String] = [],
        isLoading: Bool = false,
        onSubmit: @escaping (String) -> Void
    ) {
        self._text = text
        self.placeholder = placeholder
        self.suggestions = suggestions
        self.isLoading = isLoading
        self.onSubmit = onSubmit
    }

    private var canSubmit: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isLoading
    }

    public var body: some View {
        VStack(spacing: 10) {
            // Suggestion pills
            if !suggestions.isEmpty && !isFocused {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(suggestions, id: \.self) { s in
                            Button { text = s } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: "sparkles")
                                        .font(.system(size: 11, weight: .medium))
                                    Text(s)
                                        .font(.system(size: 13, weight: .medium))
                                }
                                .foregroundStyle(theme.primary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 7)
                                .background(
                                    Capsule().fill(theme.primary.opacity(0.08))
                                        .overlay(Capsule().strokeBorder(theme.primary.opacity(0.2), lineWidth: 1))
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 4)
                }
            }

            // Input row
            HStack(spacing: 10) {
                Image(systemName: "sparkles")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(theme.primary)

                TextField(placeholder, text: $text, axis: .vertical)
                    .font(theme.fontBody)
                    .focused($isFocused)
                    .lineLimit(1...4)

                Button {
                    guard canSubmit else { return }
                    onSubmit(text)
                } label: {
                    if isLoading {
                        ProgressView()
                            .tint(.white)
                            .frame(width: 36, height: 36)
                            .background(theme.primary)
                            .clipShape(Circle())
                    } else {
                        Image(systemName: "arrow.up")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 36, height: 36)
                            .background(canSubmit ? theme.primary : Color(.systemGray4))
                            .clipShape(Circle())
                            .animation(.spring(response: 0.25), value: canSubmit)
                    }
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: SBRadius.chip, style: .continuous)
                    .fill(Color(.secondarySystemBackground))
                    .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
            )
        }
    }
}

// MARK: - SBPasswordField

/// Dedicated password field with show/hide toggle
public struct SBPasswordField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var errorMessage: String?

    @State private var isVisible = false
    @Environment(\.sbTheme) private var theme

    public init(
        _ label: String,
        placeholder: String = "Enter password",
        text: Binding<String>,
        errorMessage: String? = nil
    ) {
        self.label = label
        self.placeholder = placeholder
        self._text = text
        self.errorMessage = errorMessage
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if !label.isEmpty {
                Text(label)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 10) {
                Image(systemName: "lock")
                    .font(.system(size: 15))
                    .foregroundStyle(.secondary)
                    .frame(width: 20)

                Group {
                    if isVisible {
                        TextField(placeholder, text: $text)
                    } else {
                        SecureField(placeholder, text: $text)
                    }
                }
                .font(theme.fontBody)

                Button {
                    isVisible.toggle()
                } label: {
                    Image(systemName: isVisible ? "eye.slash" : "eye")
                        .font(.system(size: 15))
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: SBRadius.button, style: .continuous)
                    .fill(Color(.secondarySystemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: SBRadius.button, style: .continuous)
                            .strokeBorder(
                                errorMessage != nil ? Color.red.opacity(0.6) : Color(.systemGray4),
                                lineWidth: 1
                            )
                    )
            )

            if let error = errorMessage {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.circle")
                        .font(.system(size: 11))
                    Text(error)
                        .font(.system(size: 12))
                }
                .foregroundStyle(.red)
            }
        }
    }
}

public struct SBSettingsRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String?
    let trailingText: String?
    let showChevron: Bool
    let action: (() -> Void)?

    @Environment(\.sbTheme) private var theme

    public init(
        icon: String,
        iconColor: Color = .blue,
        title: String,
        subtitle: String? = nil,
        trailingText: String? = nil,
        showChevron: Bool = true,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.iconColor = iconColor
        self.title = title
        self.subtitle = subtitle
        self.trailingText = trailingText
        self.showChevron = showChevron
        self.action = action
    }

    public var body: some View {
        Button {
            action?()
        } label: {
            HStack(spacing: 14) {
                // Icon badge
                ZStack {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(iconColor)
                        .frame(width: 32, height: 32)
                    Image(systemName: icon)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.white)
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

                // Trailing text
                if let trailingText {
                    Text(trailingText)
                        .font(theme.fontCaption)
                        .foregroundStyle(.secondary)
                }

                // Chevron
                if showChevron {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color(.systemGray3))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .buttonStyle(.plain)
    }
}

import SwiftUI

// MARK: - Toolbar Item Model

public struct SBToolbarAction: Identifiable {
    public let id = UUID()
    public let icon: String
    public let label: String
    public let action: () -> Void

    public init(_ label: String, icon: String, action: @escaping () -> Void) {
        self.label = label
        self.icon = icon
        self.action = action
    }
}

// MARK: - Toolbar Style

public enum SBToolbarStyle {
    case standard      // plain system buttons
    case glass         // .buttonStyle(.glass) on iOS 26
    case grouped       // items share one glass background pill
}

// MARK: - SBToolbar Modifier

public struct SBToolbarModifier: ViewModifier {
    let title: String
    let subtitle: String?
    let leading: [SBToolbarAction]
    let trailing: [SBToolbarAction]
    let style: SBToolbarStyle
    let useToolbarSpacer: Bool  // ✅ ToolbarSpacer between groups on iOS 26

    public init(
        title: String,
        subtitle: String? = nil,
        leading: [SBToolbarAction] = [],
        trailing: [SBToolbarAction] = [],
        style: SBToolbarStyle = .glass,
        useToolbarSpacer: Bool = false
    ) {
        self.title = title
        self.subtitle = subtitle
        self.leading = leading
        self.trailing = trailing
        self.style = style
        self.useToolbarSpacer = useToolbarSpacer
    }

    public func body(content: Content) -> some View {
        content
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // ✅ Subtitle in principal slot on iOS 26
                if let subtitle {
                    ToolbarItem(placement: .principal) {
                        VStack(spacing: 1) {
                            Text(title)
                                .font(.system(size: 17, weight: .semibold))
                            Text(subtitle)
                                .font(.system(size: 12))
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                // ✅ Leading group
                if !leading.isEmpty {
                    ToolbarItemGroup(placement: .topBarLeading) {
                        ForEach(leading) { item in
                            Button(item.label, systemImage: item.icon, action: item.action)
                                .modifier(SBToolbarButtonStyle(style: style))
                        }
                    }
                }

                // ✅ ToolbarSpacer between leading and trailing on iOS 26
                if useToolbarSpacer && !leading.isEmpty && !trailing.isEmpty {
                    if #available(iOS 26, *) {
                        ToolbarSpacer(.fixed, placement: .primaryAction)
                    }
                }

                // ✅ Trailing group
                if !trailing.isEmpty {
                    ToolbarItemGroup(placement: .topBarTrailing) {
                        ForEach(trailing) { item in
                            Button(item.label, systemImage: item.icon, action: item.action)
                                .modifier(SBToolbarButtonStyle(style: style))
                        }
                    }
                }
            }
    }
}

// MARK: - Per-button style modifier

private struct SBToolbarButtonStyle: ViewModifier {
    let style: SBToolbarStyle

    func body(content: Content) -> some View {
        if #available(iOS 26, *) {
            switch style {
            case .glass, .grouped:
                content.buttonStyle(.glass)
            case .standard:
                content
            }
        } else {
            content
        }
    }
}

// MARK: - View Extension — clean call site

public extension View {
    /// Apply a SwiftBlocks toolbar — title, subtitle, leading/trailing actions, style.
    func sbToolbar(
        title: String,
        subtitle: String? = nil,
        leading: [SBToolbarAction] = [],
        trailing: [SBToolbarAction] = [],
        style: SBToolbarStyle = .glass,
        useToolbarSpacer: Bool = false
    ) -> some View {
        modifier(SBToolbarModifier(
            title: title,
            subtitle: subtitle,
            leading: leading,
            trailing: trailing,
            style: style,
            useToolbarSpacer: useToolbarSpacer
        ))
    }
}

struct GlassNavBarModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
                .toolbarBackground(.hidden, for: .navigationBar)
        } else {
            content
                .toolbarBackground(.automatic, for: .navigationBar)
        }
    }
}
