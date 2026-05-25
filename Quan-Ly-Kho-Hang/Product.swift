//
//  Product.swift
//  Quan-Ly-Kho-Hang
//
//  Created by  User on 23.05.2026.
//

import Foundation

struct Product: Codable {
    var id: String? // ID của document trên Firebase
    let brand: String
    let category: String
    let image: String
    let min_stock: Int
    let name: String
    let price: Int
    let product_code: String
    let quantity: Int
}
