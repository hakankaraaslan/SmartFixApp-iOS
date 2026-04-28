//
//  PriceEstimator.swift
//  SmartFixApp
//
//  Created by Ahmet Hakan Karaaslan on 28.04.2026.
//

import Foundation

struct PriceRange {
    let min: Int
    let max: Int
}

final class PriceEstimator {
    
    static func estimate(
        category: String,
        brand: String?,
        model: String?,
        description: String
    ) -> PriceRange {
        
        let lowerDesc = description.lowercased()
        
        // White Goods
        if category == "White Goods" {
            if lowerDesc.contains("cool") {
                return PriceRange(min: 1500, max: 3500)
            }
            return PriceRange(min: 1000, max: 3000)
        }
        
        // Electrical
        if category == "Electrical" {
            return PriceRange(min: 500, max: 1500)
        }
        
        // Plumbing
        if category == "Plumbing" {
            return PriceRange(min: 700, max: 2000)
        }
        
        // Brand-based tweak (simple simulation)
        if let brand = brand?.lowercased() {
            if brand.contains("samsung") {
                return PriceRange(min: 1200, max: 3200)
            }
            if brand.contains("bosch") {
                return PriceRange(min: 1500, max: 4000)
            }
        }
        
        // Default fallback
        return PriceRange(min: 800, max: 2500)
    }
}
