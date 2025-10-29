//
//  QuizViewModel.swift
//  QuizVeNacional
//
//  Created by Вячеслав on 10/23/25.
//

import Foundation
import Combine

// MARK: - Quiz View Model
class QuizViewModel: ObservableObject {
    @Published var currentQuiz: Quiz?
    @Published var currentQuestionIndex = 0
    @Published var selectedAnswerIndex: Int?
    @Published var showExplanation = false
    @Published var quizCompleted = false
    @Published var timeRemaining: Int = 0
    @Published var score = 0
    @Published var correctAnswers = 0
    @Published var userAnswers: [QuizAnswer] = []
    @Published var isLoading = false
    
    private var quizStartTime: Date?
    private var questionStartTime: Date?
    private var timer: Timer?
    private let quizDataService: QuizDataService
    
    init(quizDataService: QuizDataService) {
        self.quizDataService = quizDataService
    }
    
    // MARK: - Quiz Management
    func startQuiz(_ quiz: Quiz) {
        currentQuiz = quiz
        currentQuestionIndex = 0
        selectedAnswerIndex = nil
        showExplanation = false
        quizCompleted = false
        score = 0
        correctAnswers = 0
        userAnswers = []
        quizStartTime = Date()
        
        setupQuestionTimer()
    }
    
    func selectAnswer(_ index: Int) {
        guard selectedAnswerIndex == nil else { return }
        selectedAnswerIndex = index
        
        // Record the answer
        if let quiz = currentQuiz,
           currentQuestionIndex < quiz.questions.count {
            let question = quiz.questions[currentQuestionIndex]
            let isCorrect = question.isCorrect(selectedIndex: index)
            let timeSpent = questionStartTime?.timeIntervalSinceNow ?? 0
            
            let answer = QuizAnswer(
                questionId: question.id,
                selectedIndex: index,
                isCorrect: isCorrect,
                timeSpent: abs(timeSpent)
            )
            
            userAnswers.append(answer)
            
            if isCorrect {
                correctAnswers += 1
                score += currentQuiz?.difficulty.points ?? 0
            }
        }
        
        // Show explanation after a brief delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.showExplanation = true
        }
    }
    
    func nextQuestion() {
        guard let quiz = currentQuiz else { return }
        
        if currentQuestionIndex < quiz.questions.count - 1 {
            currentQuestionIndex += 1
            selectedAnswerIndex = nil
            showExplanation = false
            setupQuestionTimer()
        } else {
            completeQuiz()
        }
    }
    
    func completeQuiz() {
        quizCompleted = true
        timer?.invalidate()
        
        // Save quiz result
        if let quiz = currentQuiz,
           let startTime = quizStartTime {
            let totalTime = abs(startTime.timeIntervalSinceNow)
            
            let result = QuizResult(
                quizId: quiz.id,
                score: score,
                totalQuestions: quiz.questions.count,
                correctAnswers: correctAnswers,
                timeSpent: totalTime,
                completedAt: Date(),
                answers: userAnswers
            )
            
            quizDataService.addQuizResult(result)
        }
    }
    
    func resetQuiz() {
        currentQuiz = nil
        currentQuestionIndex = 0
        selectedAnswerIndex = nil
        showExplanation = false
        quizCompleted = false
        timeRemaining = 0
        score = 0
        correctAnswers = 0
        userAnswers = []
        quizStartTime = nil
        questionStartTime = nil
        timer?.invalidate()
    }
    
    // MARK: - Timer Management
    private func setupQuestionTimer() {
        guard let quiz = currentQuiz,
              currentQuestionIndex < quiz.questions.count else { return }
        
        let question = quiz.questions[currentQuestionIndex]
        timeRemaining = question.timeLimit ?? 60
        questionStartTime = Date()
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                self.timeUp()
            }
        }
    }
    
    private func timeUp() {
        guard selectedAnswerIndex == nil else { return }
        
        // Auto-select no answer (incorrect)
        if let quiz = currentQuiz,
           currentQuestionIndex < quiz.questions.count {
            let question = quiz.questions[currentQuestionIndex]
            let timeSpent = questionStartTime?.timeIntervalSinceNow ?? 0
            
            let answer = QuizAnswer(
                questionId: question.id,
                selectedIndex: -1, // No answer selected
                isCorrect: false,
                timeSpent: abs(timeSpent)
            )
            
            userAnswers.append(answer)
        }
        
        selectedAnswerIndex = -1 // Indicate time up
        showExplanation = true
    }
    
    // MARK: - Computed Properties
    var currentQuestion: QuizQuestion? {
        guard let quiz = currentQuiz,
              currentQuestionIndex < quiz.questions.count else { return nil }
        return quiz.questions[currentQuestionIndex]
    }
    
    var progress: Double {
        guard let quiz = currentQuiz else { return 0 }
        return Double(currentQuestionIndex + 1) / Double(quiz.questions.count)
    }
    
    var isLastQuestion: Bool {
        guard let quiz = currentQuiz else { return false }
        return currentQuestionIndex == quiz.questions.count - 1
    }
    
    var canProceed: Bool {
        return selectedAnswerIndex != nil && showExplanation
    }
    
    var finalResult: QuizResult? {
        guard let quiz = currentQuiz,
              let startTime = quizStartTime,
              quizCompleted else { return nil }
        
        let totalTime = abs(startTime.timeIntervalSinceNow)
        
        return QuizResult(
            quizId: quiz.id,
            score: score,
            totalQuestions: quiz.questions.count,
            correctAnswers: correctAnswers,
            timeSpent: totalTime,
            completedAt: Date(),
            answers: userAnswers
        )
    }
    
    deinit {
        timer?.invalidate()
    }
}

