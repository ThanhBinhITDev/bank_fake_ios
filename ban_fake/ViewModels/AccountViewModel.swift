//
//  AccountViewModel.swift
//  ban_fake
//
//  Created by THANH BÌNH on 15/3/26.
//

import Combine
import Foundation
import UserNotifications

@MainActor
final class AccountViewModel: ObservableObject {
    enum NotificationMode {
        case all
        case income
        case expense
    }

    @Published var accountNumber: String
    @Published var balance: Int
    @Published var transactions: [Transaction]
    @Published var historyItems: [HistoryItem]

    private var bankName: String
    private var bankShortName: String
    private var accountSuffix: String
    private var scheduledNotificationIds: [String]

    init() {
        accountNumber = "8866476102"
        balance = 1_695
        transactions = []
        historyItems = []
        bankName = "BIDV"
        bankShortName = "BIDV"
        accountSuffix = "6102"
        scheduledNotificationIds = []

        seedHistory()
    }

    var formattedBalance: String {
        formatCurrency(balance) + " VND"
    }

    func simulateBalanceChange() {
        let delta = randomDelta()
        balance += delta
        let title = delta >= 0 ? "Nhận tiền" : "Chi tiêu"
        let newTransaction = Transaction(id: UUID(), title: title, date: Date(), amount: delta)
        transactions.insert(newTransaction, at: 0)
        scheduleNotification(delta: delta)
    }

    private func scheduleNotification(delta: Int) {
        Task {
            let center = UNUserNotificationCenter.current()
            let settings = await center.notificationSettings()

            if settings.authorizationStatus == .notDetermined {
                let granted = (try? await center.requestAuthorization(options: [.alert, .sound, .badge])) ?? false
                if !granted {
                    return
                }
            } else if settings.authorizationStatus == .denied {
                return
            }

            let content = UNMutableNotificationContent()
            content.title = "\(bankShortName) • Biến động số dư"
            content.body = notificationBody(delta: delta)
            content.sound = .default

            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            try? await center.add(request)
        }
    }

    func scheduleFakeNotifications(
        mode: NotificationMode,
        bankName: String,
        bankShortName: String,
        amount: Int,
        count: Int,
        intervalSeconds: Int
    ) async -> String {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()

        if settings.authorizationStatus == .notDetermined {
            let granted = (try? await center.requestAuthorization(options: [.alert, .sound, .badge])) ?? false
            if !granted {
                return "Chưa được cấp quyền thông báo"
            }
        } else if settings.authorizationStatus == .denied {
            return "Thông báo đang bị tắt trong Settings"
        }

        cancelFakeNotifications()

        let safeCount = max(1, min(20, count))
        let safeInterval = max(5, min(300, intervalSeconds))
        let baseAmount = max(1, amount)

        for index in 1...safeCount {
            let delta = signedAmount(baseAmount, mode: mode)
            let content = UNMutableNotificationContent()
            content.title = "\(bankShortName) • Biến động số dư"
            content.body = notificationBody(delta: delta, bankName: bankName)
            content.sound = .default

            let trigger = UNTimeIntervalNotificationTrigger(
                timeInterval: TimeInterval(index * safeInterval),
                repeats: false
            )

            let id = UUID().uuidString
            scheduledNotificationIds.append(id)
            let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
            try? await center.add(request)
        }

        return "Đã tạo \(safeCount) thông báo giả cho \(bankShortName)"
    }

    func cancelFakeNotifications() {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: scheduledNotificationIds)
        center.removeDeliveredNotifications(withIdentifiers: scheduledNotificationIds)
        scheduledNotificationIds.removeAll()
    }

    private func notificationBody(delta: Int, bankName: String? = nil) -> String {
        let amount = formatCurrency(abs(delta))
        let action = delta >= 0 ? "cộng" : "trừ"
        let name = bankName ?? self.bankName
        return "\(name): TK ****\(accountSuffix) vừa \(action) \(amount)."
    }

    private func signedAmount(_ amount: Int, mode: NotificationMode) -> Int {
        switch mode {
        case .income:
            return amount
        case .expense:
            return -amount
        case .all:
            return Bool.random() ? amount : -amount
        }
    }

    func updateBankInfo(bankName: String, bankShortName: String, accountNumber: String) {
        self.bankName = bankName
        self.bankShortName = bankShortName
        self.accountNumber = accountNumber
        self.accountSuffix = String(accountNumber.suffix(4))
    }

    private func randomDelta() -> Int {
        let candidates = [
            5_000,
            15_000,
            50_000,
            120_000,
            350_000,
            1_200_000
        ]
        let sign = Bool.random() ? 1 : -1
        return sign * (candidates.randomElement() ?? 5_000)
    }

    private func formatCurrency(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "VND"
        formatter.currencySymbol = ""
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "0"
    }

    private func seedHistory() {
        let calendar = Calendar.current
        let now = Date()
        let day1 = calendar.date(byAdding: .day, value: -1, to: now) ?? now
        let day2 = calendar.date(byAdding: .day, value: -2, to: now) ?? now

        historyItems = [
            HistoryItem(id: UUID(), title: "7530580245 LE THANH B...", code: "Mã GD: 0392gMfW-87WDw...", amount: -1_200_000, date: makeTime(day1, hour: 11, minute: 15, second: 28)),
            HistoryItem(id: UUID(), title: "MB-TKThe MS0OP0000...", code: "Mã GD: 0832S4C2-87W5IG...", amount: -30_000, date: makeTime(day1, hour: 9, minute: 10, second: 33)),
            HistoryItem(id: UUID(), title: "MB-TKThe MS0OP0000...", code: "Mã GD: 0831HTGS-87W53x...", amount: -16_000, date: makeTime(day1, hour: 8, minute: 59, second: 53)),
            HistoryItem(id: UUID(), title: "TKThe: 0328544171, tai M...", code: "Mã GD: 8683BRJ2-87V7kcH...", amount: 200_000, date: makeTime(day2, hour: 17, minute: 54, second: 15)),
            HistoryItem(id: UUID(), title: "MB-TKThe MS0OP0000...", code: "Mã GD: 0832gMqk-87V4fb...", amount: -17_000, date: makeTime(day2, hour: 17, minute: 7, second: 13)),
            HistoryItem(id: UUID(), title: "SMB-TkThe: 1038852587...", code: "Mã GD: 8682wrou-87V4TJ9...", amount: -30_000, date: makeTime(day2, hour: 17, minute: 4, second: 11)),
            HistoryItem(id: UUID(), title: "Card Yearly Fee-517453*...", code: "Mã GD: 08725W7i-87UqNld...", amount: -220_000, date: makeTime(day2, hour: 13, minute: 28, second: 53)),
            HistoryItem(id: UUID(), title: "REM Tfr Ac: 8866476102...", code: "Mã GD: 0552S4C2-87UoQ...", amount: -10_000, date: makeTime(day2, hour: 12, minute: 59, second: 18))
        ]
    }

    private func makeTime(_ base: Date, hour: Int, minute: Int, second: Int) -> Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: base)
        components.hour = hour
        components.minute = minute
        components.second = second
        return calendar.date(from: components) ?? base
    }
}
