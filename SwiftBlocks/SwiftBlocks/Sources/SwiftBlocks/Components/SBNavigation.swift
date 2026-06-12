// SBNavigation.swift
// SwiftBlocks — Navigation Components

import SwiftUI

// MARK: - SBNavBar

public struct SBNavBar: View {
    let title: String
    let subtitle: String?
    let leadingAction: SBNavAction?
    let trailingActions: [SBNavAction]
    let style: SBNavBarStyle

    @Environment(\.sbTheme) private var theme

    public init(
        title: String,
        subtitle: String? = nil,
        leadingAction: SBNavAction? = nil,
        trailingActions: [SBNavAction] = [],
        style: SBNavBarStyle = .default
    ) {
        self.title = title
        self.subtitle = subtitle
        self.leadingAction = leadingAction
        self.trailingActions = trailingActions
        self.style = style
    }

    public var body: some View {
        HStack(spacing: 12) {
            if let leading = leadingAction {
                SBNavActionButton(action: leading)
            }

            VStack(alignment: leadingAction == nil ? .center : .leading, spacing: 1) {
                Text(title)
                    .font(theme.fontHeadline)
                    .foregroundStyle(.primary)
                if let subtitle {
                    Text(subtitle)
                        .font(theme.fontCaption)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: leadingAction == nil ? .center : .leading)

            HStack(spacing: 8) {
                ForEach(trailingActions.indices, id: \.self) { index in
                    SBNavActionButton(action: trailingActions[index])
                }
            }
        }
        .padding(.horizontal, theme.spacingMD)
        .padding(.vertical, 12)
        .background {
            if style == .glass {
                if #available(iOS 26.0, *) {
                    Rectangle().glassEffect(.regular)
                } else {
                    Rectangle().fill(.regularMaterial)
                }
            } else {
                Rectangle().fill(theme.background)
            }
        }
    }
}

public enum SBNavBarStyle {
    case `default`, glass, transparent
}

public struct SBNavAction {
    public let icon: String
    public let label: String
    public let action: () -> Void

    public init(icon: String, label: String = "", action: @escaping () -> Void) {
        self.icon = icon
        self.label = label
        self.action = action
    }

    public static func back(_ action: @escaping () -> Void) -> SBNavAction {
        SBNavAction(icon: "chevron.left", label: "Back", action: action)
    }

    public static func close(_ action: @escaping () -> Void) -> SBNavAction {
        SBNavAction(icon: "xmark", label: "Close", action: action)
    }
}

struct SBNavActionButton: View {
    let action: SBNavAction
    @Environment(\.sbTheme) private var theme

    var body: some View {
        Button(action: action.action) {
            Image(systemName: action.icon)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(theme.primary)
                .frame(width: 36, height: 36)
                .background(theme.primary.opacity(0.1))
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - SBPageHeader

public struct SBPageHeader: View {
    let title: String
    let subtitle: String?
    let badge: String?

    @Environment(\.sbTheme) private var theme

    public init(title: String, subtitle: String? = nil, badge: String? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.badge = badge
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline, spacing: 10) {
                Text(title)
                    .font(theme.fontTitle)
                    .foregroundStyle(.primary)

                if let badge {
                    SBBadge(badge, style: .soft)
                }
            }

            if let subtitle {
                Text(subtitle)
                    .font(theme.fontBody)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, theme.spacingMD)
        .padding(.bottom, 4)
    }
}

// MARK: - SBBottomSheet modifier

public struct SBBottomSheetModifier<SheetContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    let detents: Set<PresentationDetent>
    let showDragIndicator: Bool
    let sheetContent: () -> SheetContent

    public func body(content: Content) -> some View {
        content
            .sheet(isPresented: $isPresented) {
                sheetShell
            }
    }

    @ViewBuilder
    private var sheetShell: some View {
        if #available(iOS 26.0, *) {
            sheetContent()
                .presentationDetents(detents)
                .presentationDragIndicator(showDragIndicator ? .visible : .hidden)
                .presentationBackground(.thinMaterial)
        } else {
            sheetContent()
                .presentationDetents(detents)
                .presentationDragIndicator(showDragIndicator ? .visible : .hidden)
        }
    }
}

public extension View {
    func sbBottomSheet<Content: View>(
        isPresented: Binding<Bool>,
        detents: Set<PresentationDetent> = [.medium, .large],
        showDragIndicator: Bool = true,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        modifier(SBBottomSheetModifier(
            isPresented: isPresented,
            detents: detents,
            showDragIndicator: showDragIndicator,
            sheetContent: content
        ))
    }
}

// MARK: - Internal helper

extension View {
    @ViewBuilder
    func if_iOS26<Content: View>(_ transform: (Self) -> Content) -> some View {
        if #available(iOS 26.0, *) {
            transform(self)
        } else {
            self
        }
    }
}
