//
//  HistoryItem.swift
//  ban_fake
//
//  Created by THANH BÌNH on 15/3/26.
//

import Foundation

struct HistoryItem: Identifiable {
    let id: UUID
    let title: String
    let code: String
    let amount: Int
    let date: Date
}
