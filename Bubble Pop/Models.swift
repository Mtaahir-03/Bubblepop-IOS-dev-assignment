//
//  Models.swift
//  Bubble Pop
//
//  Created by Muhammad Talal Nasir on 22/4/2025.
//
import Foundation
import SwiftUI

// Bubble model that contains all properties of a bubble
struct Bubble: Identifiable {
    let id = UUID()
    var position: CGPoint
    var color: BubbleColor
    var size: CGFloat
    
    // Computed property to get the bubble's color value
    var bubbleColor: Color {
        switch color {
        case .red:
            return Color.red
        case .pink:
            return Color.pink
        case .green:
            return Color.green
        case .blue:
            return Color.blue
        case .black:
            return Color.black
        }
    }
    
    // Computed property to get the bubble's point value
    var points: Int {
        return color.points
    }
}

// Enum to define bubble colors with their properties
enum BubbleColor: CaseIterable {
    case red, pink, green, blue, black
    
    // Points for each color
    var points: Int {
        switch self {
        case .red:
            return 1
        case .pink:
            return 2
        case .green:
            return 5
        case .blue:
            return 8
        case .black:
            return 10
        }
    }
    
    // Probability of appearance for each color
    static func randomColor() -> BubbleColor {
        let random = Double.random(in: 0...1)
        
        if random < 0.4 {
            return .red
        } else if random < 0.7 {
            return .pink
        } else if random < 0.85 {
            return .green
        } else if random < 0.95 {
            return .blue
        } else {
            return .black
        }
    }
}

// Player model to store player info and score
struct Player: Identifiable, Codable {
    var id = UUID()
    var name: String
    var score: Int
}

// Game settings model
struct GameSettings: Codable {
    var gameDuration: Int = 60
    var maxBubbles: Int = 15
}
