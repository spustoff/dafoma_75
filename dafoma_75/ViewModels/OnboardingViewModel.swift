//
//  OnboardingViewModel.swift
//  QuizVeNacional
//
//  Created by Вячеслав on 10/23/25.
//

import Foundation
import SwiftUI

// MARK: - Onboarding View Model
class OnboardingViewModel: ObservableObject {
    @Published var currentPage = 0
    @Published var showOnboarding = true
    @Published var isAnimating = false
    
    // AppStorage properties for persistent storage
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("onboardingVersion") private var onboardingVersion = 0
    @AppStorage("onboardingCompletedDate") private var onboardingCompletedDate: Double = 0
    @AppStorage("onboardingSkipped") private var onboardingSkipped = false
    @AppStorage("onboardingCurrentPage") private var savedCurrentPage = 0
    
    private let currentOnboardingVersion = 1
    
    init() {
        // Check if user needs to see onboarding
        checkOnboardingStatus()
        
        // Restore saved page if onboarding was not completed
        if showOnboarding && savedCurrentPage > 0 {
            currentPage = min(savedCurrentPage, onboardingPages.count - 1)
        }
    }
    
    private func checkOnboardingStatus() {
        let shouldShowOnboarding = !hasCompletedOnboarding || onboardingVersion < currentOnboardingVersion
        
        // Additional check: if it's been more than 30 days since completion, show onboarding again (optional)
        if hasCompletedOnboarding && onboardingCompletedDate > 0 {
            let completedDate = Date(timeIntervalSince1970: onboardingCompletedDate)
            let daysSinceCompletion = Calendar.current.dateComponents([.day], from: completedDate, to: Date()).day ?? 0
            
            // Uncomment the line below if you want to show onboarding again after 30 days
            // shouldShowOnboarding = shouldShowOnboarding || daysSinceCompletion > 30
            
            // Use the variable to avoid warning (can be removed if the feature above is enabled)
            _ = daysSinceCompletion
        }
        
        showOnboarding = shouldShowOnboarding
    }
    
    // MARK: - Onboarding Pages
    let onboardingPages: [OnboardingPage] = [
        OnboardingPage(
            title: "Welcome to QuizVeNacional",
            description: "Discover futuristic quizzes and mind-bending puzzles that will challenge your knowledge and creativity.",
            imageName: "brain.head.profile",
            backgroundColor: Color.primaryBackground
        ),
        OnboardingPage(
            title: "Explore Diverse Categories",
            description: "From technology and science to art and literature, explore quizzes across multiple fascinating categories.",
            imageName: "grid.circle.fill",
            backgroundColor: Color.secondaryBackground
        ),
        OnboardingPage(
            title: "Challenge Your Mind",
            description: "Solve complex puzzles, crack codes, and test your logic with our innovative puzzle collection.",
            imageName: "puzzlepiece.extension.fill",
            backgroundColor: Color.primaryBackground
        ),
        OnboardingPage(
            title: "Create & Share",
            description: "Design your own quizzes and puzzles to challenge friends and the community.",
            imageName: "person.crop.circle.badge.plus",
            backgroundColor: Color.secondaryBackground
        ),
        OnboardingPage(
            title: "Track Your Progress",
            description: "Monitor your performance, earn achievements, and see how you improve over time.",
            imageName: "chart.line.uptrend.xyaxis",
            backgroundColor: Color.primaryBackground
        )
    ]
    
    // MARK: - Navigation
    func nextPage() {
        guard !isAnimating else { return }
        
        if currentPage < onboardingPages.count - 1 {
            isAnimating = true
            withAnimation(.easeInOut(duration: 0.5)) {
                currentPage += 1
            }
            
            // Save current page progress
            savedCurrentPage = currentPage
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.isAnimating = false
            }
        } else {
            completeOnboarding()
        }
    }
    
    func previousPage() {
        guard !isAnimating && currentPage > 0 else { return }
        
        isAnimating = true
        withAnimation(.easeInOut(duration: 0.5)) {
            currentPage -= 1
        }
        
        // Save current page progress
        savedCurrentPage = currentPage
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.isAnimating = false
        }
    }
    
    func skipOnboarding() {
        onboardingSkipped = true
        completeOnboarding()
    }
    
    func completeOnboarding() {
        guard !isAnimating else { return }
        
        isAnimating = true
        withAnimation(.easeInOut(duration: 0.5)) {
            hasCompletedOnboarding = true
            onboardingVersion = currentOnboardingVersion
            onboardingCompletedDate = Date().timeIntervalSince1970
            savedCurrentPage = 0 // Reset saved page
            showOnboarding = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.isAnimating = false
        }
    }
    
    func goToPage(_ pageIndex: Int) {
        guard pageIndex >= 0 && pageIndex < onboardingPages.count && !isAnimating else { return }
        
        isAnimating = true
        withAnimation(.easeInOut(duration: 0.5)) {
            currentPage = pageIndex
        }
        
        savedCurrentPage = pageIndex
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.isAnimating = false
        }
    }
    
    // MARK: - Computed Properties
    var isLastPage: Bool {
        return currentPage == onboardingPages.count - 1
    }
    
    var isFirstPage: Bool {
        return currentPage == 0
    }
    
    var progress: Double {
        return Double(currentPage + 1) / Double(onboardingPages.count)
    }
    
    var currentPageData: OnboardingPage {
        return onboardingPages[currentPage]
    }
    
    // MARK: - AppStorage Management
    func resetOnboarding() {
        hasCompletedOnboarding = false
        onboardingVersion = 0
        onboardingCompletedDate = 0
        onboardingSkipped = false
        savedCurrentPage = 0
        currentPage = 0
        showOnboarding = true
        isAnimating = false
    }
    
    func clearOnboardingData() {
        // Completely clear all onboarding related data
        UserDefaults.standard.removeObject(forKey: "hasCompletedOnboarding")
        UserDefaults.standard.removeObject(forKey: "onboardingVersion")
        UserDefaults.standard.removeObject(forKey: "onboardingCompletedDate")
        UserDefaults.standard.removeObject(forKey: "onboardingSkipped")
        UserDefaults.standard.removeObject(forKey: "onboardingCurrentPage")
        
        // Reset local state
        currentPage = 0
        showOnboarding = true
        isAnimating = false
    }
    
    // MARK: - Onboarding Analytics
    var onboardingAnalytics: OnboardingAnalytics {
        return OnboardingAnalytics(
            hasCompleted: hasCompletedOnboarding,
            wasSkipped: onboardingSkipped,
            completedDate: onboardingCompletedDate > 0 ? Date(timeIntervalSince1970: onboardingCompletedDate) : nil,
            version: onboardingVersion,
            lastViewedPage: savedCurrentPage
        )
    }
    
    func markPageViewed(_ pageIndex: Int) {
        // Track which pages user has viewed (for analytics)
        let key = "onboardingPageViewed_\(pageIndex)"
        UserDefaults.standard.set(true, forKey: key)
    }
    
    func hasViewedPage(_ pageIndex: Int) -> Bool {
        let key = "onboardingPageViewed_\(pageIndex)"
        return UserDefaults.standard.bool(forKey: key)
    }
}

// MARK: - Onboarding Page Model
struct OnboardingPage: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let imageName: String
    let backgroundColor: Color
}

// MARK: - Onboarding Analytics Model
struct OnboardingAnalytics {
    let hasCompleted: Bool
    let wasSkipped: Bool
    let completedDate: Date?
    let version: Int
    let lastViewedPage: Int
    
    var completionStatus: String {
        if hasCompleted {
            return wasSkipped ? "Skipped" : "Completed"
        } else {
            return "In Progress"
        }
    }
    
    var daysSinceCompletion: Int? {
        guard let completedDate = completedDate else { return nil }
        return Calendar.current.dateComponents([.day], from: completedDate, to: Date()).day
    }
}
