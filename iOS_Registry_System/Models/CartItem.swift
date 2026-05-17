//
//  CartItem.swift
//  iOS_Registry_System
//
//  Model for an item in the shopping cart
//

import Foundation

struct CartItem: Identifiable, Codable {
    let id: UUID
    let product: Product
    let registryItem: RegistryItem
    let eventName: String
    var quantity: Int
    
    init(id: UUID = UUID(), product: Product, registryItem: RegistryItem, eventName: String, quantity: Int = 1) {
        self.id = id
        self.product = product
        self.registryItem = registryItem
        self.eventName = eventName
        self.quantity = quantity
    }
}
