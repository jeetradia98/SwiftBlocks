// SBOverlays.swift
// SwiftBlocks — Overlay Components (Onboarding, Permission, Paywall)

import SwiftUI

// MARK: - SBOnboardingPage

public struct SBOnboardingPage {
    public let icon: String
    public let title: String
    public let description: String
    public let accentColor: Color

    public init(
        icon: String,
        title: String,
        description: String,
        accentColor: Color = Color(red: 0.2, green: 0.4, blue: 1.0)
    ) {
        self.icon = icon
        self.title = title
        self.description = description
        self.accentColor = accentColor
    }
}

// MARK: - SBOnboardingView

public struct SBOnboardingView: View {
    let pages: [SBOnboardingPage]
    let ctaTitle: String
    let onComplete: () -> Void

    @State private var currentPage = 0
    @Environment(\.sbTheme) private var theme

    public init(
        pages: [SBOnboardingPage],
        ctaTitle: String = "Get Started",
        onComplete: @escaping () -> Void
    ) {
        self.pages = pages
        self.ctaTitle = ctaTitle
        self.onComplete = onComplete
    }

    public var body: some View {
        ZStack {
            // Background gradient follows accent color
            LinearGradient(
                colors: [
                    pages[currentPage].accentColor.opacity(0.15),
                    Color(.systemBackground)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.5), value: currentPage)

            VStack(spacing: 0) {
                // Pages
                TabView(selection: $currentPage) {
                    ForEach(pages.indices, id: \.self) { index in
                        onboardingPage(pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(maxHeight: .infinity)

                // Bottom controls
                VStack(spacing: 20) {
                    // Page dots
                    HStack(spacing: 8) {
                        ForEach(pages.indices, id: \.self) { index in
                            Capsule()
                                .fill(index == currentPage ? pages[currentPage].accentColor : Color(.systemGray4))
                                .frame(width: index == currentPage ? 24 : 8, height: 8)
                                .animation(.spring(response: 0.3), value: currentPage)
                        }
                    }

                    // CTA Button
                    SBButton(
                        currentPage < pages.count - 1 ? "Next" : ctaTitle,
                        icon: currentPage < pages.count - 1 ? "arrow.right" : "checkmark",
                        style: .primary,
                        size: .large,
                        isFullWidth: true
                    ) {
                        if currentPage < pages.count - 1 {
                            withAnimation(.spring(response: 0.4)) { currentPage += 1 }
                        } else {
                            onComplete()
                        }
                    }

                    if currentPage < pages.count - 1 {
                        Button("Skip") { onComplete() }
                            .font(theme.fontCaption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal, theme.spacingLG)
                .padding(.bottom, theme.spacingXL)
            }
        }
    }

    private func onboardingPage(_ page: SBOnboardingPage) -> some View {
        VStack(spacing: theme.spacingLG) {
            Spacer()

            // Icon
            ZStack {
                Circle()
                    .fill(page.accentColor.opacity(0.15))
                    .frame(width: 120, height: 120)

                Circle()
                    .fill(page.accentColor.opacity(0.1))
                    .frame(width: 90, height: 90)

                Image(systemName: page.icon)
                    .font(.system(size: 44, weight: .semibold))
                    .foregroundStyle(page.accentColor)
            }

            // Text
            VStack(spacing: 12) {
                Text(page.title)
                    .font(theme.fontTitle)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)

                Text(page.description)
                    .font(theme.fontBody)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, theme.spacingXL)
            }

            Spacer()
        }
    }
}

// MARK: - SBPermissionCard

public enum SBPermissionType {
    case camera, microphone, location, notifications, photos, contacts

    public var icon: String {
        switch self {
        case .camera:        return "camera.fill"
        case .microphone:    return "mic.fill"
        case .location:      return "location.fill"
        case .notifications: return "bell.badge.fill"
        case .photos:        return "photo.fill"
        case .contacts:      return "person.crop.circle.fill"
        }
    }

    public var title: String {
        switch self {
        case .camera:        return "Camera Access"
        case .microphone:    return "Microphone Access"
        case .location:      return "Location Access"
        case .notifications: return "Notifications"
        case .photos:        return "Photo Library"
        case .contacts:      return "Contacts"
        }
    }
}

public struct SBPermissionCard: View {
    let type: SBPermissionType
    let description: String
    let onAllow: () -> Void
    let onDeny: (() -> Void)?

    @Environment(\.sbTheme) private var theme

    public init(
        type: SBPermissionType,
        description: String,
        onAllow: @escaping () -> Void,
        onDeny: (() -> Void)? = nil
    ) {
        self.type = type
        self.description = description
        self.onAllow = onAllow
        self.onDeny = onDeny
    }

    public var body: some View {
        SBCard(style: .glass) {
            VStack(spacing: theme.spacingMD) {
                // Icon
                Image(systemName: type.icon)
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundStyle(theme.primary)
                    .frame(width: 64, height: 64)
                    .background(theme.primary.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 18))

                // Text
                VStack(spacing: 6) {
                    Text(type.title)
                        .font(theme.fontHeadline)
                        .foregroundStyle(.primary)

                    Text(description)
                        .font(theme.fontBody)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }

                // Actions
                VStack(spacing: 10) {
                    SBButton("Allow Access", style: .primary, isFullWidth: true, action: onAllow)
                    if let onDeny {
                        SBButton("Not Now", style: .ghost, isFullWidth: true, action: onDeny)
                    }
                }
            }
        }
        .padding(.horizontal, theme.spacingMD)
    }
}

// MARK: - SBPaywallView

public struct SBPaywallPlan {
    public let id: String
    public let name: String
    public let price: String
    public let period: String
    public let features: [String]
    public let isFeatured: Bool

    public init(
        id: String,
        name: String,
        price: String,
        period: String,
        features: [String],
        isFeatured: Bool = false
    ) {
        self.id = id
        self.name = name
        self.price = price
        self.period = period
        self.features = features
        self.isFeatured = isFeatured
    }
}

public struct SBPaywallView: View {
    let title: String
    let subtitle: String
    let plans: [SBPaywallPlan]
    let onPurchase: (SBPaywallPlan) -> Void
    let onRestore: (() -> Void)?
    let onDismiss: (() -> Void)?

    @State private var selectedPlan: String
    @Environment(\.sbTheme) private var theme

    public init(
        title: String = "Go Premium",
        subtitle: String = "Unlock all features",
        plans: [SBPaywallPlan],
        onPurchase: @escaping (SBPaywallPlan) -> Void,
        onRestore: (() -> Void)? = nil,
        onDismiss: (() -> Void)? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.plans = plans
        self.onPurchase = onPurchase
        self.onRestore = onRestore
        self.onDismiss = onDismiss
        self._selectedPlan = State(initialValue: plans.first(where: { $0.isFeatured })?.id ?? plans.first?.id ?? "")
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: theme.spacingLG) {

                // Header
                if let onDismiss {
                    HStack {
                        Spacer()
                        SBIconButton("xmark", style: .secondary, action: onDismiss)
                    }
                }

                VStack(spacing: 8) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(.yellow)
                        .symbolEffect(.bounce)

                    Text(title)
                        .font(theme.fontTitle)
                    Text(subtitle)
                        .font(theme.fontBody)
                        .foregroundStyle(.secondary)
                }
                .multilineTextAlignment(.center)

                // Plans
                VStack(spacing: 12) {
                    ForEach(plans, id: \.id) { plan in
                        paywallPlanCard(plan)
                    }
                }

                // CTA
                if let plan = plans.first(where: { $0.id == selectedPlan }) {
                    SBButton(
                        "Continue with \(plan.name)",
                        icon: "arrow.right",
                        style: .primary,
                        size: .large,
                        isFullWidth: true
                    ) {
                        onPurchase(plan)
                    }
                }

                if let onRestore {
                    Button("Restore Purchases", action: onRestore)
                        .font(theme.fontCaption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(theme.spacingMD)
        }
    }

    private func paywallPlanCard(_ plan: SBPaywallPlan) -> some View {
        let isSelected = selectedPlan == plan.id

        return Button {
            withAnimation(.spring(response: 0.3)) { selectedPlan = plan.id }
        } label: {
            HStack(spacing: 14) {
                // Select indicator
                ZStack {
                    Circle()
                        .strokeBorder(isSelected ? theme.primary : Color.primary.opacity(0.2), lineWidth: 2)
                        .frame(width: 22, height: 22)
                    if isSelected {
                        Circle()
                            .fill(theme.primary)
                            .frame(width: 12, height: 12)
                    }
                }

                VStack(alignment: .leading, spacing: 3) {
                    HStack {
                        Text(plan.name)
                            .font(theme.fontHeadline)
                            .foregroundStyle(.primary)
                        if plan.isFeatured {
                            SBBadge("Best Value", color: .yellow, style: .soft)
                        }
                    }
                    Text(plan.features.prefix(2).joined(separator: " · "))
                        .font(theme.fontCaption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text(plan.price)
                        .font(theme.fontHeadline)
                        .foregroundStyle(.primary)
                    Text(plan.period)
                        .font(theme.fontCaption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(16)
            .background {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(isSelected ? theme.primary.opacity(0.07) : theme.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(
                                isSelected ? theme.primary : Color.clear,
                                lineWidth: 2
                            )
                    )
            }
        }
        .buttonStyle(.plain)
    }
}
