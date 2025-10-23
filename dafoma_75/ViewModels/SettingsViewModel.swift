//
//  SettingsViewModel.swift
//  QuizVeNacional
//
//  Created by Вячеслав on 10/23/25.
//

import Foundation
import SwiftUI

// MARK: - Settings View Model
class SettingsViewModel: ObservableObject {
    @Published var showDeleteAccountAlert = false
    @Published var showResetDataAlert = false
    @Published var showAboutSheet = false
    @Published var isLoading = false
    @Published var successMessage: String?
    @Published var errorMessage: String?
    
    // User Preferences
    @AppStorage("soundEnabled") var soundEnabled = true
    @AppStorage("hapticFeedbackEnabled") var hapticFeedbackEnabled = true
    @AppStorage("autoAdvanceQuestions") var autoAdvanceQuestions = false
    @AppStorage("showHintsAutomatically") var showHintsAutomatically = true
    @AppStorage("difficultyPreference") var difficultyPreference = "mixed"
    @AppStorage("notificationsEnabled") var notificationsEnabled = true
    @AppStorage("dailyReminderTime") var dailyReminderTime = "18:00"
    
    // Statistics
    @AppStorage("totalQuizzesCompleted") private var totalQuizzesCompleted = 0
    @AppStorage("totalPuzzlesSolved") private var totalPuzzlesSolved = 0
    @AppStorage("totalTimeSpent") private var totalTimeSpent: Double = 0
    @AppStorage("userLevel") private var userLevel = 1
    @AppStorage("userXP") private var userXP = 0
    
    private let quizDataService: QuizDataService
    private let puzzleDataService: PuzzleDataService
    private let onboardingViewModel: OnboardingViewModel
    
    init(quizDataService: QuizDataService, puzzleDataService: PuzzleDataService, onboardingViewModel: OnboardingViewModel) {
        self.quizDataService = quizDataService
        self.puzzleDataService = puzzleDataService
        self.onboardingViewModel = onboardingViewModel
        updateStatistics()
    }
    
    // MARK: - Settings Sections
    var settingsSections: [SettingsSection] {
        return [
            SettingsSection(
                title: "Preferences",
                items: [
                    SettingsItem(
                        title: "Sound Effects",
                        subtitle: "Play sounds during quizzes and puzzles",
                        type: .toggle(binding: $soundEnabled),
                        icon: "speaker.wave.2.fill"
                    ),
                    SettingsItem(
                        title: "Haptic Feedback",
                        subtitle: "Feel vibrations for interactions",
                        type: .toggle(binding: $hapticFeedbackEnabled),
                        icon: "iphone.radiowaves.left.and.right"
                    ),
                    SettingsItem(
                        title: "Auto-Advance Questions",
                        subtitle: "Automatically move to next question",
                        type: .toggle(binding: $autoAdvanceQuestions),
                        icon: "forward.fill"
                    ),
                    SettingsItem(
                        title: "Show Hints Automatically",
                        subtitle: "Display hints when struggling",
                        type: .toggle(binding: $showHintsAutomatically),
                        icon: "lightbulb.fill"
                    )
                ]
            ),
            SettingsSection(
                title: "Statistics",
                items: [
                    SettingsItem(
                        title: "Quizzes Completed",
                        subtitle: "\(totalQuizzesCompleted) quizzes",
                        type: .info,
                        icon: "checkmark.circle.fill"
                    ),
                    SettingsItem(
                        title: "Puzzles Solved",
                        subtitle: "\(totalPuzzlesSolved) puzzles",
                        type: .info,
                        icon: "puzzlepiece.extension.fill"
                    ),
                    SettingsItem(
                        title: "Time Spent",
                        subtitle: formatTimeSpent(totalTimeSpent),
                        type: .info,
                        icon: "clock.fill"
                    ),
                    SettingsItem(
                        title: "Current Level",
                        subtitle: "Level \(userLevel) (\(userXP) XP)",
                        type: .info,
                        icon: "star.fill"
                    )
                ]
            ),
            SettingsSection(
                title: "Account",
                items: [
                    SettingsItem(
                        title: "Onboarding Status",
                        subtitle: onboardingInfo,
                        type: .info,
                        icon: "info.circle"
                    ),
                    SettingsItem(
                        title: "Reset Onboarding",
                        subtitle: "Show welcome screens again",
                        type: .action(action: resetOnboarding),
                        icon: "arrow.clockwise"
                    ),
                    SettingsItem(
                        title: "Clear Onboarding Data",
                        subtitle: "Completely remove all onboarding data",
                        type: .destructive(action: clearOnboardingData),
                        icon: "trash.circle"
                    ),
                    SettingsItem(
                        title: "Reset All Data",
                        subtitle: "Clear all progress and data",
                        type: .destructive(action: showResetDataConfirmation),
                        icon: "trash.fill"
                    )
                ]
            ),
            SettingsSection(
                title: "About",
                items: [
                    SettingsItem(
                        title: "About QuizVeNacional",
                        subtitle: "Version 1.0.0",
                        type: .navigation(action: showAbout),
                        icon: "info.circle.fill"
                    )
                ]
            )
        ]
    }
    
    // MARK: - Actions
    func updateStatistics() {
        totalQuizzesCompleted = quizDataService.getTotalQuizzesCompleted()
        totalPuzzlesSolved = puzzleDataService.getTotalPuzzlesSolved()
        totalTimeSpent = quizDataService.getTotalTimeSpent() + puzzleDataService.getTotalTimeSpent()
        
        // Calculate user level based on XP
        let newXP = (totalQuizzesCompleted * 10) + (totalPuzzlesSolved * 15)
        userXP = newXP
        userLevel = max(1, newXP / 100 + 1)
    }
    
    func resetOnboarding() {
        onboardingViewModel.resetOnboarding()
        successMessage = "Onboarding has been reset. You'll see the welcome screens on next app launch."
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.successMessage = nil
        }
    }
    
    func clearOnboardingData() {
        onboardingViewModel.clearOnboardingData()
        successMessage = "All onboarding data has been cleared completely."
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.successMessage = nil
        }
    }
    
    var onboardingInfo: String {
        let analytics = onboardingViewModel.onboardingAnalytics
        var info = "Status: \(analytics.completionStatus)"
        
        if let days = analytics.daysSinceCompletion {
            info += " (\(days) days ago)"
        }
        
        info += ", Version: \(analytics.version)"
        return info
    }
    
    func showDeleteAccountConfirmation() {
        showDeleteAccountAlert = true
    }
    
    func showResetDataConfirmation() {
        showResetDataAlert = true
    }
    
    func deleteAccount() {
        isLoading = true
        
        // Reset all data
        quizDataService.resetAllData()
        puzzleDataService.resetAllData()
        
        // Reset user preferences
        soundEnabled = true
        hapticFeedbackEnabled = true
        autoAdvanceQuestions = false
        showHintsAutomatically = true
        difficultyPreference = "mixed"
        notificationsEnabled = true
        dailyReminderTime = "18:00"
        
        // Reset statistics
        totalQuizzesCompleted = 0
        totalPuzzlesSolved = 0
        totalTimeSpent = 0
        userLevel = 1
        userXP = 0
        
        // Reset onboarding
        onboardingViewModel.resetOnboarding()
        
        isLoading = false
        successMessage = "Account deleted successfully. All data has been cleared."
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.successMessage = nil
        }
    }
    
    func resetAllData() {
        isLoading = true
        
        quizDataService.resetAllData()
        puzzleDataService.resetAllData()
        
        // Reset statistics
        totalQuizzesCompleted = 0
        totalPuzzlesSolved = 0
        totalTimeSpent = 0
        userLevel = 1
        userXP = 0
        
        updateStatistics()
        
        isLoading = false
        successMessage = "All data has been reset successfully."
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.successMessage = nil
        }
    }
    
    func showAbout() {
        showAboutSheet = true
    }
    
    // MARK: - Helper Methods
    private func formatTimeSpent(_ seconds: Double) -> String {
        let hours = Int(seconds) / 3600
        let minutes = (Int(seconds) % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

// MARK: - Settings Models
struct SettingsSection: Identifiable {
    let id = UUID()
    let title: String
    let items: [SettingsItem]
}

struct SettingsItem: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let type: SettingsItemType
    let icon: String
}

enum SettingsItemType {
    case toggle(binding: Binding<Bool>)
    case navigation(action: () -> Void)
    case action(action: () -> Void)
    case destructive(action: () -> Void)
    case info
}
