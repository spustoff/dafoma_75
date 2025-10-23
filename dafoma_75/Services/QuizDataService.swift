//
//  QuizDataService.swift
//  QuizVeNacional
//
//  Created by Вячеслав on 10/23/25.
//

import Foundation
import Combine

// MARK: - Quiz Data Service
class QuizDataService: ObservableObject {
    @Published var quizzes: [Quiz] = []
    @Published var userQuizzes: [Quiz] = []
    @Published var quizResults: [QuizResult] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let userDefaults = UserDefaults.standard
    private let quizzesKey = "SavedQuizzes"
    private let userQuizzesKey = "UserGeneratedQuizzes"
    private let resultsKey = "QuizResults"
    
    init() {
        loadQuizzes()
        loadUserQuizzes()
        loadQuizResults()
        generateSampleQuizzes()
    }
    
    // MARK: - Quiz Management
    func loadQuizzes() {
        if let data = userDefaults.data(forKey: quizzesKey),
           let savedQuizzes = try? JSONDecoder().decode([Quiz].self, from: data) {
            self.quizzes = savedQuizzes
        }
    }
    
    func saveQuizzes() {
        if let data = try? JSONEncoder().encode(quizzes) {
            userDefaults.set(data, forKey: quizzesKey)
        }
    }
    
    func loadUserQuizzes() {
        if let data = userDefaults.data(forKey: userQuizzesKey),
           let savedQuizzes = try? JSONDecoder().decode([Quiz].self, from: data) {
            self.userQuizzes = savedQuizzes
        }
    }
    
    func saveUserQuizzes() {
        if let data = try? JSONEncoder().encode(userQuizzes) {
            userDefaults.set(data, forKey: userQuizzesKey)
        }
    }
    
    func addUserQuiz(_ quiz: Quiz) {
        userQuizzes.append(quiz)
        saveUserQuizzes()
    }
    
    func deleteUserQuiz(withId id: UUID) {
        userQuizzes.removeAll { $0.id == id }
        saveUserQuizzes()
    }
    
    // MARK: - Quiz Results Management
    func loadQuizResults() {
        if let data = userDefaults.data(forKey: resultsKey),
           let savedResults = try? JSONDecoder().decode([QuizResult].self, from: data) {
            self.quizResults = savedResults
        }
    }
    
    func saveQuizResults() {
        if let data = try? JSONEncoder().encode(quizResults) {
            userDefaults.set(data, forKey: resultsKey)
        }
    }
    
    func addQuizResult(_ result: QuizResult) {
        quizResults.append(result)
        saveQuizResults()
    }
    
    func getQuizResults(for quizId: UUID) -> [QuizResult] {
        return quizResults.filter { $0.quizId == quizId }
    }
    
    func getBestResult(for quizId: UUID) -> QuizResult? {
        return getQuizResults(for: quizId).max { $0.score < $1.score }
    }
    
    // MARK: - Quiz Filtering and Searching
    func getQuizzes(by category: QuizCategory) -> [Quiz] {
        return quizzes.filter { $0.category == category }
    }
    
    func getQuizzes(by difficulty: QuizDifficulty) -> [Quiz] {
        return quizzes.filter { $0.difficulty == difficulty }
    }
    
    func searchQuizzes(with searchText: String) -> [Quiz] {
        guard !searchText.isEmpty else { return quizzes }
        
        return quizzes.filter { quiz in
            quiz.title.localizedCaseInsensitiveContains(searchText) ||
            quiz.description.localizedCaseInsensitiveContains(searchText) ||
            quiz.category.rawValue.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    // MARK: - Statistics
    func getTotalQuizzesCompleted() -> Int {
        return Set(quizResults.map { $0.quizId }).count
    }
    
    func getAverageScore() -> Double {
        guard !quizResults.isEmpty else { return 0 }
        let totalScore = quizResults.reduce(0) { $0 + $1.score }
        return Double(totalScore) / Double(quizResults.count)
    }
    
    func getTotalTimeSpent() -> TimeInterval {
        return quizResults.reduce(0) { $0 + $1.timeSpent }
    }
    
    func getQuizzesByCategory() -> [QuizCategory: Int] {
        var categoryCount: [QuizCategory: Int] = [:]
        for category in QuizCategory.allCases {
            categoryCount[category] = getQuizzes(by: category).count
        }
        return categoryCount
    }
    
    // MARK: - Data Reset
    func resetAllData() {
        quizzes.removeAll()
        userQuizzes.removeAll()
        quizResults.removeAll()
        
        userDefaults.removeObject(forKey: quizzesKey)
        userDefaults.removeObject(forKey: userQuizzesKey)
        userDefaults.removeObject(forKey: resultsKey)
        
        generateSampleQuizzes()
    }
    
    // MARK: - Sample Data Generation
    private func generateSampleQuizzes() {
        guard quizzes.isEmpty else { return }
        
        let sampleQuizzes = [
            Quiz(
                title: "Future Technology Trends",
                description: "Explore the cutting-edge technologies that will shape our future",
                category: .futuristic,
                difficulty: .medium,
                questions: [
                    QuizQuestion(
                        question: "Which technology is expected to revolutionize transportation by 2030?",
                        options: ["Autonomous Vehicles", "Teleportation", "Flying Cars", "Hyperloop"],
                        correctAnswerIndex: 0,
                        explanation: "Autonomous vehicles are already in development and testing phases.",
                        imageURL: nil,
                        timeLimit: 30
                    ),
                    QuizQuestion(
                        question: "What is the primary benefit of quantum computing?",
                        options: ["Faster internet", "Solving complex problems", "Better graphics", "Longer battery life"],
                        correctAnswerIndex: 1,
                        explanation: "Quantum computers can solve certain complex problems exponentially faster than classical computers.",
                        imageURL: nil,
                        timeLimit: 45
                    ),
                    QuizQuestion(
                        question: "Which AI technology is most likely to impact healthcare?",
                        options: ["Gaming AI", "Medical Diagnosis AI", "Social Media AI", "Music AI"],
                        correctAnswerIndex: 1,
                        explanation: "AI-powered medical diagnosis can help doctors identify diseases more accurately and quickly.",
                        imageURL: nil,
                        timeLimit: 30
                    )
                ],
                estimatedTime: 5,
                imageURL: nil,
                isUserGenerated: false,
                createdAt: Date(),
                createdBy: nil
            ),
            Quiz(
                title: "Space Exploration Quiz",
                description: "Test your knowledge about space exploration and astronomy",
                category: .science,
                difficulty: .hard,
                questions: [
                    QuizQuestion(
                        question: "Which planet has the most moons in our solar system?",
                        options: ["Jupiter", "Saturn", "Neptune", "Uranus"],
                        correctAnswerIndex: 1,
                        explanation: "Saturn has 146 confirmed moons, making it the planet with the most moons.",
                        imageURL: nil,
                        timeLimit: 30
                    ),
                    QuizQuestion(
                        question: "What is the closest star to Earth after the Sun?",
                        options: ["Alpha Centauri", "Proxima Centauri", "Sirius", "Vega"],
                        correctAnswerIndex: 1,
                        explanation: "Proxima Centauri is the closest star to Earth at about 4.24 light-years away.",
                        imageURL: nil,
                        timeLimit: 45
                    )
                ],
                estimatedTime: 3,
                imageURL: nil,
                isUserGenerated: false,
                createdAt: Date(),
                createdBy: nil
            ),
            Quiz(
                title: "Programming Fundamentals",
                description: "Basic programming concepts and terminology",
                category: .technology,
                difficulty: .easy,
                questions: [
                    QuizQuestion(
                        question: "What does 'API' stand for?",
                        options: ["Application Programming Interface", "Advanced Programming Integration", "Automated Program Instruction", "Application Process Integration"],
                        correctAnswerIndex: 0,
                        explanation: "API stands for Application Programming Interface, which allows different software applications to communicate.",
                        imageURL: nil,
                        timeLimit: 30
                    ),
                    QuizQuestion(
                        question: "Which of these is a programming language?",
                        options: ["HTML", "CSS", "Python", "JSON"],
                        correctAnswerIndex: 2,
                        explanation: "Python is a programming language, while HTML and CSS are markup languages, and JSON is a data format.",
                        imageURL: nil,
                        timeLimit: 20
                    )
                ],
                estimatedTime: 2,
                imageURL: nil,
                isUserGenerated: false,
                createdAt: Date(),
                createdBy: nil
            )
        ]
        
        self.quizzes = sampleQuizzes
        saveQuizzes()
    }
}
