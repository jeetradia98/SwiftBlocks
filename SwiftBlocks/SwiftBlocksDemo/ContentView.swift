// ContentView.swift
// SwiftBlocks — Full Component Demo

import SwiftUI

// MARK: - ContentView

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var showOptionSheet = false
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                NavigationStack {
                    DashboardView(selectedTab: $selectedTab)
                }
                .tag(0)
                .id(0)

                NavigationStack {
                    ComponentsView()
                }
                .tag(1)
                .id(1)

                NavigationStack {
                    FormsView()
                }
                .tag(2)
                .id(2)

                NavigationStack {
                    ProfileView()
                }
                .tag(3)
                .id(3)
                
                NavigationStack {
                    ExtrasView()
                }
                .tag(4)
                .id(4)

            }
            .toolbar(.hidden, for: .tabBar)
            SBFloatingGlassBar(
                items: [
                    .init(title: "Dashboard",  icon: "chart.bar",        iconFilled: "chart.bar.fill"),
                    .init(title: "Components", icon: "square.grid.2x2",  iconFilled: "square.grid.2x2.fill"),
                    .init(title: "Forms",      icon: "doc.text",          iconFilled: "doc.text.fill"),
                    .init(title: "Profile",    icon: "person",             iconFilled: "person.fill"),
                    .init(title: "Extras", icon: "plus.square", iconFilled: "plus.square.fill")
                ],
                selection: $selectedTab
            )
            .padding(.bottom, 16)
        }
        .sbTheme(.default)
        .ignoresSafeArea(edges: .bottom)
    }
}

// MARK: - 1. Dashboard View

struct DashboardView: View {
    @Binding var selectedTab: Int

    @State private var showToast  = false
    @State private var toastType: SBToastType = .success
    @State private var isLoading  = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {

                SBPageHeader(title: "Dashboard", subtitle: "SwiftBlocks Demo", badge: "iOS 26")

                SBMetricRow(metrics: [
                    .init(value: "2.4k",  label: "Users",   trend: .up("12%")),
                    .init(value: "$8.2k", label: "Revenue", trend: .up("9%")),
                    .init(value: "94%",   label: "Uptime",  trend: .neutral("—"))
                ])
                .padding(.horizontal, 16)

                SBCard(style: .elevated) {
                    VStack(spacing: 0) {
                        Button {
                            selectedTab = 1
                        } label: {
                            SBListRow(
                                icon: "square.grid.2x2.fill", iconColor: .blue,
                                title: "Browse Components",
                                subtitle: "Buttons, cards, chat & more",
                                showChevron: true
                            )
                        }
                        .buttonStyle(.plain)

                        Divider().padding(.leading, 66)

                        Button {
                            selectedTab = 2
                        } label: {
                            SBListRow(
                                icon: "doc.text.fill", iconColor: .purple,
                                title: "Form Controls",
                                subtitle: "Inputs, pickers & settings",
                                showChevron: true
                            )
                        }
                        .buttonStyle(.plain)

                        Divider().padding(.leading, 66)

                        Button {
                            selectedTab = 3
                        } label: {
                            SBListRow(
                                icon: "person.fill", iconColor: .orange,
                                title: "Profile & Commerce",
                                subtitle: "Avatars, cart & overlays",
                                showChevron: true
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)

                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12)
                ], spacing: 12) {
                    SBStatCard(title: "Total Revenue", value: "$12,400", subtitle: "This month",    icon: "creditcard",  trend: .up("12%"))
                    SBStatCard(title: "New Users",     value: "1,284",   subtitle: "vs last month", icon: "person.2",    trend: .up("8%"))
                    SBStatCard(title: "Churn Rate",    value: "2.4%",    icon: "arrow.down.left",   trend: .down("0.3%"))
                    SBStatCard(title: "Avg Session",   value: "4m 32s",  icon: "clock",             trend: .neutral("same"))
                }
                .padding(.horizontal, 16)

                SBCard(style: .elevated) {
                    SBBarChart(title: "Weekly Revenue", data: [
                        .init(label: "Mon", value: 2400),
                        .init(label: "Tue", value: 3800),
                        .init(label: "Wed", value: 2900),
                        .init(label: "Thu", value: 4700),
                        .init(label: "Fri", value: 5200),
                        .init(label: "Sat", value: 3100),
                        .init(label: "Sun", value: 1800)
                    ])
                }
                .padding(.horizontal, 16)

                SBCard(style: .elevated) {
                    SBRingChart(
                        segments: [
                            .init(label: "iOS",     value: 54),
                            .init(label: "Android", value: 30),
                            .init(label: "Web",     value: 16)
                        ],
                        centerText: "54%", centerSubtext: "iOS"
                    )
                    .padding(.vertical, 8)
                }
                .padding(.horizontal, 16)

                SBCard(style: .elevated) {
                    SBLineChartView(title: "User Growth",
                                    points: [800, 1200, 1100, 1600, 2100, 2400],
                                    labels: ["Jan","Feb","Mar","Apr","May","Jun"])
                }
                .padding(.horizontal, 16)

                SBCard(style: .elevated) {
                    SBAreaChartView(title: "Sessions This Week",
                                    points: [1200, 1800, 1400, 2200, 1900, 2800, 2400],
                                    labels: ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"])
                }
                .padding(.horizontal, 16)

                SBCard(style: .elevated) {
                    SBHorizontalBarChartView(title: "Top Channels", items: [
                        ("Organic", 42.0), ("Referral", 28.0), ("Paid", 18.0), ("Social", 12.0)
                    ])
                }
                .padding(.horizontal, 16)

                SBCard(style: .elevated) {
                    SBGroupedBarChartView(
                        title: "iOS vs Android",
                        groups: ["Mon","Tue","Wed","Thu","Fri"],
                        seriesA: ("iOS",     [300.0, 420, 380, 510, 460], Color.blue),
                        seriesB: ("Android", [180.0, 260, 210, 300, 280], Color.purple)
                    )
                }
                .padding(.horizontal, 16)

                VStack(spacing: 10) {
                    Text("Toast Notifications")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 16)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach([
                                ("Success", SBToastType.success),
                                ("Error",   SBToastType.error),
                                ("Warning", SBToastType.warning),
                                ("Info",    SBToastType.info)
                            ], id: \.0) { label, type in
                                SBButton(label, style: .outline, size: .small) {
                                    toastType = type; showToast = true
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }

                SBButton("Simulate Loading", icon: "arrow.clockwise",
                         style: .secondary, isFullWidth: true) {
                    isLoading = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { isLoading = false }
                }
                .padding(.horizontal, 16)

                Spacer(minLength: 100)
            }
            .padding(.top,16)
//            .padding(.top, {
//                if #available(iOS 26, *) {
//                    return 16.0
//                } else {
//                    return 56.0
//                }
//            }())
        }
        .navigationTitle("Dashboard")
        .navigationBarTitleDisplayMode(.inline)
//        .modifier(GlassNavBarModifier())
        .sbToast(isPresented: $showToast, message: toastMessage(for: toastType), type: toastType)
        .sbLoading(isLoading, message: "Refreshing data...")
    }

    func toastMessage(for type: SBToastType) -> String {
        switch type {
        case .success: return "Data saved successfully!"
        case .error:   return "Something went wrong."
        case .warning: return "Your session is expiring."
        case .info:    return "New update available."
        }
    }
}

// MARK: - 2. Components View

struct ComponentsView: View {
    @State private var showSheet = false
    @State private var chatMessages: [SBChatMessage] = [
        .init(content: "Hi! I'm your AI assistant. How can I help?", isUser: false),
        .init(content: "Can you explain SwiftBlocks?", isUser: true),
        .init(content: "SwiftBlocks is a modern SwiftUI component library with iOS 26 Liquid Glass support!", isUser: false)
    ]
    @State private var chatInput  = ""
    @State private var isAITyping = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                SBPageHeader(title: "Components", subtitle: "Buttons, Cards, Chat & More")

                sectionHeader("Buttons")
                VStack(spacing: 10) {
                    SBButton("Primary Button",   style: .primary,     isFullWidth: true) {}
                    SBButton("Secondary",        style: .secondary,   isFullWidth: true) {}
                    SBButton("Outline",          style: .outline,     isFullWidth: true) {}
                    SBButton("Delete Account", icon: "trash", style: .destructive, isFullWidth: true) {}
                    SBButton("Glass Style",    icon: "sparkles", style: .glass,    isFullWidth: true) {}
                    SBButton("Loading...",       style: .primary,     isFullWidth: true, isLoading: true) {}
                    SBGlassButton("Floating Glass", icon: "plus") {}
                }
                .padding(.horizontal, 16)

                sectionHeader("Icon Buttons")
                HStack(spacing: 14) {
                    SBIconButton("heart.fill",  style: .primary)     {}
                    SBIconButton("bell.fill",   style: .secondary)   {}
                    SBIconButton("star.fill",   style: .glass)       {}
                    SBIconButton("share",       style: .outline)     {}
                    SBIconButton("trash",       style: .destructive) {}
                }
                .padding(.horizontal, 16)

                sectionHeader("Cards")
                VStack(spacing: 12) {
                    SBCard(style: .elevated) {
                        SBInfoCard(title: "Elevated Card", description: "Default with shadow", icon: "square.stack")
                    }
                    .padding(.horizontal, 16)

                    SBCard(style: .outlined) {
                        SBInfoCard(title: "Outlined Card", description: "Border, no fill", icon: "square")
                    }
                    .padding(.horizontal, 16)

                    VStack(alignment: .leading, spacing: 4) {
                        SBInfoCard(title: "Glass Card",
                                   description: "iOS 26 Liquid Glass — single layer, no double border",
                                   icon: "sparkles")
                    }
                    .padding(16)
                    .nativeGlass(cornerRadius: SBRadius.card)
                    .padding(.horizontal, 16)
                }

                sectionHeader("Badges & Status")
                HStack(spacing: 8) {
                    SBBadge("New",  color: .blue,   style: .filled)
                    SBBadge("Beta", color: .orange, style: .soft)
                    SBBadge("Live", color: .green,  style: .outlined)
                    SBBadge("Sale", color: .red,    style: .filled)
                }
                .padding(.horizontal, 16)

                VStack(spacing: 8) {
                    SBStatusBanner("App is up to date.",             type: .success)
                    SBStatusBanner("Scheduled maintenance tonight.", type: .warning)
                    SBStatusBanner("New features available!",        type: .info)
                }
                .padding(.horizontal, 16)

                sectionHeader("Loaders")
                HStack(spacing: 24) {
                    SBLoader(style: .circular)
                    SBLoader(style: .dots)
                    SBLoader(style: .pulse)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)

                sectionHeader("Skeleton")
                VStack(spacing: 10) {
                    SBSkeletonCard()
                    SBSkeletonCard()
                    SBSkeleton(height: 14)
                    SBSkeleton(width: 180, height: 12)
                }
                .padding(.horizontal, 16)

                sectionHeader("Media")
                VStack(spacing: 12) {
                    SBMediaPlaceholder(aspectRatio: 16/9, label: "Cover Image")
                        .padding(.horizontal, 16)
                    SBVideoThumbnail(title: "SwiftBlocks Intro", duration: "3:42") {}
                        .padding(.horizontal, 16)
                    SBFileRow(filename: "design-system.pdf", fileSize: "2.4 MB",  fileType: .pdf)     {}
                        .padding(.horizontal, 16)
                    SBFileRow(filename: "assets.zip",        fileSize: "18.7 MB", fileType: .archive) {}
                        .padding(.horizontal, 16)
                }

                sectionHeader("AI Chat")
                VStack(spacing: 8) {
                    ForEach(chatMessages) { msg in SBChatBubble(msg, showTimestamp: false) }
                    if isAITyping { SBTypingIndicator() }
                    SBPromptSuggestions(prompts: [
                        "What components exist?", "How to add glass?", "Show theming"
                    ]) { sendMessage($0) }
                    SBChatInputBar(text: $chatInput, isLoading: isAITyping) { sendMessage(chatInput) }
                }
                .padding(16)
                sectionHeader("AI Features")
                VStack(spacing: 10) {
                    SBAIFeatureCard(icon: "sparkles",       title: "Smart Suggestions",
                                    description: "AI-powered recommendations", accentColor: .purple) {}
                    SBAIFeatureCard(icon: "wand.and.stars", title: "Auto Complete",
                                    description: "Finish your sentences faster",  accentColor: .blue) {}
                    SBAIFeatureCard(icon: "brain",          title: "Context Memory",
                                    description: "Remembers your preferences",    accentColor: .orange) {}
                }
                .padding(.horizontal, 16)

                sectionHeader("Navigation")
                SBNavBar(title: "Settings", subtitle: "Manage preferences",
                         trailingActions: [.init(icon: "ellipsis") {}])
                    .padding(.horizontal, 16)

                SBNavBar(title: "Glass NavBar", leadingAction: .back {},
                         trailingActions: [.init(icon: "bell") {}], style: .glass)
                    .padding(.horizontal, 16)

                SBButton("Open Bottom Sheet", icon: "arrow.up.circle",
                         style: .outline, isFullWidth: true) { showSheet = true }
                    .padding(.horizontal, 16)

                Spacer(minLength: 100)
            }
            .padding(.top,16)
        }
        .navigationTitle("Components")
        .navigationBarTitleDisplayMode(.inline)
//        .modifier(GlassNavBarModifier())
        .sbBottomSheet(isPresented: $showSheet) {
            VStack(spacing: 16) {
                SBPageHeader(title: "Bottom Sheet", subtitle: "iOS-native sheet with drag indicator")
                SBInfoCard(title: "Detents Support",  description: ".medium and .large auto-configured", icon: "arrow.up.and.down")
                SBInfoCard(title: "Glass Background", description: "Uses .thinMaterial on iOS 26+",      icon: "sparkles")
                SBButton("Close", style: .outline, isFullWidth: true) { showSheet = false }
            }
            .padding(20)
        }
    }

    private func sendMessage(_ text: String) {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        chatMessages.append(.init(content: text, isUser: true))
        chatInput = ""
        isAITyping = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isAITyping = false
            chatMessages.append(.init(
                content: "Thanks for asking about \"\(text.prefix(30))\"! SwiftBlocks has you covered.",
                isUser: false
            ))
        }
    }

    @ViewBuilder func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(.secondary)
            .textCase(.uppercase)
            .kerning(0.8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
    }
}

// MARK: - 3. Forms View

struct FormsView: View {
    @State private var email        = ""
    @State private var password     = ""
    @State private var username     = ""
    @State private var bio          = ""
    @State private var searchQuery  = ""
    @State private var notifications = true
    @State private var darkMode      = false
    @State private var analytics     = true
    @State private var quantity      = 2
    @State private var fontSize      = 16.0
    @State private var rating        = 4
    @State private var selectedPlan  = "pro"
    @State private var showToast     = false
    @State private var emailError: String? = nil

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                SBPageHeader(title: "Forms", subtitle: "Inputs, pickers & settings")

                sectionCard("Text Inputs") {
                    VStack(spacing: 14) {
                        SBTextField("Email", placeholder: "you@example.com",
                                    text: $email, leadingIcon: "envelope", errorMessage: emailError)
                            .onChange(of: email) { _, new in
                                emailError = new.contains("@") ? nil : "Enter a valid email"
                            }
                        SBTextField("Password", placeholder: "••••••••",
                                    text: $password, leadingIcon: "lock", isSecure: true)
                        SBTextField("Username", placeholder: "@handle",
                                    text: $username, style: .filled, leadingIcon: "at")
                        SBTextField("Search", placeholder: "Find anything...",
                                    text: $searchQuery, style: .glass, leadingIcon: "magnifyingglass")
                        SBSearchBar(text: $searchQuery)
                        SBCharacterCountField("Bio", placeholder: "Tell your story...",
                                              text: $bio, limit: 160)
                    }
                }

                sectionCard("Controls") {
                    VStack(spacing: 16) {
                        SBStepperRow(title: "Quantity", subtitle: "Units to order",
                                     value: $quantity, range: 1...99)
                        Divider()
                        SBSliderRow(title: "Font Size", value: $fontSize,
                                    range: 12...28, step: 1, format: { "\(Int($0))pt" })
                        Divider()
                        SBRatingRow(title: "Rate this library", rating: $rating)
                        Divider()
                        SBPickerRow(title: "Plan",
                                    options: [
                                        (label: "Free", value: "free"),
                                        (label: "Pro",  value: "pro"),
                                        (label: "Team", value: "team")
                                    ],
                                    selection: $selectedPlan)
                    }
                }

                sectionHeader("Settings Style")
                SBListSection(header: "Preferences", footer: "Changes apply immediately") {
                    SBToggleRow(icon: "bell.fill",      iconColor: .red,    title: "Notifications", subtitle: "Push & in-app alerts", isOn: $notifications)
                    Divider().padding(.leading, 66)
                    SBToggleRow(icon: "moon.fill",      iconColor: .indigo, title: "Dark Mode",     isOn: $darkMode)
                    Divider().padding(.leading, 66)
                    SBToggleRow(icon: "chart.bar.fill", iconColor: .blue,   title: "Analytics",     subtitle: "Help improve the app", isOn: $analytics)
                }
                .padding(.horizontal, 16)

                SBListSection(header: "Account") {
                    SBListRow(icon: "person.fill",             iconColor: .blue,   title: "Edit Profile",       showChevron: true) {}
                    Divider().padding(.leading, 66)
                    SBListRow(icon: "creditcard.fill",         iconColor: .green,  title: "Billing",            trailingText: "Pro plan", showChevron: true) {}
                    Divider().padding(.leading, 66)
                    SBListRow(icon: "shield.fill",             iconColor: .purple, title: "Privacy & Security", showChevron: true) {}
                    Divider().padding(.leading, 66)
                    SBListRow(icon: "arrow.right.square.fill", iconColor: .red,    title: "Sign Out") {}
                }
                .padding(.horizontal, 16)

                SBButton("Save Changes", icon: "checkmark", style: .primary,
                          size: .large, isFullWidth: true) { showToast = true }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 100)
            }
            .padding(.top,16)
        }
        .navigationTitle("Forms")
        .navigationBarTitleDisplayMode(.inline)
        .sbToast(isPresented: $showToast, message: "Settings saved!", type: .success)
    }

    @ViewBuilder
    func sectionCard<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(title)
            SBCard(style: .elevated) { content() }
                .padding(.horizontal, 16)
        }
    }

    @ViewBuilder func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(.secondary)
            .textCase(.uppercase)
            .kerning(0.8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
    }
}

// MARK: - 4. Profile View

struct ProfileView: View {
    @State private var showOnboarding  = false
    @State private var showPaywall     = false
    @State private var showPermission  = false
    @State private var cartQuantity1   = 1
    @State private var cartQuantity2   = 2
    @State private var addedToCart: Set<String> = []

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                SBProfileHeader(
                    name: "Alex Johnson", username: "alexj",
                    bio: "Building beautiful iOS apps with SwiftBlocks 🚀",
                    stats: [
                        .init(value: "128",  label: "Projects"),
                        .init(value: "4.9k", label: "Stars"),
                        .init(value: "312",  label: "Followers")
                    ],
                    actionTitle: "Edit Profile"
                ) {}

                sectionHeader("Avatars")
                SBCard(style: .elevated) {
                    VStack(spacing: 16) {
                        HStack(spacing: 16) {
                            SBAvatar(name: "Alice Wang", size: .small)
                            SBAvatar(name: "Bob Chen",   size: .medium,  color: .purple)
                            SBAvatar(name: "Carol Kim",  size: .large,   color: .orange, showBadge: true)
                            SBAvatar(name: "David Lee",  size: .xlarge,  color: .green)
                        }
                        SBAvatarStack(names: ["Alice hawjeakw", "Bob", "Carol", "David", "Eve", "Frank"])
                    }
                }
                .padding(.horizontal, 16)

                sectionHeader("Contacts")
                SBListSection {
                    SBContactRow(name: "Alice Wang",   role: "iOS Engineer",        avatarColor: .blue,   trailingIcon: "message.fill") {}
                    Divider().padding(.leading, 72)
                    SBContactRow(name: "Bob Martinez", role: "Product Designer",    avatarColor: .purple, trailingIcon: "phone.fill")   {}
                    Divider().padding(.leading, 72)
                    SBContactRow(name: "Carol Singh",  role: "Engineering Manager", avatarColor: .orange, trailingIcon: "video.fill")   {}
                }
                .padding(.horizontal, 16)

                sectionHeader("Product Cards")
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 14) {
                        SBProductCard(name: "Pro Plan", price: "$9.99", originalPrice: "$19.99",
                                       badge: "50% OFF", icon: "crown.fill", rating: 4.8,
                                       isInCart: addedToCart.contains("pro")) { addedToCart.insert("pro") }
                            .frame(width: 200)
                        SBProductCard(name: "Team License", price: "$49/mo",
                                       icon: "person.3.fill", rating: 4.5,
                                       isInCart: addedToCart.contains("team")) { addedToCart.insert("team") }
                            .frame(width: 200)
                        SBProductCard(name: "Enterprise", price: "Custom",
                                       icon: "building.2.fill", isInCart: false) {}
                            .frame(width: 200)
                    }
                    .padding(.horizontal, 16)
                }

                sectionHeader("Cart")
                SBCard(style: .elevated) {
                    VStack(spacing: 12) {
                        SBCartRow(name: "Pro Plan (Monthly)", price: "$9.99",
                                   icon: "crown.fill",          quantity: $cartQuantity1) {}
                        Divider()
                        SBCartRow(name: "UI Component Pack",   price: "$4.99",
                                   icon: "square.grid.2x2.fill", quantity: $cartQuantity2) {}
                    }
                }
                .padding(.horizontal, 16)

                SBOrderSummary(
                    rows: [
                        .init(label: "Subtotal",       value: "$14.98"),
                        .init(label: "Discount (10%)", value: "-$1.50"),
                        .init(label: "Tax",            value: "$1.08"),
                        .init(label: "Total",          value: "$14.56", isTotal: true)
                    ],
                    total: "$14.56", onCheckout: {}
                )
                .padding(.horizontal, 16)

                sectionHeader("Onboarding & Overlays")
                VStack(spacing: 10) {
                    SBButton("Show Onboarding",     icon: "star.fill",  style: .primary,   isFullWidth: true) { showOnboarding = true }
                    SBButton("Show Paywall",         icon: "crown.fill", style: .secondary, isFullWidth: true) { showPaywall    = true }
                    SBButton("Show Permission Card", icon: "bell.badge", style: .outline,   isFullWidth: true) { showPermission = true }
                }
                .padding(.horizontal, 16)

                sectionHeader("Empty State")
                SBCard(style: .elevated) {
                    SBEmptyState(icon: "tray", title: "No items yet",
                                  description: "Add your first item to get started with SwiftBlocks",
                                  actionTitle: "Add Item") {}
                        .frame(height: 200)
                }
                .padding(.horizontal, 16)

                Spacer(minLength: 100)
            }
            // ── CHANGE: was 16, now 56 ──
            
            .padding(.top,16)
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
//        .modifier(GlassNavBarModifier())
        .fullScreenCover(isPresented: $showOnboarding) {
            SBOnboardingView(pages: [
                .init(icon: "star.fill",    title: "Welcome to SwiftBlocks",
                      description: "A modern SwiftUI component library built for iOS 17+ and optimized for iOS 26 Liquid Glass.", accentColor: .blue),
                .init(icon: "sparkles",     title: "Liquid Glass Ready",
                      description: "Every component automatically uses iOS 26 Liquid Glass with beautiful fallbacks.", accentColor: .purple),
                .init(icon: "paintpalette", title: "Fully Themeable",
                      description: "Use built-in themes or define your own design tokens to match your brand perfectly.", accentColor: .orange)
            ]) { showOnboarding = false }
        }
        .sheet(isPresented: $showPaywall) {
            SBPaywallView(
                title: "Unlock SwiftBlocks Pro",
                subtitle: "Access all components & Glass effects",
                plans: [
                    .init(id: "monthly", name: "Monthly", price: "$9.99",  period: "/month",
                          features: ["All components", "iOS 26 Glass", "Email support"]),
                    .init(id: "yearly",  name: "Yearly",  price: "$59.99", period: "/year",
                          features: ["Everything in Monthly", "Priority support", "Save 50%"], isFeatured: true)
                ],
                onPurchase: { _ in showPaywall = false },
                onRestore:  {},
                onDismiss:  { showPaywall = false }
            )
        }
        .sheet(isPresented: $showPermission) {
            SBPermissionCard(
                type: .notifications,
                description: "Get notified about new components, updates, and tips for building better apps.",
                onAllow: { showPermission = false },
                onDeny:  { showPermission = false }
            )
            .presentationDetents([.medium])
        }
    }

    @ViewBuilder func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(.secondary)
            .textCase(.uppercase)
            .kerning(0.8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
    }
}

struct ExtrasView: View {
    @State private var otpCode       = ""
    @State private var promptText    = ""
    @State private var showSnackbar  = false
    @State private var showAlert     = false
    @State private var selectedChips = Set<String>()
    @State private var password      = ""
    @State private var tickSliderValue: Double = 16
    @State private var neutralSliderValue: Double = 0.0

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                SBPageHeader(title: "Extras", subtitle: "Chips, OTP, Alerts & More")
                sectionHeader("iOS 26 Toolbars & Sliders")
                VStack(spacing: 12) {

                    // Tick Slider
                    SBCard(style: .elevated) {
                        VStack(spacing: 20) {
                            Text("SBTickSlider (with tick marks)")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            SBTickSlider(
                                "Font Size",
                                value: $tickSliderValue,
                                range: 12...28,
                                step: 2,
                                format: { "\(Int($0))pt" }
                            )

                            Divider()

                            Text("SBNeutralSlider (with center point)")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            SBNeutralSlider(
                                "Balance",
                                value: $neutralSliderValue,
                                range: -1.0...1.0,
                                neutralValue: 0,
                                step: 0.1
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                }
                sectionHeader("iOS 26 New APIs")
                VStack(spacing: 12) {

                    // Async Image
                    SBCard(style: .elevated) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("SBAsyncImage")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(.secondary)
                            SBAsyncImage(
                                url: URL(string: "https://picsum.photos/400/225"),
                                cornerRadius: 12,
                                aspectRatio: 16/9
                            )
                        }
                        .padding(16)
                    }
                    .padding(.horizontal, 16)

                    // Glass Effect Container
                    SBCard(style: .elevated) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("SBGlassEffectContainer")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(.secondary)
                            SBGlassEffectContainer(spacing: 8) {
                                Text("Glass A")
                                    .padding(12)
                                    .frame(maxWidth: .infinity)
                                    .nativeGlass()
                                Text("Glass B")
                                    .padding(12)
                                    .frame(maxWidth: .infinity)
                                    .nativeGlass()
                            }
                        }
                        .padding(16)
                    }
                    .padding(.horizontal, 16)

                    // Role Button
                    SBCard(style: .elevated) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(" eButton")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(.secondary)
                            SBRoleButton("Delete", icon: "trash", role: .destructive) {}
                            SBRoleButton("Cancel", icon: "xmark",  role: .cancel)      {}
                        }
                        .padding(16)
                    }
                    .padding(.horizontal, 16)
                }
                sectionHeader("Chips")
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(["SwiftUI", "iOS 26", "Glass", "Components", "Theming"], id: \.self) { tag in
                            SBChip(
                                tag,
                                icon: selectedChips.contains(tag) ? "checkmark" : nil,
                                isSelected: selectedChips.contains(tag)
                            ) {
                                if selectedChips.contains(tag) { selectedChips.remove(tag) }
                                else { selectedChips.insert(tag) }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }

                sectionHeader("OTP Input")
                SBCard(style: .elevated) {
                    VStack(spacing: 12) {
                        SBOTPInput(length: 6, code: $otpCode) { code in
                            print("OTP entered: \(code)")
                        }
                        if otpCode.count == 6 {
                            SBBadge("✓ Code entered", color: .green, style: .filled)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 16)

                sectionHeader("Password Field")
                SBCard(style: .elevated) {
                    SBPasswordField("Password", placeholder: "Enter your password", text: $password)
                }
                .padding(.horizontal, 16)

                sectionHeader("States")
                VStack(spacing: 12) {
                    SBCard(style: .elevated) {
                        SBSuccessState(
                            title: "Payment Successful",
                            description: "Your order has been placed and will arrive in 3-5 days.",
                            actionTitle: "View Order"
                        ) {}
                    }
                    .padding(.horizontal, 16)

                    SBCard(style: .elevated) {
                        SBErrorState(
                            title: "Payment Failed",
                            description: "We couldn't process your card. Please check your details.",
                            actionTitle: "Try Again"
                        ) {}
                    }
                    .padding(.horizontal, 16)
                }

                sectionHeader("Glass Card")
                SBGlassCard {
                    SBInfoCard(
                        title: "SBGlassCard",
                        description: "Explicit named glass card component — single clean layer",
                        icon: "sparkles"
                    )
                    .padding(16)
                }
                .padding(.horizontal, 16)

                sectionHeader("Snackbar & Alert")
                VStack(spacing: 10) {
                    SBButton("Show Snackbar", icon: "bell", style: .secondary, isFullWidth: true) {
                        showSnackbar = true
                    }
                    SBButton("Show Alert", icon: "exclamationmark.triangle", style: .glass, isFullWidth: true) {
                        showAlert = true
                    }
                }
                .padding(.horizontal, 16)
               
                sectionHeader("Settings Rows")
                SBCard(style: .elevated) {
                    VStack(spacing: 0) {
                        SBSettingsRow(icon: "bell.fill",    iconColor: .red,    title: "Notifications", subtitle: "Push & in-app")
                        Divider().padding(.leading, 62)
                        SBSettingsRow(icon: "lock.fill",    iconColor: .blue,   title: "Privacy",       trailingText: "On")
                        Divider().padding(.leading, 62)
                        SBSettingsRow(icon: "moon.fill",    iconColor: .indigo, title: "Dark Mode",     trailingText: "Auto")
                        Divider().padding(.leading, 62)
                        SBSettingsRow(icon: "trash.fill",   iconColor: .red,    title: "Delete Account", showChevron: true)
                    }
                }
                .padding(.horizontal, 16)
                Spacer(minLength: 100)
            }
            .padding(.top,16)
        }
        .navigationTitle("Extra View")
        .navigationBarTitleDisplayMode(.inline)
//        .modifier(GlassNavBarModifier())
        .sbSnackbar(
            isPresented: $showSnackbar,
            message: "Changes saved successfully",
            action: .button(label: "Undo") { showSnackbar = false }
        )
        .sbAlert(
            isPresented: $showAlert,
            title: "Delete Account?",
            message: "This action cannot be undone. All your data will be permanently removed.",
            icon: "trash.fill",
            iconColor: .red,
            primaryLabel: "Delete",
            primaryAction: {},
            secondaryLabel: "Cancel"
        )
    }

    @ViewBuilder func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(.secondary)
            .textCase(.uppercase)
            .kerning(0.8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
    }
}

#Preview {
    ContentView()
}
