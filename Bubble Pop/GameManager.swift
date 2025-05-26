//
//  GameManager.swift
//  Bubble Pop
//
//
import Foundation
import SwiftUI
import Combine

class GameManager: ObservableObject {
    // Published properties to update the UI
    @Published var bubbles: [Bubble] = []
    @Published var score: Int = 0
    @Published var timeRemaining: Int = 60
    @Published var gameActive: Bool = false
    @Published var playerName: String = ""
    @Published var lastPoppedColor: BubbleColor?
    @Published var comboMultiplier: Int = 0
    
    // Game settings
    @Published var settings: GameSettings = GameSettings()
    
    // Timer for game countdown
    private var gameTimer: Timer?
    private var screenSize: CGSize = .zero
    
    // Game state
    var isGameOver: Bool {
        return timeRemaining <= 0 && gameActive
    }
    
    // High scores
    @Published var highScores: [Player] = []
    
    init() {
        loadSettings()
        loadHighScores()
    }
    
    // Set screen size for bubble positioning
    func setScreenSize(_ size: CGSize) {
        screenSize = size
    }
    
    // Start a new game
    func startGame() {
        guard !playerName.isEmpty else { return }
        
        // Reset game state
        timeRemaining = settings.gameDuration
        score = 0
        bubbles = []
        gameActive = true
        lastPoppedColor = nil
        comboMultiplier = 0
        
        // Start the game timer
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
                self.refreshBubbles()
            } else {
                self.endGame()
            }
        }
        
        // Initial bubble generation
        refreshBubbles()
    }
    
    // End the current game
    func endGame() {
        gameActive = false
        gameTimer?.invalidate()
        gameTimer = nil
        
        // Add player to high scores
        let player = Player(name: playerName, score: score)
        updateHighScores(with: player)
    }
    
    // Generate new bubbles
    func refreshBubbles() {
        // Remove some random existing bubbles
        let removeCount = Int.random(in: 0...bubbles.count/2)
        if removeCount > 0 && !bubbles.isEmpty {
            bubbles.removeSubrange(0..<min(removeCount, bubbles.count))
        }
        
        // Calculate how many new bubbles to add
        let bubbleSize: CGFloat = 80.0
        let currentCount = bubbles.count
        let targetCount = Int.random(in: currentCount...(settings.maxBubbles))
        let addCount = max(0, targetCount - currentCount)
        
        // Add new bubbles at non-overlapping positions
        for _ in 0..<addCount {
            if let position = findNonOverlappingPosition(bubbleSize: bubbleSize) {
                let bubble = Bubble(
                    position: position,
                    color: BubbleColor.randomColor(),
                    size: bubbleSize
                )
                bubbles.append(bubble)
            }
        }
    }
    
    // Find a non-overlapping position for a new bubble
    private func findNonOverlappingPosition(bubbleSize: CGFloat) -> CGPoint? {
        guard screenSize.width > 0, screenSize.height > 0 else { return nil }
        
        let margin: CGFloat = bubbleSize / 2
        let attemptLimit = 50
        
        for _ in 0..<attemptLimit {
            let x = CGFloat.random(in: margin...(screenSize.width - margin))
            let y = CGFloat.random(in: margin...(screenSize.height - margin))
            let newPosition = CGPoint(x: x, y: y)
            
            // Check if the position overlaps with any existing bubble
            let overlaps = bubbles.contains { bubble in
                let distance = sqrt(
                    pow(newPosition.x - bubble.position.x, 2) +
                    pow(newPosition.y - bubble.position.y, 2)
                )
                return distance < bubbleSize
            }
            
            if !overlaps {
                return newPosition
            }
        }
        
        return nil  // Couldn't find a non-overlapping position
    }
    
    // Pop a bubble
    func popBubble(at index: Int) {
        guard index < bubbles.count, gameActive else { return }
        
        let bubble = bubbles[index]
        
        // Calculate points based on combo
        var pointsEarned = bubble.points
        
        if let lastColor = lastPoppedColor, lastColor == bubble.color {
            // Same color combo - 1.5x points
            pointsEarned = Int(Double(pointsEarned) * 1.5)
            comboMultiplier += 1
        } else {
            // Reset combo
            comboMultiplier = 0
        }
        
        // Update last popped color
        lastPoppedColor = bubble.color
        
        // Add points to score
        score += pointsEarned
        
        // Remove the bubble
        bubbles.remove(at: index)
    }
    
    // MARK: - Settings and Persistence
    
    // Save game settings
    func saveSettings() {
        if let encodedData = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(encodedData, forKey: "gameSettings")
        }
    }
    
    // Load game settings
    func loadSettings() {
        if let savedSettings = UserDefaults.standard.data(forKey: "gameSettings"),
           let decodedSettings = try? JSONDecoder().decode(GameSettings.self, from: savedSettings) {
            settings = decodedSettings
        }
    }
    
    // Update high scores
    func updateHighScores(with player: Player) {
        highScores.append(player)
        highScores.sort { $0.score > $1.score }
        
        // Keep only top 10 scores
        if highScores.count > 10 {
            highScores = Array(highScores.prefix(10))
        }
        
        saveHighScores()
    }
    
    // Save high scores
    func saveHighScores() {
        if let encodedData = try? JSONEncoder().encode(highScores) {
            UserDefaults.standard.set(encodedData, forKey: "highScores")
        }
    }
    
    // Load high scores
    func loadHighScores() {
        if let savedScores = UserDefaults.standard.data(forKey: "highScores"),
           let decodedScores = try? JSONDecoder().decode([Player].self, from: savedScores) {
            highScores = decodedScores
        }
    }
    // Calculate points for a bubble without popping it
    func calculatePointsForBubble(_ bubble: Bubble) -> Int {
        var pointsEarned = bubble.points
        
        if let lastColor = lastPoppedColor, lastColor == bubble.color {
            // Same color combo - 1.5x points
            pointsEarned = Int(Double(pointsEarned) * 1.5)
        }
        
        return pointsEarned
    }
}
