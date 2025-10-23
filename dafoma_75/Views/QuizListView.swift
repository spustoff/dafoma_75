//
//  QuizListView.swift
//  QuizVeNacional
//
//  Created by Вячеслав on 10/23/25.
//

import SwiftUI

struct QuizListView: View {
    @StateObject private var quizDataService = QuizDataService()
    @State private var searchText = ""
    @State private var selectedCategory: QuizCategory?
    @State private var selectedDifficulty: QuizDifficulty?
    @State private var showingCreateQuiz = false
    
    var filteredQuizzes: [Quiz] {
        var quizzes = quizDataService.quizzes + quizDataService.userQuizzes
        
        if !searchText.isEmpty {
            quizzes = quizDataService.searchQuizzes(with: searchText)
        }
        
        if let category = selectedCategory {
            quizzes = quizzes.filter { $0.category == category }
        }
        
        if let difficulty = selectedDifficulty {
            quizzes = quizzes.filter { $0.difficulty == difficulty }
        }
        
        return quizzes
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    colors: [Color.primaryBackground, Color.secondaryBackground],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header with search
                    VStack(spacing: AppSpacing.md) {
                        // Search bar
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(Color.textSecondary)
                            
                            TextField("Search quizzes...", text: $searchText)
                                .textFieldStyle(PlainTextFieldStyle())
                                .foregroundColor(Color.textPrimary)
                        }
                        .padding(.horizontal, AppSpacing.md)
                        .padding(.vertical, AppSpacing.sm)
                        .background(Color.cardBackground)
                        .cornerRadius(AppCornerRadius.medium)
                        .padding(.horizontal, AppSpacing.md)
                        
                        // Filter buttons
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: AppSpacing.sm) {
                                // Category filters
                                ForEach(QuizCategory.allCases, id: \.self) { category in
                                    FilterChip(
                                        title: category.rawValue,
                                        isSelected: selectedCategory == category,
                                        action: {
                                            selectedCategory = selectedCategory == category ? nil : category
                                        }
                                    )
                                }
                                
                                Divider()
                                    .frame(height: 30)
                                    .foregroundColor(Color.textSecondary)
                                
                                // Difficulty filters
                                ForEach(QuizDifficulty.allCases, id: \.self) { difficulty in
                                    FilterChip(
                                        title: difficulty.rawValue,
                                        isSelected: selectedDifficulty == difficulty,
                                        action: {
                                            selectedDifficulty = selectedDifficulty == difficulty ? nil : difficulty
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal, AppSpacing.md)
                        }
                    }
                    .padding(.top, AppSpacing.sm)
                    
                    // Quiz list
                    ScrollView {
                        LazyVStack(spacing: AppSpacing.md) {
                            ForEach(filteredQuizzes) { quiz in
                                NavigationLink(destination: QuizDetailView(quiz: quiz)) {
                                    QuizCardView(quiz: quiz, quizDataService: quizDataService)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal, AppSpacing.md)
                        .padding(.top, AppSpacing.md)
                    }
                }
            }
            .navigationTitle("Quizzes")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingCreateQuiz = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(Color.accentYellow)
                            .font(.title2)
                    }
                }
            }
        }
        .sheet(isPresented: $showingCreateQuiz) {
            CreateQuizView(quizDataService: quizDataService)
        }
    }
}

// MARK: - Quiz Card View
struct QuizCardView: View {
    let quiz: Quiz
    let quizDataService: QuizDataService
    
    var bestResult: QuizResult? {
        quizDataService.getBestResult(for: quiz.id)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text(quiz.title)
                        .font(AppFonts.headline)
                        .foregroundColor(Color.textPrimary)
                        .lineLimit(2)
                    
                    Text(quiz.description)
                        .font(AppFonts.subheadline)
                        .foregroundColor(Color.textSecondary)
                        .lineLimit(3)
                }
                
                Spacer()
                
                // Category icon
                VStack {
                    Image(systemName: quiz.category.icon)
                        .font(.title2)
                        .foregroundColor(Color(hex: quiz.category.color))
                    
                    if let result = bestResult {
                        Text("\(Int(result.percentage))%")
                            .font(AppFonts.caption)
                            .foregroundColor(Color.textSecondary)
                    }
                }
            }
            
            // Stats row
            HStack {
                // Difficulty
                HStack(spacing: AppSpacing.xs) {
                    Circle()
                        .fill(Color(hex: quiz.difficulty.color))
                        .frame(width: 8, height: 8)
                    
                    Text(quiz.difficulty.rawValue)
                        .font(AppFonts.caption)
                        .foregroundColor(Color.textSecondary)
                }
                
                Spacer()
                
                // Questions count
                HStack(spacing: AppSpacing.xs) {
                    Image(systemName: "questionmark.circle")
                        .font(.caption)
                        .foregroundColor(Color.textSecondary)
                    
                    Text("\(quiz.totalQuestions) questions")
                        .font(AppFonts.caption)
                        .foregroundColor(Color.textSecondary)
                }
                
                Spacer()
                
                // Estimated time
                HStack(spacing: AppSpacing.xs) {
                    Image(systemName: "clock")
                        .font(.caption)
                        .foregroundColor(Color.textSecondary)
                    
                    Text("\(quiz.estimatedTime) min")
                        .font(AppFonts.caption)
                        .foregroundColor(Color.textSecondary)
                }
            }
            
            // User generated badge
            if quiz.isUserGenerated {
                HStack {
                    Image(systemName: "person.crop.circle.badge.plus")
                        .font(.caption)
                        .foregroundColor(Color.accentYellow)
                    
                    Text("User Generated")
                        .font(AppFonts.caption)
                        .foregroundColor(Color.accentYellow)
                    
                    Spacer()
                }
            }
        }
        .padding(AppSpacing.md)
        .background(Color.cardBackground)
        .cornerRadius(AppCornerRadius.medium)
        .overlay(
            RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                .stroke(Color.textSecondary.opacity(0.1), lineWidth: 1)
        )
    }
}

// MARK: - Filter Chip
struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(AppFonts.caption)
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(isSelected ? Color.primaryBackground : Color.textSecondary)
                .padding(.horizontal, AppSpacing.sm)
                .padding(.vertical, AppSpacing.xs)
                .background(
                    RoundedRectangle(cornerRadius: AppCornerRadius.small)
                        .fill(isSelected ? Color.accentYellow : Color.cardBackground)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: AppCornerRadius.small)
                        .stroke(Color.textSecondary.opacity(0.2), lineWidth: isSelected ? 0 : 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Create Quiz View
struct CreateQuizView: View {
    let quizDataService: QuizDataService
    @Environment(\.dismiss) private var dismiss
    
    @State private var quizTitle = ""
    @State private var quizDescription = ""
    @State private var selectedCategory: QuizCategory = .userGenerated
    @State private var selectedDifficulty: QuizDifficulty = .easy
    @State private var estimatedTime = 5
    @State private var questions: [CreateQuizQuestion] = []
    @State private var showingAddQuestion = false
    @State private var isCreating = false
    
    var canSave: Bool {
        !quizTitle.isEmpty && !quizDescription.isEmpty && questions.count >= 1
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [Color.primaryBackground, Color.secondaryBackground],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: AppSpacing.lg) {
                        // Quiz Info Section
                        VStack(alignment: .leading, spacing: AppSpacing.md) {
                            Text("Quiz Information")
                                .font(AppFonts.headline)
                                .foregroundColor(Color.textPrimary)
                            
                            VStack(spacing: AppSpacing.md) {
                                // Title
                                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                                    Text("Title")
                                        .font(AppFonts.callout)
                                        .foregroundColor(Color.textSecondary)
                                    
                                    TextField("Enter quiz title", text: $quizTitle)
                                        .textFieldStyle(CustomTextFieldStyle())
                                }
                                
                                // Description
                                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                                    Text("Description")
                                        .font(AppFonts.callout)
                                        .foregroundColor(Color.textSecondary)
                                    
                                    TextField("Enter quiz description", text: $quizDescription)
                                        .textFieldStyle(CustomTextFieldStyle())
                                }
                                
                                // Category
                                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                                    Text("Category")
                                        .font(AppFonts.callout)
                                        .foregroundColor(Color.textSecondary)
                                    
                                    Picker("Category", selection: $selectedCategory) {
                                        ForEach(QuizCategory.allCases, id: \.self) { category in
                                            Text(category.rawValue).tag(category)
                                        }
                                    }
                                    .pickerStyle(MenuPickerStyle())
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding()
                                    .background(Color.cardBackground)
                                    .cornerRadius(AppCornerRadius.medium)
                                }
                                
                                // Difficulty and Time
                                HStack(spacing: AppSpacing.md) {
                                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                                        Text("Difficulty")
                                            .font(AppFonts.callout)
                                            .foregroundColor(Color.textSecondary)
                                        
                                        Picker("Difficulty", selection: $selectedDifficulty) {
                                            ForEach(QuizDifficulty.allCases, id: \.self) { difficulty in
                                                Text(difficulty.rawValue).tag(difficulty)
                                            }
                                        }
                                        .pickerStyle(MenuPickerStyle())
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.cardBackground)
                                        .cornerRadius(AppCornerRadius.medium)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                                        Text("Time (min)")
                                            .font(AppFonts.callout)
                                            .foregroundColor(Color.textSecondary)
                                        
                                        Stepper("\(estimatedTime)", value: $estimatedTime, in: 1...60)
                                            .padding()
                                            .background(Color.cardBackground)
                                            .cornerRadius(AppCornerRadius.medium)
                                    }
                                }
                            }
                        }
                        .padding(AppSpacing.lg)
                        .background(Color.cardBackground)
                        .cornerRadius(AppCornerRadius.large)
                        
                        // Questions Section
                        VStack(alignment: .leading, spacing: AppSpacing.md) {
                            HStack {
                                Text("Questions (\(questions.count))")
                                    .font(AppFonts.headline)
                                    .foregroundColor(Color.textPrimary)
                                
                                Spacer()
                                
                                Button(action: {
                                    showingAddQuestion = true
                                }) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(Color.accentYellow)
                                }
                            }
                            
                            if questions.isEmpty {
                                VStack(spacing: AppSpacing.md) {
                                    Image(systemName: "questionmark.circle")
                                        .font(.system(size: 50))
                                        .foregroundColor(Color.textSecondary)
                                    
                                    Text("No questions added yet")
                                        .font(AppFonts.body)
                                        .foregroundColor(Color.textSecondary)
                                    
                                    Text("Add at least one question to create your quiz")
                                        .font(AppFonts.caption)
                                        .foregroundColor(Color.textSecondary)
                                        .multilineTextAlignment(.center)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(AppSpacing.xl)
                            } else {
                                ForEach(Array(questions.enumerated()), id: \.element.id) { index, question in
                                    QuestionRowView(
                                        question: question,
                                        index: index,
                                        onEdit: { editQuestion(at: index) },
                                        onDelete: { deleteQuestion(at: index) }
                                    )
                                }
                            }
                        }
                        .padding(AppSpacing.lg)
                        .background(Color.cardBackground)
                        .cornerRadius(AppCornerRadius.large)
                    }
                    .padding(.horizontal, AppSpacing.md)
                    .padding(.bottom, AppSpacing.xl)
                }
            }
            .navigationTitle("Create Quiz")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(Color.textSecondary)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveQuiz()
                    }
                    .foregroundColor(canSave ? Color.accentYellow : Color.textSecondary)
                    .disabled(!canSave || isCreating)
                }
            }
        }
        .sheet(isPresented: $showingAddQuestion) {
            AddQuestionView { question in
                questions.append(question)
            }
        }
    }
    
    private func editQuestion(at index: Int) {
        // Implementation for editing question
    }
    
    private func deleteQuestion(at index: Int) {
        questions.remove(at: index)
    }
    
    private func saveQuiz() {
        guard canSave else { return }
        
        isCreating = true
        
        let quizQuestions = questions.map { createQuestion in
            QuizQuestion(
                question: createQuestion.question,
                options: createQuestion.options,
                correctAnswerIndex: createQuestion.correctAnswerIndex,
                explanation: createQuestion.explanation.isEmpty ? nil : createQuestion.explanation,
                imageURL: nil,
                timeLimit: createQuestion.timeLimit > 0 ? createQuestion.timeLimit : nil
            )
        }
        
        let newQuiz = Quiz(
            title: quizTitle,
            description: quizDescription,
            category: selectedCategory,
            difficulty: selectedDifficulty,
            questions: quizQuestions,
            estimatedTime: estimatedTime,
            imageURL: nil,
            isUserGenerated: true,
            createdAt: Date(),
            createdBy: "User"
        )
        
        quizDataService.addUserQuiz(newQuiz)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isCreating = false
            dismiss()
        }
    }
}

// MARK: - Supporting Views and Models

// Create Quiz Question Model
struct CreateQuizQuestion: Identifiable {
    let id = UUID()
    var question: String
    var options: [String]
    var correctAnswerIndex: Int
    var explanation: String
    var timeLimit: Int
    
    init(question: String = "", options: [String] = ["", "", "", ""], correctAnswerIndex: Int = 0, explanation: String = "", timeLimit: Int = 30) {
        self.question = question
        self.options = options
        self.correctAnswerIndex = correctAnswerIndex
        self.explanation = explanation
        self.timeLimit = timeLimit
    }
}

// Custom Text Field Style
struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color.cardBackground)
            .cornerRadius(AppCornerRadius.medium)
            .foregroundColor(Color.textPrimary)
    }
}

// Question Row View
struct QuestionRowView: View {
    let question: CreateQuizQuestion
    let index: Int
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack {
                Text("Question \(index + 1)")
                    .font(AppFonts.callout)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(Color.textPrimary)
                
                Spacer()
                
                HStack(spacing: AppSpacing.sm) {
                    Button(action: onEdit) {
                        Image(systemName: "pencil")
                            .foregroundColor(Color.accentYellow)
                    }
                    
                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .foregroundColor(Color.red)
                    }
                }
            }
            
            Text(question.question.isEmpty ? "No question text" : question.question)
                .font(AppFonts.body)
                .foregroundColor(question.question.isEmpty ? Color.textSecondary : Color.textPrimary)
                .lineLimit(2)
            
            HStack {
                Text("Options: \(question.options.filter { !$0.isEmpty }.count)/4")
                    .font(AppFonts.caption)
                    .foregroundColor(Color.textSecondary)
                
                Spacer()
                
                Text("Correct: \(question.correctAnswerIndex + 1)")
                    .font(AppFonts.caption)
                    .foregroundColor(Color.accentYellow)
            }
        }
        .padding(AppSpacing.md)
        .background(Color.primaryBackground.opacity(0.3))
        .cornerRadius(AppCornerRadius.medium)
    }
}

// Add Question View
struct AddQuestionView: View {
    @Environment(\.dismiss) private var dismiss
    let onSave: (CreateQuizQuestion) -> Void
    
    @State private var question = ""
    @State private var options = ["", "", "", ""]
    @State private var correctAnswerIndex = 0
    @State private var explanation = ""
    @State private var timeLimit = 30
    
    var canSave: Bool {
        !question.isEmpty && options.allSatisfy { !$0.isEmpty }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [Color.primaryBackground, Color.secondaryBackground],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: AppSpacing.lg) {
                        // Question
                        VStack(alignment: .leading, spacing: AppSpacing.xs) {
                            Text("Question")
                                .font(AppFonts.callout)
                                .foregroundColor(Color.textSecondary)
                            
                            TextField("Enter your question", text: $question)
                                .textFieldStyle(CustomTextFieldStyle())
                        }
                        
                        // Options
                        VStack(alignment: .leading, spacing: AppSpacing.md) {
                            Text("Answer Options")
                                .font(AppFonts.callout)
                                .foregroundColor(Color.textSecondary)
                            
                            ForEach(0..<4, id: \.self) { index in
                                HStack {
                                    Button(action: {
                                        correctAnswerIndex = index
                                    }) {
                                        Image(systemName: correctAnswerIndex == index ? "checkmark.circle.fill" : "circle")
                                            .foregroundColor(correctAnswerIndex == index ? Color.green : Color.textSecondary)
                                    }
                                    
                                    TextField("Option \(index + 1)", text: $options[index])
                                        .textFieldStyle(CustomTextFieldStyle())
                                }
                            }
                            
                            Text("Tap the circle to mark the correct answer")
                                .font(AppFonts.caption)
                                .foregroundColor(Color.textSecondary)
                        }
                        
                        // Explanation
                        VStack(alignment: .leading, spacing: AppSpacing.xs) {
                            Text("Explanation (Optional)")
                                .font(AppFonts.callout)
                                .foregroundColor(Color.textSecondary)
                            
                            TextField("Explain why this is the correct answer", text: $explanation)
                                .textFieldStyle(CustomTextFieldStyle())
                        }
                        
                        // Time Limit
                        VStack(alignment: .leading, spacing: AppSpacing.xs) {
                            Text("Time Limit (seconds)")
                                .font(AppFonts.callout)
                                .foregroundColor(Color.textSecondary)
                            
                            Stepper("\(timeLimit) seconds", value: $timeLimit, in: 10...120, step: 5)
                                .padding()
                                .background(Color.cardBackground)
                                .cornerRadius(AppCornerRadius.medium)
                        }
                    }
                    .padding(.horizontal, AppSpacing.md)
                    .padding(.bottom, AppSpacing.xl)
                }
            }
            .navigationTitle("Add Question")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(Color.textSecondary)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let newQuestion = CreateQuizQuestion(
                            question: question,
                            options: options,
                            correctAnswerIndex: correctAnswerIndex,
                            explanation: explanation,
                            timeLimit: timeLimit
                        )
                        onSave(newQuestion)
                        dismiss()
                    }
                    .foregroundColor(canSave ? Color.accentYellow : Color.textSecondary)
                    .disabled(!canSave)
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    QuizListView()
}
