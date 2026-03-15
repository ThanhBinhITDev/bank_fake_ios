//
//  ContentView.swift
//  ban_fake
//
//  Created by THANH BÌNH on 15/3/26.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = AccountViewModel()
    private let theme = Theme()

    var body: some View {
        ZStack {
            theme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                topBar
                ScrollView {
                    content
                    transactionsSection
                }
                Spacer()
                bottomButton
                    .padding(.bottom, 18)
            }
        }
    }

    private var topBar: some View {
        HStack {
            Button {
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(theme.primaryText)
            }

            Spacer()

            Button {
                viewModel.simulateBalanceChange()
            } label: {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(theme.primaryText)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 4)
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tài khoản")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(theme.primaryText)
                .padding(.horizontal, 20)

            tabs
                .padding(.horizontal, 16)

            chips
                .padding(.horizontal, 20)

            promoCard
                .padding(.horizontal, 20)

            accountCard
                .padding(.horizontal, 20)
        }
        .padding(.top, 4)
    }

    private var tabs: some View {
        VStack(spacing: 4) {
            HStack {
                tabItem(title: "Thanh toán", isSelected: true)
                tabItem(title: "Tiết kiệm", isSelected: false)
                tabItem(title: "Tiền vay", isSelected: false)
            }
            HStack {
                Rectangle()
                    .fill(theme.accent)
                    .frame(width: 88, height: 2)
                Spacer()
            }
        }
    }

    private func tabItem(title: String, isSelected: Bool) -> some View {
        Text(title)
            .font(.system(size: 14, weight: isSelected ? .semibold : .regular))
            .foregroundStyle(isSelected ? theme.primaryText : theme.subtleText)
            .frame(maxWidth: .infinity)
    }

    private var chips: some View {
        HStack(spacing: 8) {
            chip(title: "Việt Nam Đồng", isSelected: true, badge: "1")
            chip(title: "Chọn tên như ý", isSelected: false, badge: nil)
            chip(title: "Hội nhóm", isSelected: false, badge: nil)
        }
    }

    private func chip(title: String, isSelected: Bool, badge: String?) -> some View {
        HStack(spacing: 6) {
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(isSelected ? theme.primaryText : theme.subtleText)
                .lineLimit(1)
                .minimumScaleFactor(0.85)
            if let badge {
                Text(badge)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(theme.badgeText)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        Capsule()
                            .fill(theme.badgeBackground)
                    )
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(theme.chipBackground)
        )
        .overlay(
            Capsule()
                .stroke(isSelected ? theme.accent : theme.chipBorder, lineWidth: 1)
        )
    }

    private var promoCard: some View {
        HStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(theme.promoIconBackground)
                    .frame(width: 44, height: 44)
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(theme.accent)
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text("Tài khoản Đầu tư\ntự động")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(theme.primaryText)
                    Text("Mới")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(theme.newBadge)
                        )
                        .offset(y: -6)
                }
                Text("Tự động mỗi ngày - Chốt lãi\nhàng tháng")
                    .font(.system(size: 11))
                    .foregroundStyle(theme.subtleText)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(theme.subtleText)
                .padding(8)
                .background(
                    Circle().fill(theme.promoChevronBackground)
                )
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(theme.cardBackground)
        )
    }

    private var accountCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(viewModel.accountNumber)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(theme.cardPrimaryText)
                    Text(viewModel.formattedBalance)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(theme.cardPrimaryText)
                }

                Spacer()

                HStack(spacing: 10) {
                    actionIcon(systemName: "star.fill")
                    actionIcon(systemName: "square.on.square")
                }
            }

            Divider()
                .overlay(theme.cardDivider)

            HStack {
                cardAction(title: "My QR", systemName: "qrcode")
                Spacer()
                cardAction(title: "Lịch sử GD", systemName: "clock")
                Spacer()
                cardAction(title: "Chi tiết", systemName: "doc.plaintext")
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 16)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(theme.accountCard)
        )
    }

    private var transactionsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Giao dịch gần đây")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(theme.primaryText)
                .padding(.horizontal, 20)

            if viewModel.transactions.isEmpty {
                Text("Chưa có giao dịch. Bấm nút làm mới để tạo giao dịch giả.")
                    .font(.system(size: 12))
                    .foregroundStyle(theme.subtleText)
                    .padding(.horizontal, 20)
            } else {
                ForEach(viewModel.transactions.prefix(6)) { transaction in
                    transactionRow(transaction)
                        .padding(.horizontal, 20)
                }
            }
        }
        .padding(.top, 14)
    }

    private func transactionRow(_ transaction: Transaction) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(theme.cardBackground)
                    .frame(width: 36, height: 36)
                Image(systemName: transaction.amount >= 0 ? "arrow.down.left" : "arrow.up.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(transaction.amount >= 0 ? theme.accent : Color.red)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(theme.primaryText)
                Text(formattedDate(transaction.date))
                    .font(.system(size: 11))
                    .foregroundStyle(theme.subtleText)
            }

            Spacer()

            Text(formattedAmount(transaction.amount))
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(transaction.amount >= 0 ? theme.accent : Color.red)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(theme.cardBackground)
        )
    }

    private func formattedAmount(_ amount: Int) -> String {
        let sign = amount >= 0 ? "+" : "-"
        let value = abs(amount)
        return sign + formatCurrency(value)
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private func formatCurrency(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "VND"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "VND 0"
    }

    private func actionIcon(systemName: String) -> some View {
        ZStack {
            Circle()
                .stroke(theme.cardIconBorder, lineWidth: 1)
                .frame(width: 32, height: 32)
            Image(systemName: systemName)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(theme.cardPrimaryText)
        }
    }

    private func cardAction(title: String, systemName: String) -> some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .stroke(theme.cardIconBorder, lineWidth: 1)
                    .frame(width: 34, height: 34)
                Image(systemName: systemName)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(theme.cardPrimaryText)
            }
            Text(title)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(theme.cardPrimaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(width: 72)
    }

    private var bottomButton: some View {
        Button {
        } label: {
            HStack(spacing: 8) {
                ZStack {
                    Circle()
                        .stroke(theme.accent, lineWidth: 1.5)
                        .frame(width: 28, height: 28)
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(theme.accent)
                }
                Text("Mở tài khoản")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(theme.primaryText)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 7)
            .background(
                Capsule()
                    .stroke(theme.accent, lineWidth: 1.5)
            )
        }
    }
}

#Preview {
    ContentView()
}

private struct Theme {
    let background = Color(red: 0.93, green: 0.96, blue: 0.95)
    let primaryText = Color(red: 0.12, green: 0.18, blue: 0.16)
    let subtleText = Color(red: 0.45, green: 0.52, blue: 0.50)
    let accent = Color(red: 0.18, green: 0.43, blue: 0.36)

    let chipBackground = Color.white
    let chipBorder = Color(red: 0.83, green: 0.87, blue: 0.86)
    let badgeBackground = Color(red: 0.16, green: 0.37, blue: 0.32)
    let badgeText = Color.white

    let cardBackground = Color.white
    let promoIconBackground = Color(red: 0.90, green: 0.95, blue: 0.94)
    let promoChevronBackground = Color(red: 0.90, green: 0.93, blue: 0.92)
    let newBadge = Color(red: 0.78, green: 0.25, blue: 0.16)

    let accountCard = Color(red: 0.14, green: 0.33, blue: 0.30)
    let cardPrimaryText = Color(red: 0.92, green: 0.96, blue: 0.94)
    let cardDivider = Color(red: 0.45, green: 0.60, blue: 0.56)
    let cardIconBorder = Color(red: 0.40, green: 0.58, blue: 0.54)
}
