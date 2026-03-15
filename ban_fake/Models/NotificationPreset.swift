//
//  NotificationPreset.swift
//  ban_fake
//
//  Created by THANH BÌNH on 15/3/26.
//

import Foundation

struct NotificationPreset: Identifiable, Equatable, Hashable {
    let id: UUID
    let title: String
    let intervalSeconds: Int
}
