//
//  CartService.swift
//  iOS_Registry_System
//
//  Singleton service to manage the shopping cart state
//

import Foundation
import Combine
import SwiftUI

class CartService: ObservableObject {
    static let shared = CartService()
    
    @Published private(set) var items: [CartItem] = []
    
    private init() {}
    
    func addToCart(product: Product, registryItem: RegistryItem, eventName: String) {
        // For simplicity, we'll allow multiple entries of the same item if from different registries
        // but if it's the exact same registry item, we increment quantity
        if let index = items.firstIndex(where: { $0.registryItem?.id == registryItem.id }) {
            items[index].quantity += 1
        } else {
            let newItem = CartItem(
                userId: UUID(), // Dummy
                productId: product.id,
                product: product,
                registryItem: registryItem,
                eventName: eventName
            )
            items.append(newItem)
        }
    }
    
    func removeFromCart(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
    }
    
    func updateQuantity(for itemID: UUID, delta: Int) {
        if let index = items.firstIndex(where: { $0.id == itemID }) {
            let newQuantity = items[index].quantity + delta
            if newQuantity <= 0 {
                items.remove(at: index)
            } else {
                items[index].quantity = newQuantity
            }
        }
    }
    
    func clearCart() {
        items = []
    }
    
    var totalPrice: Double {
        items.reduce(0) { $0 + (($1.product?.price ?? 0.0) * Double($1.quantity)) }
    }
    
    var itemCount: Int {
        items.reduce(0) { $0 + $1.quantity }
    }
}
