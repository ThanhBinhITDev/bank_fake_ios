//
//  Transaction.swift
//  ban_fake
//
//  Created by THANH BÌNH on 15/3/26.
//

import Foundation

struct Transaction: Identifiable {
    let id: UUID
    let title: String
    let date: Date
    let amount: Int

    var isCredit: Bool {
        amount >= 0
    }
}
