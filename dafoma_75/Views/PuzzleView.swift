//
//  PuzzleView.swift
//  QuizVeNacional
//
//  Created by Вячеслав on 10/23/25.
//

import SwiftUI

struct PuzzleView: View {
    @StateObject private var puzzleDataService = PuzzleDataService()
    @State private var searchText = ""
    @State private var selectedType: PuzzleType?
    @State private var selectedDifficulty: PuzzleDifficulty?
    @State private var showingCreatePuzzle = false
    
    var filteredPuzzles: [Puzzle] {
        var puzzles = puzzleDataService.puzzles + puzzleDataService.userPuzzles
        
        if !searchText.isEmpty {
            puzzles = puzzleDataService.searchPuzzles(with: searchText)
        }
        
        if let type = selectedType {
            puzzles = puzzles.filter { $0.type == type }
        }
        
        if let difficulty = selectedDifficulty {
            puzzles = puzzles.filter { $0.difficulty == difficulty }
        }
        
        return puzzles
    }
    
    var recommendedPuzzles: [Puzzle] {
        Array(puzzleDataService.getRecommendedPuzzles().prefix(3))
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
                            
                            TextField("Search puzzles...", text: $searchText)
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
                                // Type filters
                                ForEach(PuzzleType.allCases, id: \.self) { type in
                                    FilterChip(
                                        title: type.rawValue,
                                        isSelected: selectedType == type,
                                        action: {
                                            selectedType = selectedType == type ? nil : type
                                        }
                                    )
                                }
                                
                                Divider()
                                    .frame(height: 30)
                                    .foregroundColor(Color.textSecondary)
                                
                                // Difficulty filters
                                ForEach(PuzzleDifficulty.allCases, id: \.self) { difficulty in
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
                    
                    // Content
                    ScrollView {
                        LazyVStack(spacing: AppSpacing.lg) {
                            // Recommended section
                            if !recommendedPuzzles.isEmpty && searchText.isEmpty && selectedType == nil && selectedDifficulty == nil {
                                VStack(alignment: .leading, spacing: AppSpacing.md) {
                                    HStack {
                                        Text("Recommended for You")
                                            .font(AppFonts.headline)
                                            .foregroundColor(Color.textPrimary)
                                        
                                        Spacer()
                                        
                                        Image(systemName: "sparkles")
                                            .foregroundColor(Color.accentYellow)
                                    }
                                    .padding(.horizontal, AppSpacing.md)
                                    
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: AppSpacing.md) {
                                            ForEach(recommendedPuzzles) { puzzle in
                                                NavigationLink(destination: PuzzleDetailView(puzzle: puzzle)) {
                                                    RecommendedPuzzleCard(puzzle: puzzle, puzzleDataService: puzzleDataService)
                                                }
                                                .buttonStyle(PlainButtonStyle())
                                            }
                                        }
                                        .padding(.horizontal, AppSpacing.md)
                                    }
                                }
                            }
                            
                            // All puzzles
                            VStack(alignment: .leading, spacing: AppSpacing.md) {
                                if !recommendedPuzzles.isEmpty && searchText.isEmpty && selectedType == nil && selectedDifficulty == nil {
                                    Text("All Puzzles")
                                        .font(AppFonts.headline)
                                        .foregroundColor(Color.textPrimary)
                                        .padding(.horizontal, AppSpacing.md)
                                }
                                
                                ForEach(filteredPuzzles) { puzzle in
                                    NavigationLink(destination: PuzzleDetailView(puzzle: puzzle)) {
                                        PuzzleCardView(puzzle: puzzle, puzzleDataService: puzzleDataService)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                        .padding(.horizontal, AppSpacing.md)
                        .padding(.top, AppSpacing.md)
                        .padding(.bottom, AppSpacing.xl)
                    }
                }
            }
            .navigationTitle("Puzzles")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingCreatePuzzle = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(Color.accentYellow)
                            .font(.title2)
                    }
                }
            }
        }
        .sheet(isPresented: $showingCreatePuzzle) {
            CreatePuzzleView(puzzleDataService: puzzleDataService)
        }
    }
}

// MARK: - Puzzle Card View
struct PuzzleCardView: View {
    let puzzle: Puzzle
    let puzzleDataService: PuzzleDataService
    
    var bestResult: PuzzleResult? {
        puzzleDataService.getBestResult(for: puzzle.id)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text(puzzle.title)
                        .font(AppFonts.headline)
                        .foregroundColor(Color.textPrimary)
                        .lineLimit(2)
                    
                    Text(puzzle.description)
                        .font(AppFonts.subheadline)
                        .foregroundColor(Color.textSecondary)
                        .lineLimit(3)
                }
                
                Spacer()
                
                // Type icon
                VStack {
                    Image(systemName: puzzle.type.icon)
                        .font(.title2)
                        .foregroundColor(Color(hex: puzzle.type.color))
                    
                    if let result = bestResult, result.isSolved {
                        Text("\(result.score)")
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
                        .fill(Color(hex: puzzle.difficulty.color))
                        .frame(width: 8, height: 8)
                    
                    Text(puzzle.difficulty.rawValue)
                        .font(AppFonts.caption)
                        .foregroundColor(Color.textSecondary)
                }
                
                Spacer()
                
                // Points
                HStack(spacing: AppSpacing.xs) {
                    Image(systemName: "star.fill")
                        .font(.caption)
                        .foregroundColor(Color.accentYellow)
                    
                    Text("\(puzzle.points) pts")
                        .font(AppFonts.caption)
                        .foregroundColor(Color.textSecondary)
                }
                
                Spacer()
                
                // Estimated time
                HStack(spacing: AppSpacing.xs) {
                    Image(systemName: "clock")
                        .font(.caption)
                        .foregroundColor(Color.textSecondary)
                    
                    Text("\(puzzle.estimatedTime) min")
                        .font(AppFonts.caption)
                        .foregroundColor(Color.textSecondary)
                }
            }
            
            // Status indicator
            HStack {
                if let result = bestResult {
                    HStack(spacing: AppSpacing.xs) {
                        Image(systemName: result.isSolved ? "checkmark.circle.fill" : "clock.fill")
                            .font(.caption)
                            .foregroundColor(result.isSolved ? Color.green : Color.orange)
                        
                        Text(result.isSolved ? "Solved" : "Attempted")
                            .font(AppFonts.caption)
                            .foregroundColor(result.isSolved ? Color.green : Color.orange)
                    }
                } else {
                    HStack(spacing: AppSpacing.xs) {
                        Image(systemName: "circle")
                            .font(.caption)
                            .foregroundColor(Color.textSecondary)
                        
                        Text("Not attempted")
                            .font(AppFonts.caption)
                            .foregroundColor(Color.textSecondary)
                    }
                }
                
                Spacer()
                
                // User generated badge
                if puzzle.isUserGenerated {
                    HStack(spacing: AppSpacing.xs) {
                        Image(systemName: "person.crop.circle.badge.plus")
                            .font(.caption)
                            .foregroundColor(Color.accentYellow)
                        
                        Text("User Created")
                            .font(AppFonts.caption)
                            .foregroundColor(Color.accentYellow)
                    }
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

// MARK: - Recommended Puzzle Card
struct RecommendedPuzzleCard: View {
    let puzzle: Puzzle
    let puzzleDataService: PuzzleDataService
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            // Icon and difficulty
            HStack {
                Image(systemName: puzzle.type.icon)
                    .font(.title2)
                    .foregroundColor(Color(hex: puzzle.type.color))
                
                Spacer()
                
                Circle()
                    .fill(Color(hex: puzzle.difficulty.color))
                    .frame(width: 8, height: 8)
            }
            
            // Title
            Text(puzzle.title)
                .font(AppFonts.callout)
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(Color.textPrimary)
                .lineLimit(2)
            
            // Type and points
            HStack {
                Text(puzzle.type.rawValue)
                    .font(AppFonts.caption)
                    .foregroundColor(Color.textSecondary)
                
                Spacer()
                
                Text("\(puzzle.points) pts")
                    .font(AppFonts.caption)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(Color.accentYellow)
            }
        }
        .padding(AppSpacing.md)
        .frame(width: 160, height: 120)
        .background(Color.cardBackground)
        .cornerRadius(AppCornerRadius.medium)
        .overlay(
            RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                .stroke(Color.textSecondary.opacity(0.1), lineWidth: 1)
        )
    }
}

// MARK: - Create Puzzle View
struct CreatePuzzleView: View {
    let puzzleDataService: PuzzleDataService
    @Environment(\.dismiss) private var dismiss
    
    @State private var puzzleTitle = ""
    @State private var puzzleDescription = ""
    @State private var selectedType: PuzzleType = .riddle
    @State private var selectedDifficulty: PuzzleDifficulty = .beginner
    @State private var puzzleContent = ""
    @State private var solution = ""
    @State private var hints: [String] = [""]
    @State private var timeLimit = 10
    @State private var isCreating = false
    
    var canSave: Bool {
        !puzzleTitle.isEmpty && !puzzleDescription.isEmpty && !puzzleContent.isEmpty && !solution.isEmpty
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
                        // Puzzle Info Section
                        VStack(alignment: .leading, spacing: AppSpacing.md) {
                            Text("Puzzle Information")
                                .font(AppFonts.headline)
                                .foregroundColor(Color.textPrimary)
                            
                            VStack(spacing: AppSpacing.md) {
                                // Title
                                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                                    Text("Title")
                                        .font(AppFonts.callout)
                                        .foregroundColor(Color.textSecondary)
                                    
                                    TextField("Enter puzzle title", text: $puzzleTitle)
                                        .textFieldStyle(CustomTextFieldStyle())
                                }
                                
                                // Description
                                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                                    Text("Description")
                                        .font(AppFonts.callout)
                                        .foregroundColor(Color.textSecondary)
                                    
                                    TextField("Enter puzzle description", text: $puzzleDescription)
                                        .textFieldStyle(CustomTextFieldStyle())
                                }
                                
                                // Type and Difficulty
                                HStack(spacing: AppSpacing.md) {
                                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                                        Text("Type")
                                            .font(AppFonts.callout)
                                            .foregroundColor(Color.textSecondary)
                                        
                                        Picker("Type", selection: $selectedType) {
                                            ForEach(PuzzleType.allCases, id: \.self) { type in
                                                Text(type.rawValue).tag(type)
                                            }
                                        }
                                        .pickerStyle(MenuPickerStyle())
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.cardBackground)
                                        .cornerRadius(AppCornerRadius.medium)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                                        Text("Difficulty")
                                            .font(AppFonts.callout)
                                            .foregroundColor(Color.textSecondary)
                                        
                                        Picker("Difficulty", selection: $selectedDifficulty) {
                                            ForEach(PuzzleDifficulty.allCases, id: \.self) { difficulty in
                                                Text(difficulty.rawValue).tag(difficulty)
                                            }
                                        }
                                        .pickerStyle(MenuPickerStyle())
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.cardBackground)
                                        .cornerRadius(AppCornerRadius.medium)
                                    }
                                }
                                
                                // Time Limit
                                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                                    Text("Time Limit (minutes)")
                                        .font(AppFonts.callout)
                                        .foregroundColor(Color.textSecondary)
                                    
                                    Stepper("\(timeLimit) minutes", value: $timeLimit, in: 1...60)
                                        .padding()
                                        .background(Color.cardBackground)
                                        .cornerRadius(AppCornerRadius.medium)
                                }
                            }
                        }
                        .padding(AppSpacing.lg)
                        .background(Color.cardBackground)
                        .cornerRadius(AppCornerRadius.large)
                        
                        // Puzzle Content Section
                        VStack(alignment: .leading, spacing: AppSpacing.md) {
                            Text("Puzzle Content")
                                .font(AppFonts.headline)
                                .foregroundColor(Color.textPrimary)
                            
                            VStack(spacing: AppSpacing.md) {
                                // Content
                                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                                    Text("Puzzle Content")
                                        .font(AppFonts.callout)
                                        .foregroundColor(Color.textSecondary)
                                    
                                    TextField("Enter the puzzle content or question", text: $puzzleContent)
                                        .textFieldStyle(CustomTextFieldStyle())
                                }
                                
                                // Solution
                                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                                    Text("Solution")
                                        .font(AppFonts.callout)
                                        .foregroundColor(Color.textSecondary)
                                    
                                    TextField("Enter the correct answer", text: $solution)
                                        .textFieldStyle(CustomTextFieldStyle())
                                }
                            }
                        }
                        .padding(AppSpacing.lg)
                        .background(Color.cardBackground)
                        .cornerRadius(AppCornerRadius.large)
                        
                        // Hints Section
                        VStack(alignment: .leading, spacing: AppSpacing.md) {
                            HStack {
                                Text("Hints (\(hints.filter { !$0.isEmpty }.count))")
                                    .font(AppFonts.headline)
                                    .foregroundColor(Color.textPrimary)
                                
                                Spacer()
                                
                                Button(action: addHint) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(Color.accentYellow)
                                }
                            }
                            
                            ForEach(Array(hints.enumerated()), id: \.offset) { index, hint in
                                HStack {
                                    TextField("Hint \(index + 1)", text: $hints[index])
                                        .textFieldStyle(CustomTextFieldStyle())
                                    
                                    if hints.count > 1 {
                                        Button(action: {
                                            removeHint(at: index)
                                        }) {
                                            Image(systemName: "minus.circle.fill")
                                                .foregroundColor(Color.red)
                                        }
                                    }
                                }
                            }
                            
                            Text("Hints help users solve the puzzle. Add up to \(selectedDifficulty.maxHints) hints.")
                                .font(AppFonts.caption)
                                .foregroundColor(Color.textSecondary)
                        }
                        .padding(AppSpacing.lg)
                        .background(Color.cardBackground)
                        .cornerRadius(AppCornerRadius.large)
                    }
                    .padding(.horizontal, AppSpacing.md)
                    .padding(.bottom, AppSpacing.xl)
                }
            }
            .navigationTitle("Create Puzzle")
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
                        savePuzzle()
                    }
                    .foregroundColor(canSave ? Color.accentYellow : Color.textSecondary)
                    .disabled(!canSave || isCreating)
                }
            }
        }
    }
    
    private func addHint() {
        if hints.count < selectedDifficulty.maxHints {
            hints.append("")
        }
    }
    
    private func removeHint(at index: Int) {
        if hints.count > 1 {
            hints.remove(at: index)
        }
    }
    
    private func savePuzzle() {
        guard canSave else { return }
        
        isCreating = true
        
        let content = PuzzleContent(mainContent: puzzleContent)
        let validHints = hints.filter { !$0.isEmpty }
        
        let newPuzzle = Puzzle(
            title: puzzleTitle,
            description: puzzleDescription,
            type: selectedType,
            difficulty: selectedDifficulty,
            content: content,
            solution: solution,
            hints: validHints,
            timeLimit: timeLimit,
            points: selectedDifficulty.basePoints,
            isUserGenerated: true,
            createdAt: Date(),
            createdBy: "User"
        )
        
        puzzleDataService.addUserPuzzle(newPuzzle)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isCreating = false
            dismiss()
        }
    }
}

// MARK: - Puzzle Detail View
struct PuzzleDetailView: View {
    let puzzle: Puzzle
    @StateObject private var puzzleDataService = PuzzleDataService()
    @State private var showingPuzzle = false
    @Environment(\.dismiss) private var dismiss
    
    var bestResult: PuzzleResult? {
        puzzleDataService.getBestResult(for: puzzle.id)
    }
    
    var allResults: [PuzzleResult] {
        puzzleDataService.getPuzzleResults(for: puzzle.id)
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
                                Text(puzzle.title)
                                    .font(AppFonts.largeTitle)
                                    .font(.system(size: 17, weight: .bold))
                                    .foregroundColor(Color.textPrimary)
                                
                                Text(puzzle.type.rawValue)
                                    .font(AppFonts.subheadline)
                                    .foregroundColor(Color(hex: puzzle.type.color))
                            }
                            
                            Spacer()
                            
                            Image(systemName: puzzle.type.icon)
                                .font(.system(size: 40))
                                .foregroundColor(Color(hex: puzzle.type.color))
                        }
                        
                        Text(puzzle.description)
                            .font(AppFonts.body)
                            .foregroundColor(Color.textSecondary)
                            .lineLimit(nil)
                    }
                    .padding(AppSpacing.lg)
                    .background(Color.cardBackground)
                    .cornerRadius(AppCornerRadius.large)
                    
                    // Puzzle Stats
                    VStack(alignment: .leading, spacing: AppSpacing.md) {
                        Text("Puzzle Information")
                            .font(AppFonts.headline)
                            .foregroundColor(Color.textPrimary)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: AppSpacing.md) {
                            StatCard(
                                icon: "target",
                                title: "Difficulty",
                                value: puzzle.difficulty.rawValue,
                                color: Color(hex: puzzle.difficulty.color)
                            )
                            
                            StatCard(
                                icon: "star.fill",
                                title: "Points",
                                value: "\(puzzle.points)",
                                color: Color.accentYellow
                            )
                            
                            StatCard(
                                icon: "clock.fill",
                                title: "Est. Time",
                                value: "\(puzzle.estimatedTime) min",
                                color: Color.primaryBlue
                            )
                            
                            StatCard(
                                icon: "lightbulb.fill",
                                title: "Hints",
                                value: "\(puzzle.hints.count)",
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
                                        Text(best.isSolved ? "Best Score" : "Last Attempt")
                                            .font(AppFonts.subheadline)
                                            .foregroundColor(Color.textSecondary)
                                        
                                        Spacer()
                                        
                                        Text(best.isSolved ? "\(best.score) pts" : "Not solved")
                                            .font(AppFonts.title2)
                                            .font(.system(size: 17, weight: .bold))
                                            .foregroundColor(best.isSolved ? Color(hex: best.performance.color) : Color.textSecondary)
                                    }
                                    
                                    if best.isSolved {
                                        HStack {
                                            Text(best.performance.emoji)
                                            Text(best.performance.rawValue)
                                                .font(AppFonts.callout)
                                                .foregroundColor(Color(hex: best.performance.color))
                                            
                                            Spacer()
                                            
                                            Text("Attempts: \(allResults.count)")
                                                .font(AppFonts.caption)
                                                .foregroundColor(Color.textSecondary)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(AppSpacing.lg)
                        .background(Color.cardBackground)
                        .cornerRadius(AppCornerRadius.large)
                    }
                    
                    // Start Puzzle Button
                    Button(action: {
                        showingPuzzle = true
                    }) {
                        HStack {
                            Image(systemName: "play.fill")
                            Text(bestResult?.isSolved == true ? "Solve Again" : "Start Puzzle")
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
        .fullScreenCover(isPresented: $showingPuzzle) {
            PuzzlePlayView(puzzle: puzzle, puzzleDataService: puzzleDataService)
        }
    }
}

// MARK: - Puzzle Play View
struct PuzzlePlayView: View {
    let puzzle: Puzzle
    let puzzleDataService: PuzzleDataService
    @Environment(\.dismiss) private var dismiss
    
    @State private var userAnswer = ""
    @State private var currentHintIndex = 0
    @State private var showingHint = false
    @State private var attempts = 0
    @State private var isCompleted = false
    @State private var isSolved = false
    @State private var showingResult = false
    @State private var startTime = Date()
    @State private var timeRemaining: Int = 0
    @State private var timer: Timer?
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.primaryBackground, Color.secondaryBackground],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            if showingResult {
                PuzzleResultView(
                    puzzle: puzzle,
                    isSolved: isSolved,
                    attempts: attempts,
                    hintsUsed: currentHintIndex,
                    timeSpent: abs(startTime.timeIntervalSinceNow),
                    onDismiss: { dismiss() }
                )
            } else {
                VStack(spacing: AppSpacing.xl) {
                    // Header
                    VStack(spacing: AppSpacing.md) {
                        HStack {
                            Button("Exit") {
                                stopTimer()
                                dismiss()
                            }
                            .foregroundColor(Color.textSecondary)
                            
                            Spacer()
                            
                            if let timeLimit = puzzle.timeLimit, timeLimit > 0 {
                                HStack(spacing: AppSpacing.xs) {
                                    Image(systemName: "timer")
                                        .foregroundColor(timeRemaining <= 60 ? Color.red : Color.accentYellow)
                                    
                                    Text(formatTime(timeRemaining))
                                        .font(AppFonts.callout)
                                        .font(.system(size: 17, weight: .medium))
                                        .foregroundColor(timeRemaining <= 60 ? Color.red : Color.accentYellow)
                                }
                            }
                        }
                        
                        // Puzzle Info
                        VStack(spacing: AppSpacing.sm) {
                            Text(puzzle.title)
                                .font(AppFonts.title2)
                                .font(.system(size: 17, weight: .bold))
                                .foregroundColor(Color.textPrimary)
                                .multilineTextAlignment(.center)
                            
                            HStack {
                                Image(systemName: puzzle.type.icon)
                                    .foregroundColor(Color(hex: puzzle.type.color))
                                
                                Text(puzzle.type.rawValue)
                                    .font(AppFonts.callout)
                                    .foregroundColor(Color.textSecondary)
                                
                                Spacer()
                                
                                Text("\(puzzle.points) pts")
                                    .font(AppFonts.callout)
                                    .font(.system(size: 17, weight: .medium))
                                    .foregroundColor(Color.accentYellow)
                            }
                        }
                    }
                    .padding(.horizontal, AppSpacing.lg)
                    
                    // Puzzle Content
                    ScrollView {
                        VStack(spacing: AppSpacing.lg) {
                            // Main Content
                            VStack(alignment: .leading, spacing: AppSpacing.md) {
                                Text("Puzzle")
                                    .font(AppFonts.headline)
                                    .foregroundColor(Color.textPrimary)
                                
                                Text(puzzle.content.mainContent)
                                    .font(AppFonts.body)
                                    .foregroundColor(Color.textPrimary)
                                    .lineLimit(nil)
                                    .padding()
                                    .background(Color.cardBackground)
                                    .cornerRadius(AppCornerRadius.medium)
                            }
                            
                            // Answer Input
                            VStack(alignment: .leading, spacing: AppSpacing.md) {
                                Text("Your Answer")
                                    .font(AppFonts.headline)
                                    .foregroundColor(Color.textPrimary)
                                
                                TextField("Enter your answer", text: $userAnswer)
                                    .textFieldStyle(CustomTextFieldStyle())
                                    .disabled(isCompleted)
                                
                                HStack {
                                    Button("Submit Answer") {
                                        submitAnswer()
                                    }
                                    .buttonStyle(PrimaryButtonStyle())
                                    .disabled(userAnswer.isEmpty || isCompleted)
                                    
                                    if !puzzle.hints.isEmpty && currentHintIndex < puzzle.hints.count {
                                        Button("Get Hint") {
                                            showHint()
                                        }
                                        .buttonStyle(SecondaryButtonStyle())
                                        .disabled(isCompleted)
                                    }
                                }
                            }
                            
                            // Attempts and Hints
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Attempts")
                                        .font(AppFonts.caption)
                                        .foregroundColor(Color.textSecondary)
                                    
                                    Text("\(attempts)")
                                        .font(AppFonts.title3)
                                        .font(.system(size: 17, weight: .bold))
                                        .foregroundColor(Color.textPrimary)
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing) {
                                    Text("Hints Used")
                                        .font(AppFonts.caption)
                                        .foregroundColor(Color.textSecondary)
                                    
                                    Text("\(currentHintIndex)/\(puzzle.hints.count)")
                                        .font(AppFonts.title3)
                                        .font(.system(size: 17, weight: .bold))
                                        .foregroundColor(Color.accentYellow)
                                }
                            }
                            .padding()
                            .background(Color.cardBackground)
                            .cornerRadius(AppCornerRadius.medium)
                        }
                        .padding(.horizontal, AppSpacing.lg)
                    }
                }
            }
        }
        .onAppear {
            setupTimer()
        }
        .onDisappear {
            stopTimer()
        }
        .alert("Hint", isPresented: $showingHint) {
            Button("OK") { }
        } message: {
            if currentHintIndex < puzzle.hints.count {
                Text(puzzle.hints[currentHintIndex])
            }
        }
    }
    
    private func setupTimer() {
        if let timeLimit = puzzle.timeLimit, timeLimit > 0 {
            timeRemaining = timeLimit * 60 // Convert minutes to seconds
            
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                if timeRemaining > 0 {
                    timeRemaining -= 1
                } else {
                    timeUp()
                }
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func timeUp() {
        stopTimer()
        isCompleted = true
        isSolved = false
        showResult()
    }
    
    private func submitAnswer() {
        attempts += 1
        
        let isCorrect = userAnswer.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) == 
                       puzzle.solution.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        if isCorrect {
            stopTimer()
            isCompleted = true
            isSolved = true
            showResult()
        } else {
            // Wrong answer - clear input and continue
            userAnswer = ""
            
            // Show feedback
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
        }
    }
    
    private func showHint() {
        if currentHintIndex < puzzle.hints.count {
            showingHint = true
            currentHintIndex += 1
        }
    }
    
    private func showResult() {
        let session = PuzzleSession(puzzleId: puzzle.id)
        _ = puzzleDataService.completeSession(session, puzzle: puzzle)
        showingResult = true
    }
    
    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
}

// MARK: - Puzzle Result View
struct PuzzleResultView: View {
    let puzzle: Puzzle
    let isSolved: Bool
    let attempts: Int
    let hintsUsed: Int
    let timeSpent: TimeInterval
    let onDismiss: () -> Void
    
    var score: Int {
        guard isSolved else { return 0 }
        
        let baseScore = puzzle.points
        let timeBonus = max(0, 50 - Int(timeSpent / 60))
        let hintPenalty = hintsUsed * 10
        let attemptPenalty = max(0, (attempts - 1) * 5)
        
        return max(10, baseScore + timeBonus - hintPenalty - attemptPenalty)
    }
    
    var body: some View {
        VStack(spacing: AppSpacing.xl) {
            // Result Icon
            VStack(spacing: AppSpacing.md) {
                Image(systemName: isSolved ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(isSolved ? Color.green : Color.red)
                
                Text(isSolved ? "Puzzle Solved!" : "Time's Up!")
                    .font(AppFonts.largeTitle)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(Color.textPrimary)
                
                if isSolved {
                    Text("Score: \(score) points")
                        .font(AppFonts.title2)
                        .foregroundColor(Color.accentYellow)
                }
            }
            
            // Stats
            VStack(spacing: AppSpacing.md) {
                HStack {
                    StatItem(title: "Attempts", value: "\(attempts)")
                    StatItem(title: "Hints Used", value: "\(hintsUsed)")
                    StatItem(title: "Time", value: formatTime(timeSpent))
                }
                
                if !isSolved {
                    VStack(spacing: AppSpacing.sm) {
                        Text("Solution")
                            .font(AppFonts.headline)
                            .foregroundColor(Color.textSecondary)
                        
                        Text(puzzle.solution)
                            .font(AppFonts.title3)
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(Color.textPrimary)
                            .padding()
                            .background(Color.cardBackground)
                            .cornerRadius(AppCornerRadius.medium)
                    }
                }
            }
            .padding(AppSpacing.lg)
            .background(Color.cardBackground)
            .cornerRadius(AppCornerRadius.large)
            
            // Actions
            VStack(spacing: AppSpacing.md) {
                Button("Try Again") {
                    // Restart puzzle logic would go here
                    onDismiss()
                }
                .buttonStyle(PrimaryButtonStyle())
                
                Button("Back to Puzzles") {
                    onDismiss()
                }
                .buttonStyle(SecondaryButtonStyle())
            }
        }
        .padding(AppSpacing.lg)
    }
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - Preview
#Preview {
    PuzzleView()
}
