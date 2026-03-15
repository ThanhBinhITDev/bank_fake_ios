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
        balance = 42_823_700
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
        let baseAmounts = [200, 210, 220, 230, 240, 250, 260, 270, 280, 290, 300, 310, 320, 330, 340, 350, 360, 370, 380, 390, 400, 410, 420, 430, 440, 450, 460, 470, 480, 490, 500, 550, 600, 650, 700, 750, 800, 820, 900, 1000]
        
        var accumulatedDelta = 0

        for index in 1...safeCount {
            let baseAmount = baseAmounts.randomElement()! * 1000
            let delta = signedAmount(baseAmount, mode: mode)
            accumulatedDelta += delta
            
            let content = UNMutableNotificationContent()
            content.title = "Thông báo \(bankShortName)"
            content.body = notificationBody(delta: delta, bankName: bankName, accumulatedDelta: accumulatedDelta)
            content.sound = .default
            content.interruptionLevel = .active
            content.threadIdentifier = bankShortName

            let delay: TimeInterval
            if index == 1 {
                delay = 1
            } else {
                delay = TimeInterval((index - 1) * safeInterval)
            }
            
            let trigger = UNTimeIntervalNotificationTrigger(
                timeInterval: delay,
                repeats: false
            )

            let id = UUID().uuidString
            scheduledNotificationIds.append(id)
            
            if let attachmentURL = Bundle.main.url(forResource: "notification_icon", withExtension: "png") {
                if let attachment = try? UNNotificationAttachment(identifier: "icon", url: attachmentURL, options: nil) {
                    content.attachments = [attachment]
                }
            }
            
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

    private func notificationBody(delta: Int, bankName: String? = nil, accumulatedDelta: Int = 0) -> String {
        func randomId() -> String {
            let chars = "abcdefghijklmnopqrstuvwxyz0123456789"
            return String((0..<6).map { _ in chars.randomElement()! })
        }
        
        let formattedAmount = formatCurrency(abs(delta))
        let sign = delta >= 0 ? "+" : "-"
        let newBalance = balance + accumulatedDelta
        let formattedBalance = formatCurrency(newBalance)
        let id = randomId()
        
        return """
        Tài khoản thanh toán: \(accountNumber)
        Số tiền GD: \(sign)\(formattedAmount) VND
        Số dư cuối: \(formattedBalance) VND
        Nội dung giao dịch: thanhtoan \(id)
        """
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
        
        func randomId() -> String {
            let chars = "abcdefghijklmnopqrstuvwxyz0123456789"
            return String((0..<6).map { _ in chars.randomElement()! })
        }
        
        var items: [HistoryItem] = []
        
        // Ngày hôm nay - nhiều giao dịch
        for _ in 0..<40 {
            let hour = Int.random(in: 7...22)
            let minute = Int.random(in: 0...59)
            let second = Int.random(in: 0...59)
            let fullDate = makeTime(now, hour: hour, minute: minute, second: second)
            
            let baseAmounts = [200, 210, 220, 230, 240, 250, 260, 270, 280, 290, 300, 310, 320, 330, 340, 350, 360, 370, 380, 390, 400, 410, 420, 430, 440, 450, 460, 470, 480, 490, 500, 550, 600, 650, 700, 750, 800, 820]
            let amount = baseAmounts.randomElement()! * 1000
            let id = randomId()
            
            items.append(HistoryItem(
                id: UUID(),
                title: "thanhtoan \(id)",
                code: "Ma GD: \(UUID().uuidString.prefix(12))...",
                amount: amount,
                date: fullDate
            ))
        }
        
        // Ngày hôm qua
        for _ in 0..<8 {
            let daysAgo = 1
            let hour = Int.random(in: 8...20)
            let minute = Int.random(in: 0...59)
            let second = Int.random(in: 0...59)
            let date = calendar.date(byAdding: .day, value: -daysAgo, to: now) ?? now
            let fullDate = makeTime(date, hour: hour, minute: minute, second: second)
            
            let baseAmounts = [200, 210, 220, 230, 240, 250, 260, 270, 280, 290, 300, 310, 320, 330, 340, 350, 360, 370, 380, 390, 400, 410, 420, 430, 440, 450, 460, 470, 480, 490, 500, 550, 600, 650, 700, 750, 800, 820]
            let amount = baseAmounts.randomElement()! * 1000
            let id = randomId()
            
            items.append(HistoryItem(
                id: UUID(),
                title: "thanhtoan \(id)",
                code: "Ma GD: \(UUID().uuidString.prefix(12))...",
                amount: amount,
                date: fullDate
            ))
        }
        
        // Các ngày trước
        for _ in 0..<5 {
            let daysAgo = Int.random(in: 2...7)
            let hour = Int.random(in: 8...20)
            let minute = Int.random(in: 0...59)
            let second = Int.random(in: 0...59)
            let date = calendar.date(byAdding: .day, value: -daysAgo, to: now) ?? now
            let fullDate = makeTime(date, hour: hour, minute: minute, second: second)
            
            let baseAmounts = [200, 210, 220, 230, 240, 250, 260, 270, 280, 290, 300, 310, 320, 330, 340, 350, 360, 370, 380, 390, 400, 410, 420, 430, 440, 450, 460, 470, 480, 490, 500, 550, 600, 650, 700, 750, 800, 820]
            let amount = baseAmounts.randomElement()! * 1000
            let id = randomId()
            
            items.append(HistoryItem(
                id: UUID(),
                title: "thanhtoan \(id)",
                code: "Ma GD: \(UUID().uuidString.prefix(12))...",
                amount: amount,
                date: fullDate
            ))
        }
        
        historyItems = items.sorted { $0.date > $1.date }
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
