//
//  Quiz.swift
//  QuizVeNacional
//
//  Created by Вячеслав on 10/23/25.
//

import Foundation

// MARK: - Quiz Model
struct Quiz: Identifiable, Codable, Hashable {
    let id = UUID()
    let title: String
    let description: String
    let category: QuizCategory
    let difficulty: QuizDifficulty
    let questions: [QuizQuestion]
    let estimatedTime: Int // in minutes
    let imageURL: String?
    let isUserGenerated: Bool
    let createdAt: Date
    let createdBy: String?
    
    var completionRate: Double {
        // Calculate based on user performance (to be implemented with user data)
        return 0.0
    }
    
    var totalQuestions: Int {
        return questions.count
    }
}

// MARK: - Quiz Category
enum QuizCategory: String, CaseIterable, Codable {
    case technology = "Technology"
    case science = "Science"
    case history = "History"
    case geography = "Geography"
    case entertainment = "Entertainment"
    case sports = "Sports"
    case art = "Art"
    case literature = "Literature"
    case mathematics = "Mathematics"
    case futuristic = "Futuristic"
    case userGenerated = "User Generated"
    
    var icon: String {
        switch self {
        case .technology: return "laptopcomputer"
        case .science: return "atom"
        case .history: return "clock.arrow.circlepath"
        case .geography: return "globe"
        case .entertainment: return "tv"
        case .sports: return "sportscourt"
        case .art: return "paintbrush"
        case .literature: return "book"
        case .mathematics: return "function"
        case .futuristic: return "sparkles"
        case .userGenerated: return "person.crop.circle.badge.plus"
        }
    }
    
    var color: String {
        switch self {
        case .technology: return "#0954A6"
        case .science: return "#34C759"
        case .history: return "#FF9500"
        case .geography: return "#007AFF"
        case .entertainment: return "#FF2D92"
        case .sports: return "#FF3B30"
        case .art: return "#AF52DE"
        case .literature: return "#5856D6"
        case .mathematics: return "#FF9500"
        case .futuristic: return "#F8C029"
        case .userGenerated: return "#8E8E93"
        }
    }
}

// MARK: - Quiz Difficulty
enum QuizDifficulty: String, CaseIterable, Codable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
    case expert = "Expert"
    
    var color: String {
        switch self {
        case .easy: return "#34C759"
        case .medium: return "#FF9500"
        case .hard: return "#FF3B30"
        case .expert: return "#AF52DE"
        }
    }
    
    var points: Int {
        switch self {
        case .easy: return 10
        case .medium: return 20
        case .hard: return 30
        case .expert: return 50
        }
    }
}

// MARK: - Quiz Question
struct QuizQuestion: Identifiable, Codable, Hashable {
    let id = UUID()
    let question: String
    let options: [String]
    let correctAnswerIndex: Int
    let explanation: String?
    let imageURL: String?
    let timeLimit: Int? // in seconds
    
    var correctAnswer: String {
        return options[correctAnswerIndex]
    }
    
    func isCorrect(selectedIndex: Int) -> Bool {
        return selectedIndex == correctAnswerIndex
    }
}

// MARK: - Quiz Result
struct QuizResult: Identifiable, Codable {
    let id = UUID()
    let quizId: UUID
    let score: Int
    let totalQuestions: Int
    let correctAnswers: Int
    let timeSpent: TimeInterval
    let completedAt: Date
    let answers: [QuizAnswer]
    
    var percentage: Double {
        return Double(correctAnswers) / Double(totalQuestions) * 100
    }
    
    var grade: QuizGrade {
        switch percentage {
        case 90...100: return .excellent
        case 80..<90: return .good
        case 70..<80: return .average
        case 60..<70: return .belowAverage
        default: return .poor
        }
    }
}

// MARK: - Quiz Answer
struct QuizAnswer: Identifiable, Codable {
    let id = UUID()
    let questionId: UUID
    let selectedIndex: Int
    let isCorrect: Bool
    let timeSpent: TimeInterval
}

// MARK: - Quiz Grade
enum QuizGrade: String, CaseIterable {
    case excellent = "Excellent"
    case good = "Good"
    case average = "Average"
    case belowAverage = "Below Average"
    case poor = "Poor"
    
    var color: String {
        switch self {
        case .excellent: return "#34C759"
        case .good: return "#30D158"
        case .average: return "#FF9500"
        case .belowAverage: return "#FF6B35"
        case .poor: return "#FF3B30"
        }
    }
    
    var emoji: String {
        switch self {
        case .excellent: return "🏆"
        case .good: return "🎉"
        case .average: return "👍"
        case .belowAverage: return "📚"
        case .poor: return "💪"
        }
    }
}

