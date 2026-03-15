//
//  Bank.swift
//  ban_fake
//
//  Created by THANH BÌNH on 15/3/26.
//

import Foundation

struct Bank: Identifiable, Equatable, Hashable {
    let id: UUID
    let name: String
    let shortName: String
}
