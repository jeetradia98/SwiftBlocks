// SBCommerce.swift
// SwiftBlocks — Commerce & Product Components

import SwiftUI

// MARK: - SBProductCard

public struct SBProductCard: View {
    let name:          String
    let price:         String
    let originalPrice: String?
    let badge:         String?
    let icon:          String
    let rating:        Double?
    let isInCart:      Bool
    let onAdd:         () -> Void

    @Environment(\.sbTheme) private var theme

    public init(name: String, price: String, originalPrice: String? = nil, badge: String? = nil, icon: String = "bag.fill", rating: Double? = nil, isInCart: Bool = false, onAdd: @escaping () -> Void) {
        self.name = name; self.price = price; self.originalPrice = originalPrice; self.badge = badge
        self.icon = icon; self.rating = rating; self.isInCart = isInCart; self.onAdd = onAdd
    }

    public var body: some View {
        SBCard(style: .elevated, radius: 16, padding: 0) {
            VStack(alignment: .leading, spacing: 0) {
                ZStack(alignment: .topTrailing) {
                    RoundedRectangle(cornerRadius: 0)
                        .fill(LinearGradient(colors: [theme.primary.opacity(0.12), theme.secondary.opacity(0.08)], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .aspectRatio(4/3, contentMode: .fit)
                        .overlay { Image(systemName: icon).font(.system(size: 40, weight: .light)).foregroundStyle(theme.primary.opacity(0.4)) }
                    if let badge { SBBadge(badge, color: theme.error, style: .filled).padding(10) }
                }
                VStack(alignment: .leading, spacing: 8) {
                    Text(name).font(theme.fontBody).foregroundStyle(.primary).lineLimit(2)
                    if let r = rating {
                        HStack(spacing: 3) {
                            Image(systemName: "star.fill").font(.system(size: 11)).foregroundStyle(.yellow)
                            Text(String(format: "%.1f", r)).font(.system(size: 11, weight: .semibold)).foregroundStyle(.secondary)
                        }
                    }
                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text(price).font(theme.fontHeadline).foregroundStyle(theme.primary)
                        if let orig = originalPrice { Text(orig).font(theme.fontCaption).foregroundStyle(.secondary).strikethrough() }
                        Spacer()
                        Button(action: onAdd) {
                            Image(systemName: isInCart ? "checkmark" : "plus")
                                .font(.system(size: 14, weight: .bold)).foregroundStyle(.white)
                                .frame(width: 30, height: 30)
                                .background(isInCart ? theme.success : theme.primary).clipShape(Circle())
                        }
                        .buttonStyle(.plain).animation(.spring(response: 0.3), value: isInCart)
                    }
                }
                .padding(12)
            }
        }
    }
}

// MARK: - SBCartRow

public struct SBCartRow: View {
    let name:     String
    let price:    String
    let icon:     String
    @Binding var quantity: Int
    let onRemove: () -> Void

    @Environment(\.sbTheme) private var theme

    public init(name: String, price: String, icon: String = "bag.fill", quantity: Binding<Int>, onRemove: @escaping () -> Void) {
        self.name = name; self.price = price; self.icon = icon; self._quantity = quantity; self.onRemove = onRemove
    }

    public var body: some View {
        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(theme.primary.opacity(0.1)).frame(width: 60, height: 60)
                .overlay { Image(systemName: icon).font(.system(size: 24, weight: .light)).foregroundStyle(theme.primary.opacity(0.5)) }
            VStack(alignment: .leading, spacing: 4) {
                Text(name).font(theme.fontBody).foregroundStyle(.primary).lineLimit(2)
                Text(price).font(theme.fontHeadline).foregroundStyle(theme.primary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 8) {
                Button(action: onRemove) { Image(systemName: "trash").font(.system(size: 13)).foregroundStyle(.secondary) }.buttonStyle(.plain)
                HStack(spacing: 10) {
                    Button { if quantity > 1 { withAnimation { quantity -= 1 } } } label: {
                        Image(systemName: "minus").font(.system(size: 11, weight: .bold))
                            .foregroundStyle(quantity <= 1 ? Color(.tertiaryLabel) : theme.primary)
                            .frame(width: 26, height: 26).background(theme.surface).clipShape(Circle())
                    }.buttonStyle(.plain)
                    Text("\(quantity)").font(.system(size: 14, weight: .semibold)).monospacedDigit().frame(minWidth: 16)
                    Button { withAnimation { quantity += 1 } } label: {
                        Image(systemName: "plus").font(.system(size: 11, weight: .bold)).foregroundStyle(theme.primary)
                            .frame(width: 26, height: 26).background(theme.primary.opacity(0.1)).clipShape(Circle())
                    }.buttonStyle(.plain)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - SBOrderRow / SBOrderSummary

public struct SBOrderRow {
    public let label: String; public let value: String; public let isTotal: Bool
    public init(label: String, value: String, isTotal: Bool = false) {
        self.label = label; self.value = value; self.isTotal = isTotal
    }
}

public struct SBOrderSummary: View {
    let rows:      [SBOrderRow]
    let total:     String
    let ctaTitle:  String
    let onCheckout: () -> Void

    @Environment(\.sbTheme) private var theme

    public init(rows: [SBOrderRow], total: String, ctaTitle: String = "Place Order", onCheckout: @escaping () -> Void) {
        self.rows = rows; self.total = total; self.ctaTitle = ctaTitle; self.onCheckout = onCheckout
    }

    public var body: some View {
        SBCard(style: .elevated) {
            VStack(spacing: 12) {
                ForEach(rows.indices, id: \.self) { i in
                    HStack {
                        Text(rows[i].label).font(rows[i].isTotal ? theme.fontHeadline : theme.fontBody)
                            .foregroundStyle(rows[i].isTotal ? .primary : .secondary)
                        Spacer()
                        Text(rows[i].value).font(rows[i].isTotal ? theme.fontHeadline : theme.fontBody)
                            .foregroundStyle(rows[i].isTotal ? theme.primary : .primary)
                    }
                    if i < rows.count - 1 { Divider() }
                }
                SBButton(ctaTitle, style: .primary, isFullWidth: true, action: onCheckout).padding(.top, 4)
            }
        }
    }
}

// MARK: - SBPriceTag

public struct SBPriceTag: View {
    let price:         String
    let originalPrice: String?
    let discountBadge: String?
    let size:          SBPriceTagSize

    @Environment(\.sbTheme) private var theme
    public enum SBPriceTagSize { case small, medium, large }

    public init(price: String, originalPrice: String? = nil, discountBadge: String? = nil, size: SBPriceTagSize = .medium) {
        self.price = price; self.originalPrice = originalPrice; self.discountBadge = discountBadge; self.size = size
    }

    private var mainFont: Font {
        switch size {
        case .small:  .system(size: 16, weight: .bold)
        case .medium: .system(size: 22, weight: .bold)
        case .large:  .system(size: 30, weight: .bold, design: .rounded)
        }
    }

    public var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text(price).font(mainFont).foregroundStyle(theme.primary)
            if let orig = originalPrice { Text(orig).font(.system(size: 14)).foregroundStyle(.secondary).strikethrough(color: .secondary) }
            if let badge = discountBadge { SBBadge(badge, color: theme.error, style: .soft) }
        }
    }
}
