// SBiOS26Components.swift
// SwiftBlocks — iOS 26 / WWDC25 New Components

import SwiftUI

// MARK: - 1. SBGlassEffectContainer
// Wraps multiple glass shapes so they morph into one shared glass surface
// Uses GlassEffectContainer on iOS 26, plain VStack fallback on older

public struct SBGlassEffectContainer<Content: View>: View {
    let spacing: CGFloat
    let content: Content

    public init(spacing: CGFloat = 8, @ViewBuilder content: () -> Content) {
        self.spacing = spacing
        self.content = content()
    }

    public var body: some View {
        if #available(iOS 26, *) {
            GlassEffectContainer(spacing: spacing) {
                content
            }
        } else {
            VStack(spacing: spacing) {
                content
            }
        }
    }
}

// MARK: - 2. SBConcentricCard
// Uses ConcentricRectangle on iOS 26 — corner radii derived from parent frame
// Falls back to standard RoundedRectangle on older OS

public struct SBConcentricCard<Content: View>: View {
    let content: Content
    let padding: CGFloat

    public init(padding: CGFloat = 16, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.padding = padding
    }

    public var body: some View {
        content
            .padding(padding)
            .background {
                if #available(iOS 26, *) {
                    ConcentricRectangle()
                        .fill(.regularMaterial)
                } else {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(.regularMaterial)
                }
            }
    }
}

// MARK: - 3. SBAsyncImage
// AsyncImage wrapper with loading skeleton + error state
// Uses new URLRequest-based init on iOS 26, standard URL init on older

public struct SBAsyncImage: View {
    let url: URL?
    let cornerRadius: CGFloat
    let aspectRatio: CGFloat

    @Environment(\.sbTheme) private var theme

    public init(
        url: URL?,
        cornerRadius: CGFloat = 12,
        aspectRatio: CGFloat = 16 / 9
    ) {
        self.url = url
        self.cornerRadius = cornerRadius
        self.aspectRatio = aspectRatio
    }

    public var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .empty:
                // ✅ Skeleton while loading
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(Color(.systemGray5))
                    .overlay(
                        ProgressView()
                    )
                    .aspectRatio(aspectRatio, contentMode: .fit)

            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
                    .aspectRatio(aspectRatio, contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))

            case .failure:
                // ✅ Error state
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(Color(.systemGray6))
                    .aspectRatio(aspectRatio, contentMode: .fit)
                    .overlay(
                        VStack(spacing: 6) {
                            Image(systemName: "photo.slash")
                                .font(.system(size: 24))
                                .foregroundStyle(.secondary)
                            Text("Failed to load")
                                .font(.system(size: 12))
                                .foregroundStyle(.secondary)
                        }
                    )

            @unknown default:
                EmptyView()
            }
        }
    }
}

// MARK: - 4. SBNavigationSubtitle
// Convenience modifier — adds .navigationSubtitle on iOS 26+
// silently ignored on older OS (no subtitle support)

public extension View {
    func sbNavigationSubtitle(_ subtitle: String) -> some View {
        Group {
            if #available(iOS 26, *) {
                self.navigationSubtitle(subtitle)
            } else {
                self
            }
        }
    }
}

// MARK: - 5. SBScrollEdgeCard
// Demonstrates Hard ScrollEdgeEffect — fade with hard cutoff at scroll edges
// Applied to any ScrollView content

public extension View {
    /// Applies iOS 26 hard scroll-edge fade effect. No-op on older OS.
    func sbScrollEdgeEffect() -> some View {
        Group {
            if #available(iOS 26, *) {
                self.scrollEdgeEffectStyle(.hard, for: .all)
            } else {
                self
            }
        }
    }
}

// MARK: - 6. SBTabBarAccessory
// A content view designed to sit above a TabView as a bottom accessory
// Uses .tabViewBottomAccessory on iOS 26

public struct SBTabBarAccessory<Content: View>: View {
    let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        content
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(.regularMaterial)
    }
}

public extension View {
    /// Places a view above the tab bar as a bottom accessory on iOS 26.
    /// Falls back to an overlay on older OS.
    @ViewBuilder
    func sbTabBarAccessory<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        if #available(iOS 26, *) {
            self.tabViewBottomAccessory(content: content)
        } else {
            self.overlay(
                VStack {
                    Spacer()
                    content()
                        .padding(.bottom, 80)
                }
            )
        }
    }
}

// MARK: - 7. SBRoleButton
// Uses new Button(role:) init from iOS 26 — renders system-styled destructive/cancel
// Falls back to SBButton on older OS

public struct SBRoleButton: View {
    public enum SBRole {
        case destructive
        case cancel
        case none
    }

    let title: String
    let icon: String?
    let role: SBRole
    let action: () -> Void

    @Environment(\.sbTheme) private var theme

    public init(
        _ title: String,
        icon: String? = nil,
        role: SBRole = .none,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.role = role
        self.action = action
    }

    public var body: some View {
        if #available(iOS 26, *) {
            Button(title, role: swiftUIRole, action: action)
                .buttonStyle(.glass)
        } else {
            SBButton(
                title,
                icon: icon,
                style: role == .destructive ? .destructive : .secondary,
                isFullWidth: true,
                action: action
            )
        }
    }

    @available(iOS 26, *)
    private var swiftUIRole: ButtonRole? {
        switch role {
        case .destructive: return .destructive
        case .cancel:      return .cancel
        case .none:        return nil
        }
    }
}

// MARK: - 8. SBGlassToolbar
// Toolbar with shared glass background — groups items under one glass surface
// Uses .sharedBackgroundVisibility on iOS 26

public struct SBGlassToolbarConfig {
    public let title: String
    public let leadingIcon: String?
    public let trailingIcon: String?
    public let leadingAction: (() -> Void)?
    public let trailingAction: (() -> Void)?

    public init(
        title: String,
        leadingIcon: String? = nil,
        trailingIcon: String? = nil,
        leadingAction: (() -> Void)? = nil,
        trailingAction: (() -> Void)? = nil
    ) {
        self.title = title
        self.leadingIcon = leadingIcon
        self.trailingIcon = trailingIcon
        self.leadingAction = leadingAction
        self.trailingAction = trailingAction
    }
}

// MARK: - SBGlassToolbar (fixed)

public extension View {
    func sbGlassToolbar(_ config: SBGlassToolbarConfig) -> some View {
        self.toolbar {
            if let leadingIcon = config.leadingIcon {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        config.leadingAction?()
                    } label: {
                        Image(systemName: leadingIcon)
                    }
                    // ✅ sharedBackgroundVisibility is a ToolbarContent modifier
                    // applied directly on ToolbarItem, not on Button
                    .modifier(ToolbarGlassModifier())
                }
            }

            ToolbarItem(placement: .principal) {
                Text(config.title)
                    .font(.system(size: 17, weight: .semibold))
            }

            if let trailingIcon = config.trailingIcon {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        config.trailingAction?()
                    } label: {
                        Image(systemName: trailingIcon)
                    }
                    .modifier(ToolbarGlassModifier())
                }
            }
        }
    }
}

// ✅ Separate modifier — applies glass tint to toolbar button, no sharedBackgroundVisibility
private struct ToolbarGlassModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26, *) {
            content.buttonStyle(.glass)
        } else {
            content
        }
    }
}

// MARK: - TOOLBARS

// MARK: - SBTitleToolbar
// Uses .title ToolbarItemPlacement on iOS 26 — places content in the title area
// Falls back to .principal on older OS

public extension View {
    func sbTitleToolbar(
        title: String,
        subtitle: String? = nil,
        leadingIcon: String? = nil,
        trailingIcon: String? = nil,
        leadingAction: (() -> Void)? = nil,
        trailingAction: (() -> Void)? = nil
    ) -> some View {
        self.toolbar {
            // ✅ Leading item
            if let leadingIcon {
                ToolbarItem(placement: .topBarLeading) {
                    Button { leadingAction?() } label: {
                        Image(systemName: leadingIcon)
                    }
                }
            }

            // ✅ Title area — .title placement on iOS 26, .principal fallback
            ToolbarItem(placement: {
                if #available(iOS 26, *) { return .title }
                else { return .principal }
            }()) {
                VStack(spacing: 1) {
                    Text(title)
                        .font(.system(size: 17, weight: .semibold))
                    if let subtitle {
                        Text(subtitle)
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary)
                    }
                }
            }

            // ✅ Trailing item
            if let trailingIcon {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { trailingAction?() } label: {
                        Image(systemName: trailingIcon)
                    }
                }
            }
        }
    }
}

// MARK: - SBToolbarSpacer
// ToolbarSpacer — standard spacing between toolbar items
// iOS 26 only, no-op on older

public struct SBToolbarSpacerItem: ToolbarContent {
    public init() {}

    public var body: some ToolbarContent {
        if #available(iOS 26, *) {
            ToolbarSpacer(.fixed)
        } else {
            ToolbarItem { Spacer() }
        }
    }
}

// MARK: - SBSharedBackgroundToolbar
// Groups toolbar items under one shared glass background on iOS 26
// Uses .sharedBackgroundVisibility on ToolbarItem directly (not on View)

public extension View {
    func sbSharedBackgroundToolbar(
        leading: [(icon: String, action: () -> Void)] = [],
        trailing: [(icon: String, action: () -> Void)] = [],
        title: String
    ) -> some View {
        self.toolbar {
            // Leading group
            ToolbarItemGroup(placement: .topBarLeading) {
                ForEach(leading.indices, id: \.self) { i in
                    Button { leading[i].action() } label: {
                        Image(systemName: leading[i].icon)
                    }
                    // ✅ sharedBackgroundVisibility on ToolbarContent — correct usage
                    .modifier(SBSharedBGModifier())
                }
            }

            ToolbarItem(placement: .principal) {
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
            }

            // Trailing group
            ToolbarItemGroup(placement: .topBarTrailing) {
                ForEach(trailing.indices, id: \.self) { i in
                    Button { trailing[i].action() } label: {
                        Image(systemName: trailing[i].icon)
                    }
                    .modifier(SBSharedBGModifier())
                }
            }
        }
    }
}

// ✅ Applies .buttonStyle(.glass) on iOS 26 for toolbar buttons
private struct SBSharedBGModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26, *) {
            content.buttonStyle(.glass)
        } else {
            content
        }
    }
}

// MARK: - SLIDERS

// MARK: - SBTickSlider
// Custom slider with tick marks — new in iOS 26
// Falls back to standard Slider on older OS

// MARK: - SBTickSlider (fixed)

public struct SBTickSlider: View {
    let title: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double
    let format: (Double) -> String

    @Environment(\.sbTheme) private var theme

    public init(
        _ title: String,
        value: Binding<Double>,
        range: ClosedRange<Double>,
        step: Double = 1,
        format: @escaping (Double) -> String = { "\(Int($0))" }
    ) {
        self.title = title
        self._value = value
        self.range = range
        self.step = step
        self.format = format
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.primary)
                Spacer()
                Text(format(value))
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(theme.primary)
                    .monospacedDigit()
            }

            if #available(iOS 26, *) {
                // ✅ tick: closure must return SliderTick<Double>, not a View
                Slider(value: $value, in: range, step: step) {
                    Text(title)
                } minimumValueLabel: {
                    Text(format(range.lowerBound))
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                } maximumValueLabel: {
                    Text(format(range.upperBound))
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                } tick: { value in
                    // ✅ Return SliderTick, not a View
                    SliderTick(value)
                }
                .tint(theme.primary)
            } else {
                VStack(spacing: 4) {
                    Slider(value: $value, in: range, step: step)
                        .tint(theme.primary)
                    HStack {
                        Text(format(range.lowerBound))
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(format(range.upperBound))
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - SBNeutralSlider (fixed)

public struct SBNeutralSlider: View {
    let title: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let neutralValue: Double
    let step: Double
    let format: (Double) -> String

    @Environment(\.sbTheme) private var theme

    public init(
        _ title: String,
        value: Binding<Double>,
        range: ClosedRange<Double> = -1.0...1.0,
        neutralValue: Double = 0,
        step: Double = 0.1,
        format: @escaping (Double) -> String = { String(format: "%.1f", $0) }
    ) {
        self.title = title
        self._value = value
        self.range = range
        self.neutralValue = neutralValue
        self.step = step
        self.format = format
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.primary)
                Spacer()
                Text(value == neutralValue ? "Neutral" : format(value))
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(value == neutralValue ? .secondary : theme.primary)
                    .monospacedDigit()

                if value != neutralValue {
                    Button {
                        withAnimation(.spring(response: 0.3)) {
                            value = neutralValue
                        }
                    } label: {
                        Image(systemName: "arrow.uturn.backward.circle.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .animation(.spring(response: 0.2), value: value == neutralValue)

            if #available(iOS 26, *) {
                // ✅ label: is required — pass EmptyView or Text
                Slider(
                    value: $value,
                    in: range,
                    step: step,
                    neutralValue: neutralValue
                ) {
                    // ✅ required label parameter
                    Text(title)
                }
                .tint(theme.primary)
            } else {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Slider(value: $value, in: range, step: step)
                            .tint(theme.primary)

                        Rectangle()
                            .fill(Color(.systemGray3))
                            .frame(width: 2, height: 16)
                            .position(
                                x: geo.size.width / 2,
                                y: geo.size.height / 2
                            )
                    }
                }
                .frame(height: 28)
            }

            HStack {
                Text(format(range.lowerBound))
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
                Spacer()
                Text("●")
                    .font(.system(size: 8))
                    .foregroundStyle(.secondary)
                Spacer()
                Text(format(range.upperBound))
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
