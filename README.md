# SwiftBlocks

A modern, production-ready SwiftUI component library — built for iOS 17+ and optimized for iOS 26 Liquid Glass.


## What is SwiftBlocks?

SwiftBlocks is a practical SwiftUI design system for startup apps, SaaS products, AI apps, and production-grade iOS projects.

Stop rebuilding the same buttons, cards, inputs, sheets, empty states, loaders, permission screens, onboarding flows, and chat components for every app. SwiftBlocks gives you 25+ polished, themeable, accessible components that work on iOS 17 and automatically enhance on iOS 26 with Liquid Glass.

---

## Features

- 25+ production-ready components
- iOS 26 Liquid Glass via `glassEffect` — automatic fallback on iOS 17–25
- Full dark mode and light mode support
- Dynamic Type and VoiceOver ready
- Themeable via `SBTheme` — swap colors, fonts, and radius tokens
- SPM distribution — one line install
- Full demo app included with 5 screens

---

## Installation

### Swift Package Manager

In Xcode: **File → Add Package Dependencies**

```
https://github.com/jeetradia98/SwiftBlocks
```

Or add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/jeetradia98/SwiftBlocks", from: "1.0.0")
]
```

Then import:

```swift
import SwiftBlocks
```

---

## Quick Start

```swift
import SwiftBlocks
import SwiftUI

struct MyView: View {
    var body: some View {
        VStack(spacing: 16) {
            SBButton("Get Started", style: .primary, isFullWidth: true) {
                print("Tapped")
            }

            SBCard(style: .elevated) {
                SBInfoCard(title: "Revenue", description: "$12,400 this month", icon: "creditcard")
            }

            SBGlassCard {
                Text("iOS 26 Liquid Glass")
                    .padding()
            }
        }
        .sbTheme(.default)
    }
}
```

---

## Component Gallery

### Buttons

```swift
SBButton("Primary",     style: .primary,     isFullWidth: true) {}
SBButton("Secondary",   style: .secondary,   isFullWidth: true) {}
SBButton("Outline",     style: .outline,     isFullWidth: true) {}
SBButton("Destructive", style: .destructive, isFullWidth: true) {}
SBButton("Glass",       style: .glass,       isFullWidth: true) {}
SBButton("Loading",     style: .primary,     isFullWidth: true, isLoading: true) {}

// Icon buttons
SBIconButton("heart.fill", style: .primary)   {}
SBIconButton("bell.fill",  style: .secondary) {}
SBIconButton("star.fill",  style: .glass)     {}

// Glass floating button
SBGlassButton("Floating Glass", icon: "plus") {}
```

---

### Cards

```swift
// Elevated card with shadow
SBCard(style: .elevated) {
    SBInfoCard(title: "Elevated Card", description: "Default with shadow", icon: "square.stack")
}

// Outlined card
SBCard(style: .outlined) {
    SBInfoCard(title: "Outlined Card", description: "Border, no fill", icon: "square")
}

// iOS 26 Liquid Glass card
SBGlassCard(radius: 20) {
    SBInfoCard(title: "Glass Card", description: "Liquid Glass on iOS 26+", icon: "sparkles")
}
```

---

### Inputs & Forms

```swift
// Text field
SBTextField("Email", placeholder: "you@example.com",
            text: $email, leadingIcon: "envelope")

// Password field with show/hide toggle
SBPasswordField("Password", placeholder: "Enter password", text: $password)

// Search bar
SBSearchBar(text: $searchQuery)

// OTP input — 4 or 6 digits, SMS autofill ready
SBOTPInput(length: 6, code: $otpCode) { code in
    print("OTP: \(code)")
}

// Character count field
SBCharacterCountField("Bio", placeholder: "Tell your story...", text: $bio, limit: 160)
```

---

### Feedback

```swift
// Badges
SBBadge("New",  color: .blue,   style: .filled)
SBBadge("Beta", color: .orange, style: .soft)
SBBadge("Live", color: .green,  style: .outlined)

// Status banners
SBStatusBanner("App is up to date.",             type: .success)
SBStatusBanner("Scheduled maintenance tonight.", type: .warning)
SBStatusBanner("New features available!",        type: .info)

// Toast
.sbToast(isPresented: $showToast, message: "Saved!", type: .success)

// Snackbar with action
.sbSnackbar(isPresented: $show, message: "Changes saved",
            action: .button(label: "Undo") { })

// Custom alert
.sbAlert(isPresented: $showAlert,
         title: "Delete Account?",
         message: "This cannot be undone.",
         icon: "trash.fill", iconColor: .red,
         primaryLabel: "Delete", primaryAction: {},
         secondaryLabel: "Cancel")
```

---

### Loaders & Skeleton

```swift
// Loaders
SBLoader(style: .circular)
SBLoader(style: .dots)
SBLoader(style: .pulse)

// Skeleton loading placeholders
SBSkeletonCard()
SBSkeleton(height: 14)
SBSkeleton(width: 180, height: 12)

// Full screen loading overlay
.sbLoading(isLoading, message: "Refreshing data...")
```

---

### States

```swift
// Empty state
SBEmptyState(icon: "tray", title: "No items yet",
             description: "Add your first item to get started",
             actionTitle: "Add Item") {}

// Success state
SBSuccessState(title: "Payment Successful",
               description: "Your order has been placed.",
               actionTitle: "View Order") {}

// Error state
SBErrorState(title: "Payment Failed",
             description: "We couldn't process your card.",
             actionTitle: "Try Again") {}
```

---

### Navigation

```swift
// Standard nav bar
SBNavBar(title: "Settings", subtitle: "Manage preferences",
         trailingActions: [.init(icon: "ellipsis") {}])

// Glass nav bar (iOS 26 enhanced)
SBNavBar(title: "Glass NavBar", leadingAction: .back {},
         trailingActions: [.init(icon: "bell") {}], style: .glass)

// Floating glass tab bar
SBFloatingGlassBar(
    items: [
        .init(title: "Dashboard", icon: "chart.bar",       iconFilled: "chart.bar.fill"),
        .init(title: "Profile",   icon: "person",           iconFilled: "person.fill"),
        .init(title: "Settings",  icon: "gearshape",        iconFilled: "gearshape.fill")
    ],
    selection: $selectedTab
)

// Bottom sheet
.sbBottomSheet(isPresented: $showSheet) {
    VStack { Text("Sheet content") }
        .padding(20)
}
```

---

### Profile & Avatars

```swift
// Profile header
SBProfileHeader(
    name: "Alex Johnson", username: "alexj",
    bio: "Building beautiful iOS apps 🚀",
    stats: [
        .init(value: "128", label: "Projects"),
        .init(value: "4.9k", label: "Stars")
    ],
    actionTitle: "Edit Profile"
) {}

// Avatars
SBAvatar(name: "Alice Wang", size: .medium, color: .blue)
SBAvatar(name: "Bob Chen",   size: .large,  color: .purple, showBadge: true)

// Avatar stack
SBAvatarStack(names: ["Alice", "Bob", "Carol", "David", "Eve"])
```

---

### Settings

```swift
// Settings row — Apple-style icon + title + trailing
SBSettingsRow(icon: "bell.fill",  iconColor: .red,   title: "Notifications", subtitle: "Push & in-app")
SBSettingsRow(icon: "lock.fill",  iconColor: .blue,  title: "Privacy",       trailingText: "On")
SBSettingsRow(icon: "trash.fill", iconColor: .red,   title: "Delete Account", showChevron: true)

// Toggle row
SBToggleRow(icon: "bell.fill", iconColor: .red, title: "Notifications", isOn: $notifications)

// List section with header and footer
SBListSection(header: "Preferences", footer: "Changes apply immediately") {
    SBToggleRow(icon: "moon.fill", iconColor: .indigo, title: "Dark Mode", isOn: $darkMode)
}
```

---

### Chips & Tags

```swift
SBChip("SwiftUI")
SBChip("iOS 26", isSelected: true)
SBChip("Remove", onDismiss: { }) { }
```

---

### AI Components

```swift
// AI prompt bar with suggestions
SBAIPromptBar(
    text: $promptText,
    suggestions: ["Summarize this", "Explain simply", "Write a draft"],
    onSubmit: { prompt in print(prompt) }
)

// AI chat bubble
SBChatBubble(message, showTimestamp: true)

// Typing indicator
SBTypingIndicator()

// AI feature card
SBAIFeatureCard(icon: "sparkles", title: "Smart Suggestions",
                description: "AI-powered recommendations", accentColor: .purple) {}
```

---

### Commerce

```swift
// Product card
SBProductCard(name: "Pro Plan", price: "$9.99", originalPrice: "$19.99",
              badge: "50% OFF", icon: "crown.fill", rating: 4.8,
              isInCart: false) { }

// Cart row with quantity stepper
SBCartRow(name: "Pro Plan (Monthly)", price: "$9.99",
          icon: "crown.fill", quantity: $cartQuantity) {}

// Order summary
SBOrderSummary(
    rows: [
        .init(label: "Subtotal", value: "$14.98"),
        .init(label: "Tax",      value: "$1.08"),
        .init(label: "Total",    value: "$14.56", isTotal: true)
    ],
    total: "$14.56", onCheckout: {}
)
```

---

### Overlays & Onboarding

```swift
// Onboarding flow
SBOnboardingView(pages: [
    .init(icon: "star.fill", title: "Welcome",
          description: "Build beautiful apps faster.", accentColor: .blue),
    .init(icon: "sparkles",  title: "iOS 26 Ready",
          description: "Liquid Glass out of the box.", accentColor: .purple)
]) { /* onComplete */ }

// Paywall
SBPaywallView(
    title: "Unlock Pro",
    subtitle: "Access all components",
    plans: [
        .init(id: "monthly", name: "Monthly", price: "$9.99", period: "/month",
              features: ["All components", "iOS 26 Glass"]),
        .init(id: "yearly",  name: "Yearly",  price: "$59.99", period: "/year",
              features: ["Everything + Save 50%"], isFeatured: true)
    ],
    onPurchase: { _ in }, onRestore: {}, onDismiss: {}
)

// Permission card
SBPermissionCard(type: .notifications,
                 description: "Get notified about updates.",
                 onAllow: {}, onDeny: {})
```

---

## iOS 26 Liquid Glass

SwiftBlocks automatically uses iOS 26 Liquid Glass where appropriate and falls back gracefully on iOS 17–25.

```swift
// Use nativeGlass modifier directly
myView
    .nativeGlass(cornerRadius: 20)

// Or use sbGlass for full control
myView
    .sbGlass(style: .regular, shape: .roundedRectangle(radius: 20))
    .sbGlass(style: .thick,   shape: .capsule)

// SBGlassCard container
SBGlassCard(radius: 20) {
    Text("Glass content")
}

// SBGlassButton
SBGlassButton("Action", icon: "sparkles") {}

// SBFloatingGlassBar (iOS 26 tab bar)
SBFloatingGlassBar(items: [...], selection: $tab)
```

iOS 26 uses `.glassEffect(_:in:)` from the native SDK.
iOS 17–25 uses `.ultraThinMaterial` with a subtle border — no broken UI, ever.

---

## Theming

Every component reads from the environment theme. Apply once at the root:

```swift
ContentView()
    .sbTheme(.default)
```

Customize:

```swift
extension SBTheme {
    static let myBrand = SBTheme(
        primary: Color("BrandBlue"),
        // ... other tokens
    )
}

ContentView()
    .sbTheme(.myBrand)
```

---

## Demo App

The included demo app shows all components across 5 screens:

| Screen | Components |
|---|---|
| Dashboard | Metrics, charts (bar, line, area, ring, grouped), stat cards, toasts |
| Components | Buttons, cards, badges, loaders, skeleton, media, AI chat, navigation |
| Forms | Text fields, password, search, OTP, stepper, slider, rating, toggles, pickers |
| Profile | Avatars, contacts, product cards, cart, order summary, onboarding, paywall |
| Extras | Chips, OTP input, password field, AI prompt bar, success/error states, snackbar, alert, settings rows |

---

## Requirements

- iOS 17.0+
- Xcode 16+
- Swift 5.9+

---

## License

MIT License — free for personal and commercial use.

---


*SwiftBlocks — Build beautiful iOS apps faster.*
