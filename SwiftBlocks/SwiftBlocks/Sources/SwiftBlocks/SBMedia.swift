// SBMedia.swift
// SwiftBlocks — Media Components

import SwiftUI

// MARK: - SBMediaPlaceholder

/// A placeholder for images/media while loading
public struct SBMediaPlaceholder: View {
    let aspectRatio: CGFloat
    let icon: String
    let label: String?
    let radius: CGFloat

    @Environment(\.sbTheme) private var theme

    public init(
        aspectRatio: CGFloat = 16/9,
        icon: String = "photo",
        label: String? = nil,
        radius: CGFloat = 12
    ) {
        self.aspectRatio = aspectRatio
        self.icon = icon
        self.label = label
        self.radius = radius
    }

    public var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .fill(theme.surface)

            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 28, weight: .light))
                    .foregroundStyle(theme.primary.opacity(0.4))
                if let label {
                    Text(label)
                        .font(theme.fontCaption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .aspectRatio(aspectRatio, contentMode: .fit)
    }
}

// MARK: - SBVideoThumbnail

/// A thumbnail card with play button overlay
public struct SBVideoThumbnail: View {
    let title: String?
    let duration: String?
    let icon: String
    let action: () -> Void

    @Environment(\.sbTheme) private var theme

    public init(
        title: String? = nil,
        duration: String? = nil,
        icon: String = "play.rectangle.fill",
        action: @escaping () -> Void
    ) {
        self.title = title
        self.duration = duration
        self.icon = icon
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            ZStack(alignment: .bottomLeading) {
                // Placeholder background
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [theme.primary.opacity(0.3), theme.secondary.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .aspectRatio(16/9, contentMode: .fit)

                // Play button
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(.white.opacity(0.9))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                // Bottom bar
                HStack {
                    if let title {
                        Text(title)
                            .font(theme.fontCaption)
                            .foregroundStyle(.white)
                            .lineLimit(1)
                    }
                    Spacer()
                    if let duration {
                        Text(duration)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Capsule())
                    }
                }
                .padding(10)
                .background(
                    LinearGradient(
                        colors: [.clear, .black.opacity(0.5)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                )
            }
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - SBFileRow

/// A list row for file attachments
public struct SBFileRow: View {
    let filename: String
    let fileSize: String?
    let fileType: SBFileType
    let action: (() -> Void)?

    @Environment(\.sbTheme) private var theme

    public init(
        filename: String,
        fileSize: String? = nil,
        fileType: SBFileType = .generic,
        action: (() -> Void)? = nil
    ) {
        self.filename = filename
        self.fileSize = fileSize
        self.fileType = fileType
        self.action = action
    }

    public var body: some View {
        Button {
            action?()
        } label: {
            HStack(spacing: 12) {
                // File icon
                Image(systemName: fileType.icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(fileType.color)
                    .frame(width: 44, height: 44)
                    .background(fileType.color.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                VStack(alignment: .leading, spacing: 2) {
                    Text(filename)
                        .font(theme.fontBody)
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                    if let fileSize {
                        Text(fileSize)
                            .font(theme.fontCaption)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                Image(systemName: "arrow.down.circle")
                    .font(.system(size: 20))
                    .foregroundStyle(theme.primary)
            }
            .padding(12)
            .background(theme.surface)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

public enum SBFileType {
    case pdf, image, video, audio, document, spreadsheet, archive, generic

    var icon: String {
        switch self {
        case .pdf:         return "doc.fill"
        case .image:       return "photo.fill"
        case .video:       return "video.fill"
        case .audio:       return "music.note"
        case .document:    return "doc.text.fill"
        case .spreadsheet: return "tablecells.fill"
        case .archive:     return "archivebox.fill"
        case .generic:     return "doc.fill"
        }
    }

    var color: Color {
        switch self {
        case .pdf:         return Color(red: 0.9, green: 0.2, blue: 0.2)
        case .image:       return Color(red: 0.3, green: 0.6, blue: 1.0)
        case .video:       return Color(red: 0.6, green: 0.2, blue: 0.9)
        case .audio:       return Color(red: 1.0, green: 0.5, blue: 0.1)
        case .document:    return Color(red: 0.2, green: 0.5, blue: 1.0)
        case .spreadsheet: return Color(red: 0.2, green: 0.7, blue: 0.3)
        case .archive:     return Color(red: 0.6, green: 0.5, blue: 0.4)
        case .generic:     return Color(.systemGray)
        }
    }
}

// MARK: - SBImageGrid

/// A responsive image placeholder grid (e.g. photo gallery)
public struct SBImageGrid: View {
    let count: Int
    let columns: Int
    let spacing: CGFloat

    @Environment(\.sbTheme) private var theme

    public init(count: Int, columns: Int = 3, spacing: CGFloat = 3) {
        self.count = count
        self.columns = columns
        self.spacing = spacing
    }

    public var body: some View {
        let cols = Array(repeating: GridItem(.flexible(), spacing: spacing), count: columns)
        LazyVGrid(columns: cols, spacing: spacing) {
            ForEach(0..<count, id: \.self) { _ in
                RoundedRectangle(cornerRadius: 6)
                    .fill(theme.surface)
                    .aspectRatio(1, contentMode: .fit)
                    .overlay {
                        Image(systemName: "photo")
                            .foregroundStyle(theme.primary.opacity(0.25))
                    }
            }
        }
    }
}
