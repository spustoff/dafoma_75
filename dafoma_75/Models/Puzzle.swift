//
//  Puzzle.swift
//  QuizVeNacional
//
//  Created by Вячеслав on 10/23/25.
//

import Foundation

// MARK: - Puzzle Model
struct Puzzle: Identifiable, Codable, Hashable {
    let id = UUID()
    let title: String
    let description: String
    let type: PuzzleType
    let difficulty: PuzzleDifficulty
    let content: PuzzleContent
    let solution: String
    let hints: [String]
    let timeLimit: Int? // in minutes
    let points: Int
    let isUserGenerated: Bool
    let createdAt: Date
    let createdBy: String?
    
    var estimatedTime: Int {
        return timeLimit ?? (difficulty.baseTime + type.additionalTime)
    }
}

// MARK: - Puzzle Type
enum PuzzleType: String, CaseIterable, Codable {
    case logic = "Logic"
    case wordPuzzle = "Word Puzzle"
    case mathPuzzle = "Math Puzzle"
    case pattern = "Pattern"
    case riddle = "Riddle"
    case codeBreaking = "Code Breaking"
    case spatial = "Spatial"
    case memory = "Memory"
    
    var icon: String {
        switch self {
        case .logic: return "brain.head.profile"
        case .wordPuzzle: return "textformat.abc"
        case .mathPuzzle: return "function"
        case .pattern: return "grid"
        case .riddle: return "questionmark.circle"
        case .codeBreaking: return "lock.shield"
        case .spatial: return "cube"
        case .memory: return "memorychip"
        }
    }
    
    var color: String {
        switch self {
        case .logic: return "#0954A6"
        case .wordPuzzle: return "#34C759"
        case .mathPuzzle: return "#FF9500"
        case .pattern: return "#AF52DE"
        case .riddle: return "#FF2D92"
        case .codeBreaking: return "#FF3B30"
        case .spatial: return "#007AFF"
        case .memory: return "#F8C029"
        }
    }
    
    var additionalTime: Int {
        switch self {
        case .logic: return 5
        case .wordPuzzle: return 3
        case .mathPuzzle: return 7
        case .pattern: return 4
        case .riddle: return 2
        case .codeBreaking: return 10
        case .spatial: return 6
        case .memory: return 1
        }
    }
}

// MARK: - Puzzle Difficulty
enum PuzzleDifficulty: String, CaseIterable, Codable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
    case master = "Master"
    
    var color: String {
        switch self {
        case .beginner: return "#34C759"
        case .intermediate: return "#FF9500"
        case .advanced: return "#FF3B30"
        case .master: return "#AF52DE"
        }
    }
    
    var basePoints: Int {
        switch self {
        case .beginner: return 25
        case .intermediate: return 50
        case .advanced: return 100
        case .master: return 200
        }
    }
    
    var baseTime: Int {
        switch self {
        case .beginner: return 5
        case .intermediate: return 10
        case .advanced: return 15
        case .master: return 20
        }
    }
    
    var maxHints: Int {
        switch self {
        case .beginner: return 3
        case .intermediate: return 2
        case .advanced: return 1
        case .master: return 0
        }
    }
}

// MARK: - Puzzle Content
struct PuzzleContent: Codable, Hashable {
    let mainContent: String
    let imageURL: String?
    let additionalData: [String: String]? // For flexible content types
    
    init(mainContent: String, imageURL: String? = nil, additionalData: [String: String]? = nil) {
        self.mainContent = mainContent
        self.imageURL = imageURL
        self.additionalData = additionalData
    }
}

// MARK: - Puzzle Result
struct PuzzleResult: Identifiable, Codable {
    let id = UUID()
    let puzzleId: UUID
    let isCompleted: Bool
    let isSolved: Bool
    let timeSpent: TimeInterval
    let hintsUsed: Int
    let attempts: Int
    let completedAt: Date
    let finalAnswer: String?
    
    var score: Int {
        guard isSolved else { return 0 }
        
        // Base score from puzzle difficulty
        let baseScore = 100
        
        // Time bonus (faster = more points)
        let timeBonus = max(0, 50 - Int(timeSpent / 60)) // Bonus decreases with time
        
        // Hint penalty
        let hintPenalty = hintsUsed * 10
        
        // Attempt penalty
        let attemptPenalty = max(0, (attempts - 1) * 5)
        
        return max(10, baseScore + timeBonus - hintPenalty - attemptPenalty)
    }
    
    var performance: PuzzlePerformance {
        guard isSolved else { return .failed }
        
        switch score {
        case 90...Int.max: return .excellent
        case 70..<90: return .good
        case 50..<70: return .average
        case 30..<50: return .belowAverage
        default: return .poor
        }
    }
}

// MARK: - Puzzle Performance
enum PuzzlePerformance: String, CaseIterable {
    case excellent = "Excellent"
    case good = "Good"
    case average = "Average"
    case belowAverage = "Below Average"
    case poor = "Poor"
    case failed = "Failed"
    
    var color: String {
        switch self {
        case .excellent: return "#34C759"
        case .good: return "#30D158"
        case .average: return "#FF9500"
        case .belowAverage: return "#FF6B35"
        case .poor: return "#FF3B30"
        case .failed: return "#8E8E93"
        }
    }
    
    var emoji: String {
        switch self {
        case .excellent: return "🏆"
        case .good: return "🎉"
        case .average: return "👍"
        case .belowAverage: return "📚"
        case .poor: return "💪"
        case .failed: return "😔"
        }
    }
}

// MARK: - Puzzle Session
struct PuzzleSession: Identifiable, Codable {
    let id = UUID()
    let puzzleId: UUID
    let startTime: Date
    var currentAnswer: String
    var hintsUsed: Int
    var attempts: Int
    var isCompleted: Bool
    
    init(puzzleId: UUID) {
        self.puzzleId = puzzleId
        self.startTime = Date()
        self.currentAnswer = ""
        self.hintsUsed = 0
        self.attempts = 0
        self.isCompleted = false
    }
    
    var elapsedTime: TimeInterval {
        return Date().timeIntervalSince(startTime)
    }
}

