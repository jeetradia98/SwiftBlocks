// SBForm.swift
// SwiftBlocks — Form & Input Helper Components

import SwiftUI

// MARK: - SBFormSection

/// A styled form section with title and content
public struct SBFormSection<Content: View>: View {
    let title: String?
    let description: String?
    let content: Content

    @Environment(\.sbTheme) private var theme

    public init(
        title: String? = nil,
        description: String? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.description = description
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let title {
                Text(title)
                    .font(theme.fontHeadline)
                    .foregroundStyle(.primary)
            }
            if let description {
                Text(description)
                    .font(theme.fontCaption)
                    .foregroundStyle(.secondary)
            }
            content
        }
    }
}

// MARK: - SBStepperRow

/// A row with a stepper for numeric input
public struct SBStepperRow: View {
    let title: String
    let subtitle: String?
    @Binding var value: Int
    let range: ClosedRange<Int>
    let step: Int

    @Environment(\.sbTheme) private var theme

    public init(
        title: String,
        subtitle: String? = nil,
        value: Binding<Int>,
        range: ClosedRange<Int> = 0...100,
        step: Int = 1
    ) {
        self.title = title
        self.subtitle = subtitle
        self._value = value
        self.range = range
        self.step = step
    }

    public var body: some View {
        HStack {
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

            HStack(spacing: 12) {
                Button {
                    if value - step >= range.lowerBound {
                        withAnimation(.spring(response: 0.2)) { value -= step }
                    }
                } label: {
                    Image(systemName: "minus")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(value <= range.lowerBound ? Color(.tertiaryLabel) : theme.primary)
                        .frame(width: 32, height: 32)
                        .background(theme.primary.opacity(0.1))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .disabled(value <= range.lowerBound)

                Text("\(value)")
                    .font(theme.fontHeadline)
                    .foregroundStyle(.primary)
                    .frame(minWidth: 32)
                    .monospacedDigit()

                Button {
                    if value + step <= range.upperBound {
                        withAnimation(.spring(response: 0.2)) { value += step }
                    }
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(value >= range.upperBound ? Color(.tertiaryLabel) : theme.primary)
                        .frame(width: 32, height: 32)
                        .background(theme.primary.opacity(0.1))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .disabled(value >= range.upperBound)
            }
        }
    }
}

// MARK: - SBSliderRow

/// A row with a slider for range input
public struct SBSliderRow: View {
    let title: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double
    let format: (Double) -> String

    @Environment(\.sbTheme) private var theme

    public init(
        title: String,
        value: Binding<Double>,
        range: ClosedRange<Double> = 0...100,
        step: Double = 1,
        format: @escaping (Double) -> String = { String(format: "%.0f", $0) }
    ) {
        self.title = title
        self._value = value
        self.range = range
        self.step = step
        self.format = format
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(title)
                    .font(theme.fontBody)
                    .foregroundStyle(.primary)
                Spacer()
                Text(format(value))
                    .font(theme.fontHeadline)
                    .foregroundStyle(theme.primary)
                    .monospacedDigit()
            }

            Slider(value: $value, in: range, step: step)
                .tint(theme.primary)
        }
    }
}

// MARK: - SBPickerRow

/// An inline picker row for selecting from options
public struct SBPickerRow<T: Hashable>: View {
    let title: String
    let options: [(label: String, value: T)]
    @Binding var selection: T

    @Environment(\.sbTheme) private var theme

    public init(
        title: String,
        options: [(label: String, value: T)],
        selection: Binding<T>
    ) {
        self.title = title
        self.options = options
        self._selection = selection
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(theme.fontBody)
                .foregroundStyle(.primary)

            HStack(spacing: 8) {
                ForEach(options.indices, id: \.self) { index in
                    let opt = options[index]
                    let isSelected = opt.value == selection

                    Button {
                        withAnimation(.spring(response: 0.25)) { selection = opt.value }
                    } label: {
                        Text(opt.label)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(isSelected ? .white : theme.primary)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background {
                                Capsule()
                                    .fill(isSelected ? theme.primary : theme.primary.opacity(0.1))
                            }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

// MARK: - SBRatingRow

/// A star rating row
public struct SBRatingRow: View {
    let title: String
    @Binding var rating: Int
    let maxRating: Int

    @Environment(\.sbTheme) private var theme

    public init(title: String, rating: Binding<Int>, maxRating: Int = 5) {
        self.title = title
        self._rating = rating
        self.maxRating = maxRating
    }

    public var body: some View {
        HStack {
            Text(title)
                .font(theme.fontBody)
                .foregroundStyle(.primary)

            Spacer()

            HStack(spacing: 4) {
                ForEach(1...maxRating, id: \.self) { star in
                    Image(systemName: star <= rating ? "star.fill" : "star")
                        .font(.system(size: 20))
                        .foregroundStyle(star <= rating ? Color.yellow : Color(.systemGray4))
                        .onTapGesture {
                            withAnimation(.spring(response: 0.2)) {
                                rating = star
                            }
                        }
                }
            }
        }
    }
}

// MARK: - SBFormDivider

/// A thin divider for separating form fields
public struct SBFormDivider: View {
    public init() {}

    public var body: some View {
        Divider()
            .padding(.leading, 16)
    }
}

// MARK: - SBCharacterCount

/// A text field with live character count
public struct SBCharacterCountField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    let limit: Int

    @Environment(\.sbTheme) private var theme
    @FocusState private var isFocused: Bool

    public init(
        _ title: String,
        placeholder: String = "",
        text: Binding<String>,
        limit: Int = 280
    ) {
        self.title = title
        self.placeholder = placeholder
        self._text = text
        self.limit = limit
    }

    private var remaining: Int { limit - text.count }
    private var isNearLimit: Bool { remaining <= 20 }
    private var isOverLimit: Bool { remaining < 0 }

    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(theme.fontCaption)
                .foregroundStyle(isFocused ? theme.primary : .secondary)

            ZStack(alignment: .bottomTrailing) {
                TextEditor(text: $text)
                    .font(theme.fontBody)
                    .focused($isFocused)
                    .frame(minHeight: 100)
                    .scrollContentBackground(.hidden)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: theme.radiusMD, style: .continuous)
                            .fill(theme.background)
                            .overlay(
                                RoundedRectangle(cornerRadius: theme.radiusMD, style: .continuous)
                                    .strokeBorder(
                                        isOverLimit ? theme.error :
                                        isFocused ? theme.primary :
                                        Color.primary.opacity(0.2),
                                        lineWidth: isFocused ? 2 : 1
                                    )
                            )
                    )

                // Character count badge
                Text("\(remaining)")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(isOverLimit ? theme.error : isNearLimit ? theme.warning : .secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(.systemBackground).opacity(0.9))
                    .padding(8)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isFocused)
    }
}
