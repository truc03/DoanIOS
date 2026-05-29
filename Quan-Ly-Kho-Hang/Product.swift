//
//  Product.swift
//  Quan-Ly-Kho-Hang
//
//  Created by Antigravity on 26.05.2026.
//

import Foundation

struct Product: Identifiable, Codable {
    var id: String?
    var name: String
    var quantity: Int

    init(id: String? = nil, name: String, quantity: Int) {
        self.id = id
        self.name = name
        self.quantity = quantity
    }
}
