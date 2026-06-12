// SBChart.swift
// SwiftBlocks — Chart Components (pure SwiftUI, no Swift Charts dependency)
// FIXED: SBBarChart value labels no longer overlap/clip the tallest bar.
// Root cause: value labels, GeometryReader bars, and day labels all shared
// the same frame(height:120). The tallest bar filled 100% of that height,
// leaving 0pt for the value label above it — it rendered outside the frame
// and was clipped. Fix: separate the bar area (fixed height) from the labels
// so each layer has its own guaranteed space.

import SwiftUI

// MARK: - Chart Data

public struct SBChartDataPoint: Identifiable {
    public let id = UUID()
    public let label: String
    public let value: Double
    public let color: Color?

    public init(label: String, value: Double, color: Color? = nil) {
        self.label = label
        self.value = value
        self.color = color
    }
}

// MARK: - SBBarChart

public struct SBBarChart: View {
    let title: String?
    let data: [SBChartDataPoint]
    let showValues: Bool
    let animated: Bool

    @State private var appeared = false
    @Environment(\.sbTheme) private var theme

    // Fixed heights for each layer — bars never steal space from labels
    private let barAreaHeight: CGFloat  = 120   // space bars grow into
    private let valueLabelHeight: CGFloat = 16  // above each bar
    private let dayLabelHeight: CGFloat   = 14  // below each bar

    public init(
        title: String? = nil,
        data: [SBChartDataPoint],
        showValues: Bool = true,
        animated: Bool = true
    ) {
        self.title = title
        self.data = data
        self.showValues = showValues
        self.animated = animated
    }

    private var maxValue: Double { data.map(\.value).max() ?? 1 }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let title {
                Text(title)
                    .font(theme.fontHeadline)
                    .foregroundStyle(.primary)
            }

            HStack(alignment: .bottom, spacing: 8) {
                ForEach(data) { point in
                    let fraction = appeared ? CGFloat(point.value / maxValue) : 0
                    let barColor = point.color ?? theme.primary

                    VStack(spacing: 0) {

                        // ── 1. Value label — own fixed row, never inside bar area ──
                        if showValues {
                            Text(formatValue(point.value))
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundStyle(.secondary)
                                .opacity(appeared ? 1 : 0)
                                .frame(height: valueLabelHeight)
                        }

                        // ── 2. Bar area — GeometryReader fills this fixed height only ──
                        GeometryReader { geo in
                            VStack(spacing: 0) {
                                Spacer(minLength: 0)
                                RoundedRectangle(cornerRadius: 6, style: .continuous)
                                    .fill(barColor.gradient)
                                    .frame(height: geo.size.height * fraction)
                            }
                        }
                        .frame(height: barAreaHeight)

                        // ── 3. Day label — own fixed row below bar area ──
                        Text(point.label)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                            .frame(height: dayLabelHeight)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            // Total height = value label + bar area + day label — no overlap possible
            .frame(height: valueLabelHeight + barAreaHeight + dayLabelHeight)
            .onAppear {
                if animated {
                    withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.1)) {
                        appeared = true
                    }
                } else {
                    appeared = true
                }
            }
        }
    }

    private func formatValue(_ v: Double) -> String {
        v >= 1000 ? String(format: "%.1fk", v / 1000) : String(format: "%.0f", v)
    }
}

// MARK: - SBRingChart (Donut / Ring)

public struct SBRingChart: View {
    let segments: [SBChartDataPoint]
    let centerText: String?
    let centerSubtext: String?
    let lineWidth: CGFloat

    @State private var appeared = false
    @Environment(\.sbTheme) private var theme

    public init(
        segments: [SBChartDataPoint],
        centerText: String? = nil,
        centerSubtext: String? = nil,
        lineWidth: CGFloat = 24
    ) {
        self.segments = segments
        self.centerText = centerText
        self.centerSubtext = centerSubtext
        self.lineWidth = lineWidth
    }

    private var total: Double { segments.map(\.value).reduce(0, +) }

    private let palette: [Color] = [
        Color(red: 0.2, green: 0.4, blue: 1.0),
        Color(red: 0.5, green: 0.3, blue: 0.9),
        Color(red: 0.0, green: 0.8, blue: 0.7),
        Color(red: 1.0, green: 0.5, blue: 0.2),
        Color(red: 0.9, green: 0.2, blue: 0.5)
    ]

    public var body: some View {
        HStack(spacing: 20) {
            ZStack {
                ringArcs
                if let centerText {
                    VStack(spacing: 2) {
                        Text(centerText)
                            .font(theme.fontTitle)
                            .foregroundStyle(.primary)
                        if let sub = centerSubtext {
                            Text(sub)
                                .font(theme.fontCaption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .frame(width: 120, height: 120)
            .onAppear {
                withAnimation(.spring(response: 0.8, dampingFraction: 0.8)) {
                    appeared = true
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                ForEach(segments.indices, id: \.self) { index in
                    let seg = segments[index]
                    let color = seg.color ?? palette[index % palette.count]
                    let pct = total > 0 ? Int(seg.value / total * 100) : 0

                    HStack(spacing: 8) {
                        Circle().fill(color).frame(width: 10, height: 10)
                        Text(seg.label)
                            .font(theme.fontCaption)
                            .foregroundStyle(.primary)
                        Spacer()
                        Text("\(pct)%")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var ringArcs: some View {
        let tw = lineWidth
        ForEach(segments.indices, id: \.self) { index in
            let (start, end) = angleRange(for: index)
            let color = segments[index].color ?? palette[index % palette.count]

            Circle()
                .trim(from: appeared ? start : start, to: appeared ? end : start)
                .stroke(color, style: StrokeStyle(lineWidth: tw, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 0.7, dampingFraction: 0.8).delay(Double(index) * 0.05), value: appeared)
        }
    }

    private func angleRange(for index: Int) -> (CGFloat, CGFloat) {
        guard total > 0 else { return (0, 0) }
        let prior = segments.prefix(index).map(\.value).reduce(0, +)
        let start = prior / total
        let end = start + segments[index].value / total
        return (CGFloat(start), CGFloat(end))
    }
}

// MARK: - SBMetricRow

public struct SBMetricRow: View {
    let metrics: [SBMetric]

    @Environment(\.sbTheme) private var theme

    public init(metrics: [SBMetric]) {
        self.metrics = metrics
    }

    public var body: some View {
        HStack(spacing: 0) {
            ForEach(metrics.indices, id: \.self) { index in
                SBMetricCell(metric: metrics[index])
                if index < metrics.count - 1 {
                    Divider().frame(height: 40)
                }
            }
        }
        .padding(.vertical, 16)
        .background(theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: theme.radiusMD, style: .continuous))
    }
}

public struct SBMetric {
    public let value: String
    public let label: String
    public let trend: SBTrend?

    public init(value: String, label: String, trend: SBTrend? = nil) {
        self.value = value
        self.label = label
        self.trend = trend
    }
}

struct SBMetricCell: View {
    let metric: SBMetric
    @Environment(\.sbTheme) private var theme

    var body: some View {
        VStack(spacing: 4) {
            Text(metric.value)
                .font(theme.fontTitle)
                .foregroundStyle(.primary)
            Text(metric.label)
                .font(theme.fontCaption)
                .foregroundStyle(.secondary)
            if let trend = metric.trend {
                SBTrendBadge(trend: trend)
            }
        }
        .frame(maxWidth: .infinity)
    }
}
