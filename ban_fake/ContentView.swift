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
    @State private var isHistorySheetPresented = false
    @State private var isHistoryListPresented = false
    @State private var isFakeNotifyPresented = false

    var body: some View {
        ZStack {
            theme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                topBar
                ScrollView { content }
                Spacer()
                bottomButton
                    .padding(.bottom, 18)
            }
        }
        .overlay(alignment: .bottom) {
            if isHistorySheetPresented {
                historyOverlay
            }
        }
        .fullScreenCover(isPresented: $isHistoryListPresented) {
            historyListView
        }
        .fullScreenCover(isPresented: $isFakeNotifyPresented) {
            FakeNotificationSetupView(viewModel: viewModel, onClose: {
                isFakeNotifyPresented = false
            })
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
                cardAction(title: "Lịch sử GD", systemName: "clock") {
                    isHistorySheetPresented = true
                }
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

    private func cardAction(title: String, systemName: String, action: (() -> Void)? = nil) -> some View {
        Button {
            action?()
        } label: {
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
        .buttonStyle(.plain)
    }

    private var bottomButton: some View {
        Button {
            isFakeNotifyPresented = true
        } label: {
            HStack(spacing: 8) {
                ZStack {
                    Circle()
                        .stroke(theme.accent, lineWidth: 1.5)
                        .frame(width: 24, height: 24)
                    Image(systemName: "plus")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(theme.accent)
                }
                Text("Mở tài khoản")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(theme.primaryText)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .stroke(theme.accent, lineWidth: 1.5)
            )
        }
    }

    private var historyOverlay: some View {
        GeometryReader { proxy in
            ZStack(alignment: .bottom) {
                Color.black.opacity(0.35)
                    .ignoresSafeArea()
                    .onTapGesture {
                        isHistorySheetPresented = false
                    }

                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Lịch sử giao dịch")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(theme.primaryText)
                        Spacer()
                        Button {
                            isHistorySheetPresented = false
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(theme.primaryText)
                                .frame(width: 32, height: 32)
                                .background(Circle().fill(theme.promoChevronBackground))
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)

                    Button {
                        isHistorySheetPresented = false
                        isHistoryListPresented = true
                    } label: {
                        historySheetRow(title: "Toàn bộ giao dịch tại BIDV", subtitle: "Hiển thị toàn bộ giao dịch của Khách hàng tại BIDV")
                    }

                    Button {
                    } label: {
                        historySheetRow(title: "Giao dịch trên SmartBanking", subtitle: "Hiển thị lịch sử thực hiện giao dịch của Khách hàng trên ứng dụng SmartBanking")
                    }
                    .padding(.bottom, 12)
                }
                .padding(.top, 12)
                .padding(.bottom, 16)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(Color.white)
                )
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .padding(.bottom, -proxy.safeAreaInsets.bottom)
            }
        }
        .transition(.move(edge: .bottom))
        .animation(.easeInOut(duration: 0.2), value: isHistorySheetPresented)
    }

    private func historySheetRow(title: String, subtitle: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(theme.primaryText)
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundStyle(theme.subtleText)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(theme.subtleText)
                .padding(8)
                .background(Circle().fill(theme.promoChevronBackground))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 6)
    }

    private var historyListView: some View {
        HistoryListView(items: viewModel.historyItems, onClose: {
            isHistoryListPresented = false
        })
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

private enum HistoryTab: String, CaseIterable {
    case all = "Tất cả"
    case income = "Tiền vào"
    case expense = "Tiền ra"
}

private struct HistoryListView: View {
    let items: [HistoryItem]
    let onClose: () -> Void

    @State private var searchText = ""
    @State private var selectedTab: HistoryTab = .all

    private let theme = Theme()

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack(spacing: 0) {
                header
                searchBar
                tabs
                listContent
            }
        }
    }

    private var header: some View {
        HStack {
            Button {
                onClose()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(theme.primaryText)
            }

            Text("Toàn bộ GD tại BIDV")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(theme.primaryText)

            Spacer()

            HStack(spacing: 8) {
                Text("Bộ lọc")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(theme.accent)
                Rectangle()
                    .fill(theme.chipBorder)
                    .frame(width: 1, height: 16)
                Button {
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(theme.accent)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 8)
    }

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(theme.subtleText)
            TextField("Tìm kiếm", text: $searchText)
                .font(.system(size: 14))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .stroke(theme.chipBorder, lineWidth: 1)
        )
        .padding(.horizontal, 20)
    }

    private var tabs: some View {
        VStack(spacing: 6) {
            HStack {
                tabItem(.all)
                tabItem(.income)
                tabItem(.expense)
            }
            HStack {
                Rectangle()
                    .fill(theme.accent)
                    .frame(width: 84, height: 2)
                Spacer()
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
    }

    private func tabItem(_ tab: HistoryTab) -> some View {
        Button {
            selectedTab = tab
        } label: {
            Text(tab.rawValue)
                .font(.system(size: 14, weight: selectedTab == tab ? .semibold : .regular))
                .foregroundStyle(selectedTab == tab ? theme.primaryText : theme.subtleText)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }

    private var listContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(groupedKeys, id: \.self) { dateKey in
                    Text(dateKey)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(theme.primaryText)
                        .padding(.horizontal, 20)

                    VStack(spacing: 0) {
                        ForEach(groupedItems[dateKey] ?? []) { item in
                            HistoryRow(item: item, theme: theme)
                            if item.id != (groupedItems[dateKey] ?? []).last?.id {
                                Divider()
                                    .overlay(theme.chipBorder)
                                    .padding(.leading, 20)
                            }
                        }
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(red: 0.97, green: 0.97, blue: 0.97))
                    )
                    .padding(.horizontal, 20)
                }
            }
            .padding(.top, 16)
            .padding(.bottom, 24)
        }
    }

    private var filteredItems: [HistoryItem] {
        items.filter { item in
            let matchesSearch = searchText.isEmpty || item.title.lowercased().contains(searchText.lowercased()) || item.code.lowercased().contains(searchText.lowercased())
            let matchesTab: Bool
            switch selectedTab {
            case .all:
                matchesTab = true
            case .income:
                matchesTab = item.amount >= 0
            case .expense:
                matchesTab = item.amount < 0
            }
            return matchesSearch && matchesTab
        }
    }

    private var groupedItems: [String: [HistoryItem]] {
        Dictionary(grouping: filteredItems) { item in
            dateFormatter.string(from: item.date)
        }
    }

    private var groupedKeys: [String] {
        groupedItems.keys.sorted(by: { $0 > $1 })
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter
    }
}

private struct HistoryRow: View {
    let item: HistoryItem
    let theme: Theme

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text(item.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(theme.primaryText)
                    .lineLimit(1)
                Text(item.code)
                    .font(.system(size: 12))
                    .foregroundStyle(theme.subtleText)
                    .lineLimit(1)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 6) {
                Text(formattedAmount(item.amount))
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(item.amount >= 0 ? Color(red: 0.10, green: 0.55, blue: 0.22) : Color.red)
                Text(timeFormatter.string(from: item.date))
                    .font(.system(size: 12))
                    .foregroundStyle(theme.subtleText)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }

    private func formattedAmount(_ amount: Int) -> String {
        let sign = amount >= 0 ? "+" : "-"
        let value = abs(amount)
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let number = formatter.string(from: NSNumber(value: value)) ?? "0"
        return sign + number + " VND"
    }
}

private struct FakeNotificationSetupView: View {
    @ObservedObject var viewModel: AccountViewModel
    let onClose: () -> Void

    @State private var selectedBank = BankOption(name: "BIDV", shortName: "BIDV")
    @State private var selectedFlow: AccountViewModel.NotificationMode = .all
    @State private var amountText = "200000"
    @State private var count = 5
    @State private var intervalSeconds = 30
    @State private var statusText = "Chưa tạo thông báo"
    @State private var accountNumberText = ""

    private let theme = Theme()
    private let banks = [
        BankOption(name: "BIDV", shortName: "BIDV"),
        BankOption(name: "Vietcombank", shortName: "VCB"),
        BankOption(name: "Techcombank", shortName: "TCB"),
        BankOption(name: "MB Bank", shortName: "MB"),
        BankOption(name: "ACB", shortName: "ACB")
    ]

    init(viewModel: AccountViewModel, onClose: @escaping () -> Void) {
        self.viewModel = viewModel
        self.onClose = onClose
        _accountNumberText = State(initialValue: viewModel.accountNumber)
    }

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack(spacing: 0) {
                header
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        sectionTitle("Thiết lập thông báo giả")
                        bankPicker
                        accountNumberField
                        flowPicker
                        amountField
                        countPicker
                        intervalPicker
                        statusBlock
                        actionButtons
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 24)
                }
            }
        }
    }

    private var header: some View {
        HStack {
            Button {
                onClose()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(theme.primaryText)
            }

            Text("Tạo thông báo giả")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(theme.primaryText)

            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 8)
    }

    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 16, weight: .semibold))
            .foregroundStyle(theme.primaryText)
    }

    private var bankPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Ngân hàng")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(theme.subtleText)
            Picker("Ngân hàng", selection: $selectedBank) {
                ForEach(banks) { bank in
                    Text(bank.name).tag(bank)
                }
            }
            .pickerStyle(.menu)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(theme.chipBorder, lineWidth: 1)
            )
        }
    }

    private var flowPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Loại biến động")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(theme.subtleText)
            HStack(spacing: 8) {
                ForEach(NotificationModeOption.allCases, id: \.self) { option in
                    Button {
                        selectedFlow = option.mode
                    } label: {
                        Text(option.title)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(selectedFlow == option.mode ? Color.white : theme.primaryText)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(selectedFlow == option.mode ? theme.accent : Color.white)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(theme.chipBorder, lineWidth: 1)
                                    )
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var accountNumberField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Số tài khoản")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(theme.subtleText)
            TextField("Nhập số tài khoản", text: $accountNumberText)
                .keyboardType(.numberPad)
                .font(.system(size: 14))
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(theme.chipBorder, lineWidth: 1)
                )
        }
    }

    private var amountField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Số tiền mỗi thông báo")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(theme.subtleText)
            TextField("VND", text: $amountText)
                .keyboardType(.numberPad)
                .font(.system(size: 14))
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(theme.chipBorder, lineWidth: 1)
                )
        }
    }

    private var countPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Số lượng thông báo")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(theme.subtleText)
            Stepper(value: $count, in: 1...20) {
                Text("\(count) thông báo")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(theme.primaryText)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(theme.chipBorder, lineWidth: 1)
            )
        }
    }

    private var intervalPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Khoảng cách (giây)")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(theme.subtleText)
            Stepper(value: $intervalSeconds, in: 5...300, step: 5) {
                Text("\(intervalSeconds)s / thông báo")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(theme.primaryText)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(theme.chipBorder, lineWidth: 1)
            )
        }
    }

    private var statusBlock: some View {
        Text(statusText)
            .font(.system(size: 12))
            .foregroundStyle(theme.subtleText)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(red: 0.97, green: 0.97, blue: 0.97))
            )
    }

    private var actionButtons: some View {
        HStack(spacing: 12) {
            Button {
                let amount = parseAmount(amountText)
                viewModel.updateBankInfo(
                    bankName: selectedBank.name,
                    bankShortName: selectedBank.shortName,
                    accountNumber: accountNumberText.isEmpty ? viewModel.accountNumber : accountNumberText
                )
                Task {
                    let result = await viewModel.scheduleFakeNotifications(
                        mode: selectedFlow,
                        bankName: selectedBank.name,
                        bankShortName: selectedBank.shortName,
                        amount: amount,
                        count: count,
                        intervalSeconds: intervalSeconds
                    )
                    statusText = result
                }
            } label: {
                Text("Tạo thông báo")
                    .font(.system(size: 14, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .foregroundStyle(.white)
                    .background(RoundedRectangle(cornerRadius: 12).fill(theme.accent))
            }
            Button {
                viewModel.cancelFakeNotifications()
                statusText = "Đã hủy thông báo"
            } label: {
                Text("Hủy")
                    .font(.system(size: 14, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .foregroundStyle(theme.primaryText)
                    .background(RoundedRectangle(cornerRadius: 12).stroke(theme.chipBorder, lineWidth: 1))
            }
        }
    }

    private func parseAmount(_ text: String) -> Int {
        let digits = text.filter { $0.isNumber }
        return Int(digits) ?? 0
    }
}

private struct BankOption: Identifiable, Hashable {
    var id: String { shortName }
    let name: String
    let shortName: String
}

private enum NotificationModeOption: CaseIterable {
    case all
    case income
    case expense

    var title: String {
        switch self {
        case .all: return "Tất cả"
        case .income: return "Tiền vào"
        case .expense: return "Tiền ra"
        }
    }

    var mode: AccountViewModel.NotificationMode {
        switch self {
        case .all: return .all
        case .income: return .income
        case .expense: return .expense
        }
    }
}
