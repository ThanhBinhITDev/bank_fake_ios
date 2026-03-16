//
//  ContentViewModel.swift
//  ban_fake
//
//  Created by THANH BÌNH on 15/3/26.
//

import Combine
import Foundation
import UserNotifications

@MainActor
final class ContentViewModel: ObservableObject {
    @Published var accountName: String
    @Published var balance: Int
    @Published var transactions: [Transaction]

    @Published var banks: [Bank]
    @Published var selectedBank: Bank
    @Published var notificationPresets: [NotificationPreset]
    @Published var selectedPreset: NotificationPreset
    @Published var isNotificationsActive: Bool
    @Published var notificationStatus: String

    private var scheduledNotificationIds: [String]
    private let accountSuffix: String

    init() {
        accountName = "THANH BINH"
        balance = 185_420_000
        transactions = [
            Transaction(id: UUID(), title: "Salary", date: Date().addingTimeInterval(-3600 * 24 * 2), amount: 25_000_000),
            Transaction(id: UUID(), title: "Coffee", date: Date().addingTimeInterval(-3600 * 5), amount: -55_000),
            Transaction(id: UUID(), title: "Shopping", date: Date().addingTimeInterval(-3600 * 24), amount: -1_250_000),
            Transaction(id: UUID(), title: "Transfer", date: Date().addingTimeInterval(-3600 * 36), amount: 3_000_000)
        ]

        let banksSeed = [
            Bank(id: UUID(), name: "Vietcombank", shortName: "VCB"),
            Bank(id: UUID(), name: "Techcombank", shortName: "TCB"),
            Bank(id: UUID(), name: "MB Bank", shortName: "MB"),
            Bank(id: UUID(), name: "BIDV", shortName: "BIDV"),
            Bank(id: UUID(), name: "ACB", shortName: "ACB")
        ]

        let presetsSeed = [
            NotificationPreset(id: UUID(), title: "Moi 30 giay", intervalSeconds: 30),
            NotificationPreset(id: UUID(), title: "Moi 1 phut", intervalSeconds: 60),
            NotificationPreset(id: UUID(), title: "Moi 3 phut", intervalSeconds: 180)
        ]

        banks = banksSeed
        selectedBank = banksSeed[0]
        notificationPresets = presetsSeed
        selectedPreset = presetsSeed[0]
        isNotificationsActive = false
        notificationStatus = "Chua bat thong bao"
        scheduledNotificationIds = []
        accountSuffix = "1234"
    }

    var formattedBalance: String {
        formatCurrency(balance)
    }

    func formattedAmount(_ amount: Int) -> String {
        let sign = amount >= 0 ? "+" : "-"
        return sign + formatCurrency(abs(amount))
    }

    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    func startFakeNotifications() {
        Task {
            let center = UNUserNotificationCenter.current()
            let settings = await center.notificationSettings()

            if settings.authorizationStatus == .notDetermined {
                let granted = (try? await center.requestAuthorization(options: [.alert, .sound, .badge])) ?? false
                if !granted {
                    notificationStatus = "Chua duoc cap quyen thong bao"
                    isNotificationsActive = false
                    return
                }
            } else if settings.authorizationStatus == .denied {
                notificationStatus = "Thong bao bi tat trong Settings"
                isNotificationsActive = false
                return
            }

            scheduleFakeNotifications(count: 12)
            isNotificationsActive = true
            notificationStatus = "Da dat lich thong bao gia"
        }
    }

    func stopFakeNotifications() {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: scheduledNotificationIds)
        center.removeDeliveredNotifications(withIdentifiers: scheduledNotificationIds)
        scheduledNotificationIds.removeAll()
        isNotificationsActive = false
        notificationStatus = "Da dung thong bao"
    }

    private func scheduleFakeNotifications(count: Int) {
        let center = UNUserNotificationCenter.current()
        scheduledNotificationIds.removeAll()

        for index in 1...count {
            let delta = randomDelta()
            let content = UNMutableNotificationContent()
            content.title = "Thông báo \(selectedBank.shortName)"
            content.body = notificationBody(delta: delta)
            content.sound = .default
            content.interruptionLevel = .active
            content.threadIdentifier = selectedBank.shortName

            let delay: TimeInterval
            if index == 1 {
                delay = 1
            } else {
                delay = TimeInterval((index - 1) * selectedPreset.intervalSeconds)
            }

            let trigger = UNTimeIntervalNotificationTrigger(
                timeInterval: delay,
                repeats: false
            )

            let id = "fakebank.\(UUID().uuidString)"
            scheduledNotificationIds.append(id)
            let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
            center.add(request)
        }
    }

    private func notificationBody(delta: Int) -> String {
        let formattedAmount = formatCurrency(abs(delta))
        let sign = delta >= 0 ? "+" : "-"
        
        let contents = [
            "TKThe :201801052006, tai MB. LE THANH BINH chuyen tien",
            "TKThe :1038852587, tai Vietcombank. NGUYEN VAN A chuyen tien",
            "TB-MxKy han 001/TG/26. So tien 15000000",
            "Thanh toan QR tai cua hang tiện lợi",
            "Nap tien qua ATM",
            "Chuyen khoan nhanh 247",
            "Thanh toan hoa don dien nuoc",
            "Mua sam trực tuyến"
        ]
        let content = contents.randomElement() ?? contents[0]
        
        return """
        Tài khoản thanh toán: ****\(accountSuffix)
        Số tiền GD: \(sign)\(formattedAmount) VND
        Số dư cuối: \(formattedBalance) VND
        Nội dung giao dịch: \(content)
        """
    }

    private func randomDelta() -> Int {
        let candidates = [
            50_000,
            120_000,
            350_000,
            1_200_000,
            2_500_000,
            5_000_000
        ]
        let sign = Bool.random() ? 1 : -1
        return sign * (candidates.randomElement() ?? 50_000)
    }

    private func formatCurrency(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "VND"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "VND 0"
    }
}
