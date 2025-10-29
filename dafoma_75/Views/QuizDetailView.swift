//
//  QuizDetailView.swift
//  QuizVeNacional
//
//  Created by Вячеслав on 10/23/25.
//

import SwiftUI

struct QuizDetailView: View {
    let quiz: Quiz
    @StateObject private var quizDataService = QuizDataService()
    @StateObject private var quizViewModel: QuizViewModel
    @State private var showingQuiz = false
    @Environment(\.dismiss) private var dismiss
    
    init(quiz: Quiz) {
        self.quiz = quiz
        self._quizViewModel = StateObject(wrappedValue: QuizViewModel(quizDataService: QuizDataService()))
    }
    
    var bestResult: QuizResult? {
        quizDataService.getBestResult(for: quiz.id)
    }
    
    var allResults: [QuizResult] {
        quizDataService.getQuizResults(for: quiz.id)
    }
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [Color.primaryBackground, Color.secondaryBackground],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.lg) {
                    // Header
                    VStack(alignment: .leading, spacing: AppSpacing.md) {
                        HStack {
                            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                                Text(quiz.title)
                                    .font(AppFonts.largeTitle)
                                    .font(.system(size: 17, weight: .bold))
                                    .foregroundColor(Color.textPrimary)
                                
                                Text(quiz.category.rawValue)
                                    .font(AppFonts.subheadline)
                                    .foregroundColor(Color(hex: quiz.category.color))
                            }
                            
                            Spacer()
                            
                            Image(systemName: quiz.category.icon)
                                .font(.system(size: 40))
                                .foregroundColor(Color(hex: quiz.category.color))
                        }
                        
                        Text(quiz.description)
                            .font(AppFonts.body)
                            .foregroundColor(Color.textSecondary)
                            .lineLimit(nil)
                    }
                    .padding(AppSpacing.lg)
                    .background(Color.cardBackground)
                    .cornerRadius(AppCornerRadius.large)
                    
                    // Quiz Stats
                    VStack(alignment: .leading, spacing: AppSpacing.md) {
                        Text("Quiz Information")
                            .font(AppFonts.headline)
                            .foregroundColor(Color.textPrimary)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: AppSpacing.md) {
                            StatCard(
                                icon: "questionmark.circle.fill",
                                title: "Questions",
                                value: "\(quiz.totalQuestions)",
                                color: Color.primaryBlue
                            )
                            
                            StatCard(
                                icon: "clock.fill",
                                title: "Est. Time",
                                value: "\(quiz.estimatedTime) min",
                                color: Color.accentYellow
                            )
                            
                            StatCard(
                                icon: "target",
                                title: "Difficulty",
                                value: quiz.difficulty.rawValue,
                                color: Color(hex: quiz.difficulty.color)
                            )
                            
                            StatCard(
                                icon: "star.fill",
                                title: "Points",
                                value: "\(quiz.difficulty.points * quiz.totalQuestions)",
                                color: Color.accentYellow
                            )
                        }
                    }
                    .padding(AppSpacing.lg)
                    .background(Color.cardBackground)
                    .cornerRadius(AppCornerRadius.large)
                    
                    // Performance Section
                    if !allResults.isEmpty {
                        VStack(alignment: .leading, spacing: AppSpacing.md) {
                            Text("Your Performance")
                                .font(AppFonts.headline)
                                .foregroundColor(Color.textPrimary)
                            
                            if let best = bestResult {
                                VStack(spacing: AppSpacing.sm) {
                                    HStack {
                                        Text("Best Score")
                                            .font(AppFonts.subheadline)
                                            .foregroundColor(Color.textSecondary)
                                        
                                        Spacer()
                                        
                                        Text("\(Int(best.percentage))%")
                                            .font(AppFonts.title2)
                                            .font(.system(size: 17, weight: .bold))
                                            .foregroundColor(Color(hex: best.grade.color))
                                    }
                                    
                                    HStack {
                                        Text(best.grade.emoji)
                                        Text(best.grade.rawValue)
                                            .font(AppFonts.callout)
                                            .foregroundColor(Color(hex: best.grade.color))
                                        
                                        Spacer()
                                        
                                        Text("Attempts: \(allResults.count)")
                                            .font(AppFonts.caption)
                                            .foregroundColor(Color.textSecondary)
                                    }
                                }
                            }
                        }
                        .padding(AppSpacing.lg)
                        .background(Color.cardBackground)
                        .cornerRadius(AppCornerRadius.large)
                    }
                    
                    // Questions Preview
                    VStack(alignment: .leading, spacing: AppSpacing.md) {
                        Text("Questions Preview")
                            .font(AppFonts.headline)
                            .foregroundColor(Color.textPrimary)
                        
                        ForEach(Array(quiz.questions.prefix(3).enumerated()), id: \.element.id) { index, question in
                            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                                HStack {
                                    Text("Question \(index + 1)")
                                        .font(AppFonts.caption)
                                        .foregroundColor(Color.textSecondary)
                                    
                                    Spacer()
                                    
                                    if let timeLimit = question.timeLimit {
                                        HStack(spacing: AppSpacing.xs) {
                                            Image(systemName: "timer")
                                                .font(.caption)
                                            Text("\(timeLimit)s")
                                                .font(AppFonts.caption)
                                        }
                                        .foregroundColor(Color.textSecondary)
                                    }
                                }
                                
                                Text(question.question)
                                    .font(AppFonts.callout)
                                    .foregroundColor(Color.textPrimary)
                                    .lineLimit(2)
                            }
                            .padding(AppSpacing.md)
                            .background(Color.primaryBackground.opacity(0.3))
                            .cornerRadius(AppCornerRadius.medium)
                        }
                        
                        if quiz.questions.count > 3 {
                            Text("+ \(quiz.questions.count - 3) more questions")
                                .font(AppFonts.caption)
                                .foregroundColor(Color.textSecondary)
                                .padding(.horizontal, AppSpacing.md)
                        }
                    }
                    .padding(AppSpacing.lg)
                    .background(Color.cardBackground)
                    .cornerRadius(AppCornerRadius.large)
                    
                    // Start Quiz Button
                    Button(action: {
                        showingQuiz = true
                    }) {
                        HStack {
                            Image(systemName: "play.fill")
                            Text("Start Quiz")
                                .font(.system(size: 17, weight: .semibold))
                        }
                        .font(AppFonts.headline)
                        .foregroundColor(Color.primaryBackground)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppSpacing.md)
                        .background(Color.accentYellow)
                        .cornerRadius(AppCornerRadius.medium)
                    }
                    .padding(.horizontal, AppSpacing.lg)
                }
                .padding(.horizontal, AppSpacing.md)
                .padding(.bottom, AppSpacing.xl)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: $showingQuiz) {
            QuizPlayView(quiz: quiz, viewModel: quizViewModel)
        }
    }
}

// MARK: - Stat Card
struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: AppSpacing.sm) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(AppFonts.title3)
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(Color.textPrimary)
            
            Text(title)
                .font(AppFonts.caption)
                .foregroundColor(Color.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(AppSpacing.md)
        .background(Color.primaryBackground.opacity(0.3))
        .cornerRadius(AppCornerRadius.medium)
    }
}

// MARK: - Quiz Play View
struct QuizPlayView: View {
    let quiz: Quiz
    @ObservedObject var viewModel: QuizViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showingExitAlert = false
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [Color.primaryBackground, Color.secondaryBackground],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            if viewModel.quizCompleted {
                QuizResultView(result: viewModel.finalResult!, quiz: quiz) {
                    dismiss()
                }
            } else {
                VStack(spacing: 0) {
                    // Header
                    VStack(spacing: AppSpacing.md) {
                        // Progress and timer
                        HStack {
                            Button("Exit") {
                                showingExitAlert = true
                            }
                            .foregroundColor(Color.textSecondary)
                            
                            Spacer()
                            
                            Text("\(viewModel.currentQuestionIndex + 1) / \(quiz.totalQuestions)")
                                .font(AppFonts.callout)
                                .foregroundColor(Color.textSecondary)
                            
                            Spacer()
                            
                            HStack(spacing: AppSpacing.xs) {
                                Image(systemName: "timer")
                                    .foregroundColor(viewModel.timeRemaining <= 10 ? Color.red : Color.textSecondary)
                                Text("\(viewModel.timeRemaining)")
                                    .font(AppFonts.callout)
                                    .font(.system(size: 17, weight: .medium))
                                    .foregroundColor(viewModel.timeRemaining <= 10 ? Color.red : Color.textSecondary)
                            }
                        }
                        
                        // Progress bar
                        ProgressView(value: viewModel.progress)
                            .progressViewStyle(LinearProgressViewStyle(tint: Color.accentYellow))
                            .scaleEffect(x: 1, y: 2, anchor: .center)
                    }
                    .padding(.horizontal, AppSpacing.lg)
                    .padding(.top, AppSpacing.md)
                    
                    ScrollView(.vertical, showsIndicators: false) {
                        
                        VStack {
                            
                            if let question = viewModel.currentQuestion {
                                VStack(spacing: AppSpacing.xl) {
                                    // Question
                                    VStack(spacing: AppSpacing.md) {
                                        Text(question.question)
                                            .font(AppFonts.title2)
                                            .font(.system(size: 17, weight: .medium))
                                            .foregroundColor(Color.textPrimary)
                                            .multilineTextAlignment(.center)
                                            .lineLimit(nil)
                                            .padding(.horizontal, AppSpacing.lg)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, AppSpacing.xl)
                                    
                                    // Answer options
                                    VStack(spacing: AppSpacing.md) {
                                        ForEach(Array(question.options.enumerated()), id: \.offset) { index, option in
                                            AnswerOptionView(
                                                option: option,
                                                index: index,
                                                isSelected: viewModel.selectedAnswerIndex == index,
                                                isCorrect: viewModel.showExplanation ? question.correctAnswerIndex == index : nil,
                                                showResult: viewModel.showExplanation
                                            ) {
                                                viewModel.selectAnswer(index)
                                            }
                                        }
                                    }
                                    .padding(.horizontal, AppSpacing.lg)
                                    
                                    // Explanation
                                    if viewModel.showExplanation, let explanation = question.explanation {
                                        VStack(alignment: .leading, spacing: AppSpacing.sm) {
                                            Text("Explanation")
                                                .font(AppFonts.headline)
                                                .foregroundColor(Color.textPrimary)
                                            
                                            Text(explanation)
                                                .font(AppFonts.body)
                                                .foregroundColor(Color.textSecondary)
                                                .lineLimit(nil)
                                        }
                                        .padding(AppSpacing.md)
                                        .background(Color.cardBackground)
                                        .cornerRadius(AppCornerRadius.medium)
                                        .padding(.horizontal, AppSpacing.lg)
                                    }
                                    
                                    Spacer()
                                    
                                    // Next button
                                    if viewModel.canProceed {
                                        Button(action: {
                                            viewModel.nextQuestion()
                                        }) {
                                            Text(viewModel.isLastQuestion ? "Finish Quiz" : "Next Question")
                                                .font(AppFonts.headline)
                                                .font(.system(size: 17, weight: .semibold))
                                                .foregroundColor(Color.primaryBackground)
                                                .frame(maxWidth: .infinity)
                                                .padding(.vertical, AppSpacing.md)
                                                .background(Color.accentYellow)
                                                .cornerRadius(AppCornerRadius.medium)
                                        }
                                        .padding(.horizontal, AppSpacing.lg)
                                        .padding(.bottom, AppSpacing.xl)
                                    }
                                }
                            }
                        }
                    }
                    
                    // Question content
                    
                }
            }
        }
        .onAppear {
            viewModel.startQuiz(quiz)
        }
        .alert("Exit Quiz?", isPresented: $showingExitAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Exit", role: .destructive) {
                viewModel.resetQuiz()
                dismiss()
            }
        } message: {
            Text("Your progress will be lost if you exit now.")
        }
    }
}

// MARK: - Answer Option View
struct AnswerOptionView: View {
    let option: String
    let index: Int
    let isSelected: Bool
    let isCorrect: Bool?
    let showResult: Bool
    let action: () -> Void
    
    var backgroundColor: Color {
        if showResult {
            if isCorrect == true {
                return Color.green.opacity(0.3)
            } else if isSelected && isCorrect == false {
                return Color.red.opacity(0.3)
            }
        } else if isSelected {
            return Color.accentYellow.opacity(0.3)
        }
        return Color.cardBackground
    }
    
    var borderColor: Color {
        if showResult {
            if isCorrect == true {
                return Color.green
            } else if isSelected && isCorrect == false {
                return Color.red
            }
        } else if isSelected {
            return Color.accentYellow
        }
        return Color.textSecondary.opacity(0.2)
    }
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(option)
                    .font(AppFonts.body)
                    .foregroundColor(Color.textPrimary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(nil)
                
                Spacer()
                
                if showResult {
                    Image(systemName: isCorrect == true ? "checkmark.circle.fill" : (isSelected ? "xmark.circle.fill" : "circle"))
                        .foregroundColor(isCorrect == true ? Color.green : (isSelected ? Color.red : Color.textSecondary))
                }
            }
            .padding(AppSpacing.md)
            .background(backgroundColor)
            .cornerRadius(AppCornerRadius.medium)
            .overlay(
                RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                    .stroke(borderColor, lineWidth: 2)
            )
        }
        .disabled(showResult)
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Quiz Result View
struct QuizResultView: View {
    let result: QuizResult
    let quiz: Quiz
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: AppSpacing.xl) {
            // Result header
            VStack(spacing: AppSpacing.md) {
                Text(result.grade.emoji)
                    .font(.system(size: 80))
                
                Text(result.grade.rawValue)
                    .font(AppFonts.largeTitle)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(Color(hex: result.grade.color))
                
                Text("\(Int(result.percentage))% Correct")
                    .font(AppFonts.title2)
                    .foregroundColor(Color.textPrimary)
            }
            
            // Stats
            VStack(spacing: AppSpacing.md) {
                HStack {
                    StatItem(title: "Score", value: "\(result.score)")
                    StatItem(title: "Correct", value: "\(result.correctAnswers)/\(result.totalQuestions)")
                    StatItem(title: "Time", value: "\(Int(result.timeSpent / 60)):\(String(format: "%02d", Int(result.timeSpent) % 60))")
                }
            }
            .padding(AppSpacing.lg)
            .background(Color.cardBackground)
            .cornerRadius(AppCornerRadius.large)
            
            Spacer()
            
            // Actions
            VStack(spacing: AppSpacing.md) {
                Button("Try Again") {
                    // Restart quiz logic would go here
                    onDismiss()
                }
                .buttonStyle(PrimaryButtonStyle())
                
                Button("Back to Quizzes") {
                    onDismiss()
                }
                .buttonStyle(SecondaryButtonStyle())
            }
        }
        .padding(AppSpacing.lg)
    }
}

// MARK: - Stat Item
struct StatItem: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: AppSpacing.xs) {
            Text(value)
                .font(AppFonts.title3)
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(Color.textPrimary)
            
            Text(title)
                .font(AppFonts.caption)
                .foregroundColor(Color.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Button Styles
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppFonts.headline.weight(.semibold))
            .foregroundColor(Color.primaryBackground)
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppSpacing.md)
            .background(Color.accentYellow)
            .cornerRadius(AppCornerRadius.medium)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppFonts.headline)
            .foregroundColor(Color.textSecondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppSpacing.md)
            .background(Color.cardBackground)
            .cornerRadius(AppCornerRadius.medium)
            .overlay(
                RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                    .stroke(Color.textSecondary.opacity(0.2), lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Preview
#Preview {
    QuizDetailView(quiz: Quiz(
        title: "Sample Quiz",
        description: "A sample quiz for preview",
        category: .technology,
        difficulty: .medium,
        questions: [],
        estimatedTime: 5,
        imageURL: nil,
        isUserGenerated: false,
        createdAt: Date(),
        createdBy: nil
    ))
}
