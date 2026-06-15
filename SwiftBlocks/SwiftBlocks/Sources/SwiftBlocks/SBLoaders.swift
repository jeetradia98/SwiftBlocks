// SBLoaders.swift
// SwiftBlocks — Loading & Skeleton Components

import SwiftUI

// MARK: - SBLoader

public enum SBLoaderStyle {
    case circular
    case linear
    case dots
    case pulse
}

public struct SBLoader: View {
    let style: SBLoaderStyle
    let color: Color?
    let size: CGFloat

    @Environment(\.sbTheme) private var theme
    @State private var isAnimating = false
    @State private var progress: CGFloat = 0.0

    public init(
        style: SBLoaderStyle = .circular,
        color: Color? = nil,
        size: CGFloat = 44
    ) {
        self.style = style
        self.color = color
        self.size = size
    }

    private var tint: Color { color ?? theme.primary }

    public var body: some View {
        switch style {
        case .circular: circularLoader
        case .linear:   linearLoader
        case .dots:     dotsLoader
        case .pulse:    pulseLoader
        }
    }

    private var circularLoader: some View {
        ProgressView()
            .progressViewStyle(.circular)
            .tint(tint)
            .scaleEffect(size / 44)
    }

    private var linearLoader: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(tint.opacity(0.15))
                    .frame(height: 4)
                Capsule()
                    .fill(tint)
                    .frame(width: geo.size.width * progress, height: 4)
                    .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: progress)
            }
        }
        .frame(height: 4)
        .onAppear { progress = 0.85 }
    }

    private var dotsLoader: some View {
        HStack(spacing: 6) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(tint)
                    .frame(width: size / 5, height: size / 5)
                    .scaleEffect(isAnimating ? 1.0 : 0.5)
                    .opacity(isAnimating ? 1.0 : 0.3)
                    .animation(
                        .easeInOut(duration: 0.5)
                        .repeatForever()
                        .delay(Double(index) * 0.15),
                        value: isAnimating
                    )
            }
        }
        .onAppear { isAnimating = true }
    }

    private var pulseLoader: some View {
        ZStack {
            Circle()
                .fill(tint.opacity(0.3))
                .frame(width: size, height: size)
                .scaleEffect(isAnimating ? 1.5 : 1.0)
                .opacity(isAnimating ? 0 : 0.6)
                .animation(.easeOut(duration: 1.0).repeatForever(autoreverses: false), value: isAnimating)

            Circle()
                .fill(tint)
                .frame(width: size * 0.5, height: size * 0.5)
        }
        .onAppear { isAnimating = true }
    }
}

// MARK: - SBSkeleton (Shimmer)

public struct SBSkeleton: View {
    let width: CGFloat?
    let height: CGFloat
    let radius: CGFloat

    @State private var shimmerOffset: CGFloat = -1.0

    public init(
        width: CGFloat? = nil,
        height: CGFloat = 16,
        radius: CGFloat = 8
    ) {
        self.width = width
        self.height = height
        self.radius = radius
    }

    public var body: some View {
        RoundedRectangle(cornerRadius: radius, style: .continuous)
            .fill(Color(.systemGray5))
            .frame(width: width, height: height)
            .overlay {
                GeometryReader { geo in
                    RoundedRectangle(cornerRadius: radius, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [.clear, .white.opacity(0.5), .clear],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .offset(x: shimmerOffset * geo.size.width)
                        .onAppear {
                            withAnimation(
                                .linear(duration: 1.4)
                                .repeatForever(autoreverses: false)
                            ) {
                                shimmerOffset = 2.0
                            }
                        }
                }
            }
            .clipped()
    }
}

// MARK: - SBSkeletonCard (Preset layouts)

public struct SBSkeletonCard: View {
    public init() {}

    public var body: some View {
        HStack(spacing: 12) {
            SBSkeleton(width: 52, height: 52, radius: 14)

            VStack(alignment: .leading, spacing: 8) {
                SBSkeleton(height: 14, radius: 7)
                SBSkeleton(width: 120, height: 12, radius: 6)
            }
            Spacer()
        }
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

// MARK: - SBLoadingOverlay

public struct SBLoadingOverlay: ViewModifier {
    let isLoading: Bool
    let message: String?

    @Environment(\.sbTheme) private var theme

    public func body(content: Content) -> some View {
        ZStack {
            content
                .disabled(isLoading)
                .blur(radius: isLoading ? 2 : 0)

            if isLoading {
                // AFTER — single nativeGlass layer, explicit shape, no nesting
                VStack(spacing: 16) {
                    SBLoader(style: .circular, size: 40)

                    if let message {
                        Text(message)
                            .font(theme.fontBody)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(28)
                .background {
                    let shape = RoundedRectangle(cornerRadius: 20, style: .continuous)
                    if #available(iOS 26, *) {
                        shape.glassEffect(in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                    } else {
                        shape.fill(.ultraThinMaterial)
                            .overlay(shape.strokeBorder(.white.opacity(0.12), lineWidth: 0.5))
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .transition(.opacity.combined(with: .scale(scale: 0.9)))
            }
        }
        .animation(.spring(response: 0.3), value: isLoading)
    }
}

public extension View {
    func sbLoading(_ isLoading: Bool, message: String? = nil) -> some View {
        modifier(SBLoadingOverlay(isLoading: isLoading, message: message))
    }
}
