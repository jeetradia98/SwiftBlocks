// SwiftBlocks.swift
// SwiftBlocks SDK — Public Entry Point
// iOS 17+ compatible · iOS 26 Liquid Glass optimized
//
// Usage:
//   import SwiftBlocks
//
// GitHub: https://github.com/yourname/SwiftBlocks

// MARK: - Re-exports (all public types are auto-exported via SPM)
// Just import this module and all SB* types are available.

// Core
// - SBTheme          → theme engine + environment
// - SBGlass          → iOS 26 Liquid Glass + fallback

// Components
// - SBButton         → primary, secondary, outline, ghost, destructive, glass
// - SBIconButton     → circular icon button
// - SBCard           → elevated, filled, outlined, glass cards
// - SBStatCard       → metric/dashboard stat card
// - SBInfoCard       → icon + title + description card
// - SBTextField      → outlined, filled, underlined, glass inputs
// - SBSearchBar      → search input with clear button
// - SBToast          → success/error/warning/info toasts
// - SBBadge          → filled, outlined, soft badges
// - SBStatusBanner   → dismissible status banners
// - SBEmptyState     → empty state with optional CTA
// - SBLoader         → circular, linear, dots, pulse loaders
// - SBSkeleton       → shimmer skeleton loader
// - SBSkeletonCard   → preset skeleton card layout
// - SBNavBar         → navigation bar with actions
// - SBPageHeader     → large page title with badge
// - SBOnboardingView → multi-page onboarding flow
// - SBPermissionCard → permission request card
// - SBPaywallView    → subscription paywall

// iOS 26 Glass Components
// - SBGlassCard      → glass card container
// - SBGlassButton    → floating glass button
// - SBFloatingGlassBar → glass tab bar

// View Modifiers
// .sbTheme()         → apply custom theme
// .sbGlass()         → apply glass effect
// .sbGlassCard()     → glass card shorthand
// .sbGlassCapsule()  → glass capsule shorthand
// .sbToast()         → show toast notification
// .sbBottomSheet()   → present bottom sheet
// .sbLoading()       → show loading overlay
