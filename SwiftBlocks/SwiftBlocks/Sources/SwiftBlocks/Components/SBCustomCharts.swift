// SBCustomCharts.swift
// SwiftBlocks — Custom Chart Components
// Pure SwiftUI implementations of Line, Area, Horizontal Bar, and Grouped Bar charts.
// Add this file to: SwiftBlocks → Sources → SwiftBlocks → Components → SBChart group

import SwiftUI

// MARK: - SBLineChartView

/// Smooth line chart with grid lines and data point dots.
struct SBLineChartView: View {
    let title: String
    let points: [Double]
    let labels: [String]

    private var maxVal: Double { points.max() ?? 1 }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 15, weight: .semibold))

            GeometryReader { geo in
                let w    = geo.size.width
                let h    = geo.size.height
                let step = w / CGFloat(points.count - 1)

                ZStack {
                    // Faint horizontal grid lines
                    ForEach(0..<4) { i in
                        let y = h - h * CGFloat(i) / 3
                        Path { p in
                            p.move(to:    CGPoint(x: 0, y: y))
                            p.addLine(to: CGPoint(x: w, y: y))
                        }
                        .stroke(Color.secondary.opacity(0.15), lineWidth: 1)
                    }

                    // Line
                    Path { p in
                        for (i, val) in points.enumerated() {
                            let pt = CGPoint(x: CGFloat(i) * step,
                                            y: h - h * CGFloat(val / maxVal))
                            if i == 0 { p.move(to: pt) } else { p.addLine(to: pt) }
                        }
                    }
                    .stroke(Color.blue,
                            style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))

                    // Data-point dots
                    ForEach(points.indices, id: \.self) { i in
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 7, height: 7)
                            .position(x: CGFloat(i) * step,
                                      y: h - h * CGFloat(points[i] / maxVal))
                    }
                }
            }
            .frame(height: 120)

            // X-axis labels
            HStack {
                ForEach(labels.indices, id: \.self) { i in
                    Text(labels[i])
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                    if i < labels.count - 1 { Spacer() }
                }
            }
        }
        .padding(16)
    }
}

// MARK: - SBAreaChartView

/// Gradient-filled area / sparkline chart.
struct SBAreaChartView: View {
    let title: String
    let points: [Double]
    let labels: [String]

    private var maxVal: Double { points.max() ?? 1 }

    /// Helper lives on the struct — func declarations are not allowed
    /// inside @ViewBuilder closures (compiler error).
    private func point(_ i: Int, w: CGFloat, h: CGFloat) -> CGPoint {
        let step = w / CGFloat(points.count - 1)
        return CGPoint(x: CGFloat(i) * step,
                       y: h - h * CGFloat(points[i] / maxVal))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 15, weight: .semibold))

            GeometryReader { geo in
                let w    = geo.size.width
                let h    = geo.size.height
                let step = w / CGFloat(points.count - 1)

                ZStack {
                    // Gradient fill
                    Path { p in
                        p.move(to: CGPoint(x: 0, y: h))
                        for i in points.indices { p.addLine(to: point(i, w: w, h: h)) }
                        p.addLine(to: CGPoint(x: CGFloat(points.count - 1) * step, y: h))
                        p.closeSubpath()
                    }
                    .fill(LinearGradient(
                        colors: [Color.blue.opacity(0.35), Color.blue.opacity(0.0)],
                        startPoint: .top, endPoint: .bottom
                    ))

                    // Stroke
                    Path { p in
                        for i in points.indices {
                            if i == 0 { p.move(to: point(i, w: w, h: h)) }
                            else       { p.addLine(to: point(i, w: w, h: h)) }
                        }
                    }
                    .stroke(Color.blue,
                            style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                }
            }
            .frame(height: 100)

            // X-axis labels
            HStack {
                ForEach(labels.indices, id: \.self) { i in
                    Text(labels[i])
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                    if i < labels.count - 1 { Spacer() }
                }
            }
        }
        .padding(16)
    }
}

// MARK: - SBHorizontalBarChartView

/// Horizontal progress-bar chart — great for rankings and channel breakdowns.
struct SBHorizontalBarChartView: View {
    let title: String
    let items: [(label: String, value: Double)]

    private var maxVal: Double { items.map(\.value).max() ?? 1 }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 15, weight: .semibold))

            VStack(spacing: 10) {
                ForEach(items.indices, id: \.self) { i in
                    HStack(spacing: 10) {
                        Text(items[i].label)
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary)
                            .frame(width: 60, alignment: .leading)

                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 4, style: .continuous)
                                    .fill(Color.secondary.opacity(0.12))
                                RoundedRectangle(cornerRadius: 4, style: .continuous)
                                    .fill(Color.blue.opacity(0.8))
                                    .frame(width: geo.size.width * CGFloat(items[i].value / maxVal))
                            }
                        }
                        .frame(height: 10)

                        Text("\(Int(items[i].value))%")
                            .font(.system(size: 12, weight: .medium))
                            .frame(width: 34, alignment: .trailing)
                    }
                }
            }
        }
        .padding(16)
    }
}

// MARK: - SBGroupedBarChartView

/// Side-by-side grouped bar chart for comparing two data series.
// MARK: - SBGroupedBarChartView

struct SBGroupedBarChartView: View {
    let title: String
    let groups: [String]
    let seriesA: (label: String, values: [Double], color: Color)
    let seriesB: (label: String, values: [Double], color: Color)

    private var maxVal: Double { (seriesA.values + seriesB.values).max() ?? 1 }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Title + legend
            HStack {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                Spacer()
                HStack(spacing: 12) {
                    legendDot(color: seriesA.color, label: seriesA.label)
                    legendDot(color: seriesB.color, label: seriesB.label)
                }
            }

            GeometryReader { geo in
                let barAreaH   = geo.size.height - 24  // 24pt reserved for x-axis labels
                let groupWidth = geo.size.width / CGFloat(groups.count)
                let barWidth   = (groupWidth - 20) / 2  // gap between groups

                ZStack(alignment: .bottomLeading) {
                    // ✅ Horizontal grid lines anchored to bar area
                    ForEach(0..<4) { i in
                        let y = barAreaH - barAreaH * CGFloat(i) / 3
                        Path { p in
                            p.move(to:    CGPoint(x: 0,            y: y))
                            p.addLine(to: CGPoint(x: geo.size.width, y: y))
                        }
                        .stroke(Color.secondary.opacity(0.12), lineWidth: 1)
                    }

                    // ✅ Bars — each group positioned absolutely so baseline is consistent
                    ForEach(groups.indices, id: \.self) { i in
                        let groupX = CGFloat(i) * groupWidth + (groupWidth - barWidth * 2 - 4) / 2

                        let heightA = max(4, barAreaH * CGFloat(seriesA.values[i] / maxVal))
                        let heightB = max(4, barAreaH * CGFloat(seriesB.values[i] / maxVal))

                        // Series A bar
                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                            .fill(seriesA.color)
                            .frame(width: barWidth, height: heightA)
                            // ✅ position from bottom baseline
                            .position(
                                x: groupX + barWidth / 2,
                                y: barAreaH - heightA / 2
                            )

                        // Series B bar
                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                            .fill(seriesB.color)
                            .frame(width: barWidth, height: heightB)
                            .position(
                                x: groupX + barWidth + 4 + barWidth / 2,
                                y: barAreaH - heightB / 2
                            )
                    }

                    // ✅ X-axis baseline
                    Path { p in
                        p.move(to:    CGPoint(x: 0,             y: barAreaH))
                        p.addLine(to: CGPoint(x: geo.size.width, y: barAreaH))
                    }
                    .stroke(Color.secondary.opacity(0.25), lineWidth: 1)

                    // ✅ X-axis labels pinned to bottom
                    ForEach(groups.indices, id: \.self) { i in
                        let groupX = CGFloat(i) * groupWidth + groupWidth / 2
                        Text(groups[i])
                            .font(.system(size: 10))
                            .foregroundStyle(.secondary)
                            .position(x: groupX, y: barAreaH + 14)
                    }
                }
            }
            .frame(height: 140)
        }
        .padding(16)
    }

    @ViewBuilder
    private func legendDot(color: Color, label: String) -> some View {
        HStack(spacing: 4) {
            Circle().fill(color).frame(width: 8, height: 8)
            Text(label).font(.system(size: 11)).foregroundStyle(.secondary)
        }
    }
}
