//
//  PuzzleDataService.swift
//  QuizVeNacional
//
//  Created by Вячеслав on 10/23/25.
//

import Foundation
import Combine

// MARK: - Puzzle Data Service
class PuzzleDataService: ObservableObject {
    @Published var puzzles: [Puzzle] = []
    @Published var userPuzzles: [Puzzle] = []
    @Published var puzzleResults: [PuzzleResult] = []
    @Published var activeSessions: [PuzzleSession] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let userDefaults = UserDefaults.standard
    private let puzzlesKey = "SavedPuzzles"
    private let userPuzzlesKey = "UserGeneratedPuzzles"
    private let resultsKey = "PuzzleResults"
    private let sessionsKey = "PuzzleSessions"
    
    init() {
        loadPuzzles()
        loadUserPuzzles()
        loadPuzzleResults()
        loadActiveSessions()
        generateSamplePuzzles()
    }
    
    // MARK: - Puzzle Management
    func loadPuzzles() {
        if let data = userDefaults.data(forKey: puzzlesKey),
           let savedPuzzles = try? JSONDecoder().decode([Puzzle].self, from: data) {
            self.puzzles = savedPuzzles
        }
    }
    
    func savePuzzles() {
        if let data = try? JSONEncoder().encode(puzzles) {
            userDefaults.set(data, forKey: puzzlesKey)
        }
    }
    
    func loadUserPuzzles() {
        if let data = userDefaults.data(forKey: userPuzzlesKey),
           let savedPuzzles = try? JSONDecoder().decode([Puzzle].self, from: data) {
            self.userPuzzles = savedPuzzles
        }
    }
    
    func saveUserPuzzles() {
        if let data = try? JSONEncoder().encode(userPuzzles) {
            userDefaults.set(data, forKey: userPuzzlesKey)
        }
    }
    
    func addUserPuzzle(_ puzzle: Puzzle) {
        userPuzzles.append(puzzle)
        saveUserPuzzles()
    }
    
    func deleteUserPuzzle(withId id: UUID) {
        userPuzzles.removeAll { $0.id == id }
        saveUserPuzzles()
    }
    
    // MARK: - Puzzle Results Management
    func loadPuzzleResults() {
        if let data = userDefaults.data(forKey: resultsKey),
           let savedResults = try? JSONDecoder().decode([PuzzleResult].self, from: data) {
            self.puzzleResults = savedResults
        }
    }
    
    func savePuzzleResults() {
        if let data = try? JSONEncoder().encode(puzzleResults) {
            userDefaults.set(data, forKey: resultsKey)
        }
    }
    
    func addPuzzleResult(_ result: PuzzleResult) {
        puzzleResults.append(result)
        savePuzzleResults()
    }
    
    func getPuzzleResults(for puzzleId: UUID) -> [PuzzleResult] {
        return puzzleResults.filter { $0.puzzleId == puzzleId }
    }
    
    func getBestResult(for puzzleId: UUID) -> PuzzleResult? {
        return getPuzzleResults(for: puzzleId).max { $0.score < $1.score }
    }
    
    // MARK: - Session Management
    func loadActiveSessions() {
        if let data = userDefaults.data(forKey: sessionsKey),
           let savedSessions = try? JSONDecoder().decode([PuzzleSession].self, from: data) {
            self.activeSessions = savedSessions
        }
    }
    
    func saveActiveSessions() {
        if let data = try? JSONEncoder().encode(activeSessions) {
            userDefaults.set(data, forKey: sessionsKey)
        }
    }
    
    func startPuzzleSession(for puzzleId: UUID) -> PuzzleSession {
        let session = PuzzleSession(puzzleId: puzzleId)
        activeSessions.append(session)
        saveActiveSessions()
        return session
    }
    
    func updateSession(_ session: PuzzleSession) {
        if let index = activeSessions.firstIndex(where: { $0.id == session.id }) {
            activeSessions[index] = session
            saveActiveSessions()
        }
    }
    
    func completeSession(_ session: PuzzleSession, puzzle: Puzzle) -> PuzzleResult {
        let result = PuzzleResult(
            puzzleId: session.puzzleId,
            isCompleted: true,
            isSolved: session.currentAnswer.lowercased() == puzzle.solution.lowercased(),
            timeSpent: session.elapsedTime,
            hintsUsed: session.hintsUsed,
            attempts: session.attempts,
            completedAt: Date(),
            finalAnswer: session.currentAnswer
        )
        
        addPuzzleResult(result)
        
        // Remove completed session
        activeSessions.removeAll { $0.id == session.id }
        saveActiveSessions()
        
        return result
    }
    
    func getActiveSession(for puzzleId: UUID) -> PuzzleSession? {
        return activeSessions.first { $0.puzzleId == puzzleId && !$0.isCompleted }
    }
    
    // MARK: - Puzzle Filtering and Searching
    func getPuzzles(by type: PuzzleType) -> [Puzzle] {
        return puzzles.filter { $0.type == type }
    }
    
    func getPuzzles(by difficulty: PuzzleDifficulty) -> [Puzzle] {
        return puzzles.filter { $0.difficulty == difficulty }
    }
    
    func searchPuzzles(with searchText: String) -> [Puzzle] {
        guard !searchText.isEmpty else { return puzzles }
        
        return puzzles.filter { puzzle in
            puzzle.title.localizedCaseInsensitiveContains(searchText) ||
            puzzle.description.localizedCaseInsensitiveContains(searchText) ||
            puzzle.type.rawValue.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    func getRecommendedPuzzles(basedOnPerformance: Bool = true) -> [Puzzle] {
        if basedOnPerformance && !puzzleResults.isEmpty {
            // Recommend puzzles based on user's performance
            let averageScore = puzzleResults.reduce(0) { $0 + $1.score } / puzzleResults.count
            
            if averageScore > 80 {
                // High performer - suggest harder puzzles
                return puzzles.filter { $0.difficulty == .advanced || $0.difficulty == .master }
            } else if averageScore > 60 {
                // Medium performer - suggest intermediate puzzles
                return puzzles.filter { $0.difficulty == .intermediate || $0.difficulty == .advanced }
            } else {
                // Beginner - suggest easier puzzles
                return puzzles.filter { $0.difficulty == .beginner || $0.difficulty == .intermediate }
            }
        } else {
            // Return a mix of different types and difficulties
            return Array(puzzles.shuffled().prefix(6))
        }
    }
    
    // MARK: - Statistics
    func getTotalPuzzlesCompleted() -> Int {
        return Set(puzzleResults.map { $0.puzzleId }).count
    }
    
    func getTotalPuzzlesSolved() -> Int {
        return puzzleResults.filter { $0.isSolved }.count
    }
    
    func getAverageScore() -> Double {
        let solvedResults = puzzleResults.filter { $0.isSolved }
        guard !solvedResults.isEmpty else { return 0 }
        let totalScore = solvedResults.reduce(0) { $0 + $1.score }
        return Double(totalScore) / Double(solvedResults.count)
    }
    
    func getTotalTimeSpent() -> TimeInterval {
        return puzzleResults.reduce(0) { $0 + $1.timeSpent }
    }
    
    func getPuzzlesByType() -> [PuzzleType: Int] {
        var typeCount: [PuzzleType: Int] = [:]
        for type in PuzzleType.allCases {
            typeCount[type] = getPuzzles(by: type).count
        }
        return typeCount
    }
    
    func getSolveRate() -> Double {
        guard !puzzleResults.isEmpty else { return 0 }
        let solvedCount = getTotalPuzzlesSolved()
        return Double(solvedCount) / Double(puzzleResults.count) * 100
    }
    
    // MARK: - Data Reset
    func resetAllData() {
        puzzles.removeAll()
        userPuzzles.removeAll()
        puzzleResults.removeAll()
        activeSessions.removeAll()
        
        userDefaults.removeObject(forKey: puzzlesKey)
        userDefaults.removeObject(forKey: userPuzzlesKey)
        userDefaults.removeObject(forKey: resultsKey)
        userDefaults.removeObject(forKey: sessionsKey)
        
        generateSamplePuzzles()
    }
    
    // MARK: - Sample Data Generation
    private func generateSamplePuzzles() {
        guard puzzles.isEmpty else { return }
        
        let samplePuzzles = [
            Puzzle(
                title: "The Missing Number",
                description: "Find the missing number in this sequence",
                type: .pattern,
                difficulty: .beginner,
                content: PuzzleContent(
                    mainContent: "2, 4, 8, 16, ?, 64",
                    additionalData: ["hint1": "Each number is double the previous one"]
                ),
                solution: "32",
                hints: [
                    "Look at the relationship between consecutive numbers",
                    "Each number is multiplied by 2",
                    "16 × 2 = ?"
                ],
                timeLimit: 5,
                points: 25,
                isUserGenerated: false,
                createdAt: Date(),
                createdBy: nil
            ),
            Puzzle(
                title: "Future City Riddle",
                description: "A riddle about life in a futuristic city",
                type: .riddle,
                difficulty: .intermediate,
                content: PuzzleContent(
                    mainContent: "I have no wings, yet I fly through the sky. I carry people but I'm not alive. In the future city, I'm everywhere you look. What am I?"
                ),
                solution: "drone",
                hints: [
                    "Think about transportation in the future",
                    "It's unmanned and automated"
                ],
                timeLimit: 10,
                points: 50,
                isUserGenerated: false,
                createdAt: Date(),
                createdBy: nil
            ),
            Puzzle(
                title: "Code Cipher",
                description: "Decode this message from the future",
                type: .codeBreaking,
                difficulty: .advanced,
                content: PuzzleContent(
                    mainContent: "KHOOR ZRUOG",
                    additionalData: ["cipher_type": "Caesar Cipher", "shift": "3"]
                ),
                solution: "hello world",
                hints: [
                    "This is a Caesar cipher",
                    "Each letter is shifted by 3 positions",
                    "K becomes H, H becomes E..."
                ],
                timeLimit: 15,
                points: 100,
                isUserGenerated: false,
                createdAt: Date(),
                createdBy: nil
            ),
            Puzzle(
                title: "Logic Gate Challenge",
                description: "Solve this digital logic puzzle",
                type: .logic,
                difficulty: .master,
                content: PuzzleContent(
                    mainContent: "If A=1, B=0, and C=1, what is the output of: (A AND B) OR (NOT B AND C)?",
                    additionalData: ["logic_type": "Boolean Logic"]
                ),
                solution: "1",
                hints: [],
                timeLimit: 20,
                points: 200,
                isUserGenerated: false,
                createdAt: Date(),
                createdBy: nil
            ),
            Puzzle(
                title: "Word Transformation",
                description: "Transform one word into another",
                type: .wordPuzzle,
                difficulty: .intermediate,
                content: PuzzleContent(
                    mainContent: "Change TECH to DATA in 4 steps, changing one letter at a time. Each step must form a valid word."
                ),
                solution: "tech-deck-deca-data",
                hints: [
                    "Start with TECH",
                    "Think of words with similar letters",
                    "DECK is a valid intermediate word"
                ],
                timeLimit: 12,
                points: 75,
                isUserGenerated: false,
                createdAt: Date(),
                createdBy: nil
            )
        ]
        
        self.puzzles = samplePuzzles
        savePuzzles()
    }
}
