//
//  SettingsView.swift
//  QuizVeNacional
//
//  Created by Вячеслав on 10/23/25.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel: SettingsViewModel
    
    init() {
        self._viewModel = StateObject(wrappedValue: SettingsViewModel(
            quizDataService: QuizDataService(),
            puzzleDataService: PuzzleDataService(),
            onboardingViewModel: OnboardingViewModel()
        ))
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
                
                ScrollView {
                    LazyVStack(spacing: AppSpacing.lg) {
                        ForEach(viewModel.settingsSections) { section in
                            SettingsSectionView(section: section)
                        }
                    }
                    .padding(.horizontal, AppSpacing.md)
                    .padding(.top, AppSpacing.md)
                    .padding(.bottom, AppSpacing.xl)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .overlay(
                // Success/Error messages
                VStack {
                    if let message = viewModel.successMessage {
                        MessageBanner(message: message, type: .success)
                            .transition(.move(edge: .top).combined(with: .opacity))
                    } else if let message = viewModel.errorMessage {
                        MessageBanner(message: message, type: .error)
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    
                    Spacer()
                }
                .animation(.easeInOut(duration: 0.3), value: viewModel.successMessage)
                .animation(.easeInOut(duration: 0.3), value: viewModel.errorMessage)
            )
        }
        .alert("Delete Account", isPresented: $viewModel.showDeleteAccountAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                viewModel.deleteAccount()
            }
        } message: {
            Text("This will permanently delete all your data and cannot be undone.")
        }
        .alert("Reset All Data", isPresented: $viewModel.showResetDataAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                viewModel.resetAllData()
            }
        } message: {
            Text("This will clear all your quiz and puzzle progress.")
        }
        .sheet(isPresented: $viewModel.showAboutSheet) {
            AboutView()
        }
    }
}

// MARK: - Settings Section View
struct SettingsSectionView: View {
    let section: SettingsSection
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            // Section header
            Text(section.title)
                .font(AppFonts.headline)
                .foregroundColor(Color.textPrimary)
                .padding(.horizontal, AppSpacing.md)
            
            // Section items
            VStack(spacing: 0) {
                ForEach(Array(section.items.enumerated()), id: \.element.id) { index, item in
                    SettingsItemView(item: item)
                    
                    if index < section.items.count - 1 {
                        Divider()
                            .background(Color.textSecondary.opacity(0.2))
                            .padding(.leading, 60)
                    }
                }
            }
            .background(Color.cardBackground)
            .cornerRadius(AppCornerRadius.medium)
        }
    }
}

// MARK: - Settings Item View
struct SettingsItemView: View {
    let item: SettingsItem
    
    var body: some View {
        HStack(spacing: AppSpacing.md) {
            // Icon
            Image(systemName: item.icon)
                .font(.title3)
                .foregroundColor(iconColor)
                .frame(width: 24, height: 24)
            
            // Content
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(item.title)
                    .font(AppFonts.body)
                    .foregroundColor(titleColor)
                
                if !item.subtitle.isEmpty {
                    Text(item.subtitle)
                        .font(AppFonts.caption)
                        .foregroundColor(Color.textSecondary)
                        .lineLimit(2)
                }
            }
            
            Spacer()
            
            // Control
            switch item.type {
            case .toggle(let binding):
                Toggle("", isOn: binding)
                    .toggleStyle(SwitchToggleStyle(tint: Color.accentYellow))
                
            case .navigation(_), .action(_):
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(Color.textSecondary)
                
            case .destructive(_):
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(Color.red)
                
            case .info:
                EmptyView()
            }
        }
        .padding(.horizontal, AppSpacing.md)
        .padding(.vertical, AppSpacing.sm)
        .contentShape(Rectangle())
        .onTapGesture {
            handleTap()
        }
    }
    
    private var iconColor: Color {
        switch item.type {
        case .destructive(_):
            return Color.red
        default:
            return Color.accentYellow
        }
    }
    
    private var titleColor: Color {
        switch item.type {
        case .destructive(_):
            return Color.red
        default:
            return Color.textPrimary
        }
    }
    
    private func handleTap() {
        switch item.type {
        case .navigation(let action), .action(let action), .destructive(let action):
            action()
        case .toggle(_), .info:
            break
        }
    }
}

// MARK: - Message Banner
struct MessageBanner: View {
    let message: String
    let type: MessageType
    
    enum MessageType {
        case success
        case error
        
        var color: Color {
            switch self {
            case .success: return Color.green
            case .error: return Color.red
            }
        }
        
        var icon: String {
            switch self {
            case .success: return "checkmark.circle.fill"
            case .error: return "xmark.circle.fill"
            }
        }
    }
    
    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            Image(systemName: type.icon)
                .foregroundColor(type.color)
            
            Text(message)
                .font(AppFonts.callout)
                .foregroundColor(Color.textPrimary)
                .lineLimit(2)
            
            Spacer()
        }
        .padding(AppSpacing.md)
        .background(Color.cardBackground)
        .cornerRadius(AppCornerRadius.medium)
        .overlay(
            RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                .stroke(type.color, lineWidth: 1)
        )
        .padding(.horizontal, AppSpacing.md)
        .padding(.top, AppSpacing.sm)
    }
}

// MARK: - About View
struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    
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
                    VStack(spacing: AppSpacing.xl) {
                        // App icon and name
                        VStack(spacing: AppSpacing.md) {
                            ZStack {
                                Circle()
                                    .fill(Color.accentYellow)
                                    .frame(width: 100, height: 100)
                                
                                Image(systemName: "brain.head.profile")
                                    .font(.system(size: 50))
                                    .foregroundColor(Color.primaryBackground)
                            }
                            
                            Text("QuizVeNacional")
                                .font(AppFonts.largeTitle)
                                .font(.system(size: 17, weight: .bold))
                                .foregroundColor(Color.textPrimary)
                            
                            Text("Version 1.0.0")
                                .font(AppFonts.callout)
                                .foregroundColor(Color.textSecondary)
                        }
                        
                        // Description
                        VStack(alignment: .leading, spacing: AppSpacing.md) {
                            Text("About QuizVeNacional")
                                .font(AppFonts.headline)
                                .foregroundColor(Color.textPrimary)
                            
                            Text("QuizVeNacional is an engaging and interactive entertainment app designed to challenge users with futuristic-themed quizzes and puzzles. The app offers an expansive range of topics, ensuring unique and stimulating user experiences.")
                                .font(AppFonts.body)
                                .foregroundColor(Color.textSecondary)
                                .lineLimit(nil)
                        }
                        .padding(AppSpacing.lg)
                        .background(Color.cardBackground)
                        .cornerRadius(AppCornerRadius.medium)
                        
                        // Features
                        VStack(alignment: .leading, spacing: AppSpacing.md) {
                            Text("Features")
                                .font(AppFonts.headline)
                                .foregroundColor(Color.textPrimary)
                            
                            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                                FeatureRow(icon: "questionmark.circle.fill", title: "Interactive Quizzes", description: "Multiple categories and difficulty levels")
                                FeatureRow(icon: "puzzlepiece.extension.fill", title: "Mind-Bending Puzzles", description: "Logic, word, and pattern puzzles")
                                FeatureRow(icon: "person.crop.circle.badge.plus", title: "User-Generated Content", description: "Create and share your own quizzes")
                                FeatureRow(icon: "chart.line.uptrend.xyaxis", title: "Progress Tracking", description: "Monitor your performance over time")
                                FeatureRow(icon: "sparkles", title: "Futuristic Design", description: "Modern UI following Apple guidelines")
                            }
                        }
                        .padding(AppSpacing.lg)
                        .background(Color.cardBackground)
                        .cornerRadius(AppCornerRadius.medium)
                        
                        // Developer info
                        VStack(alignment: .leading, spacing: AppSpacing.md) {
                            Text("Developer")
                                .font(AppFonts.headline)
                                .foregroundColor(Color.textPrimary)
                            
                            Text("Created with ❤️ using SwiftUI")
                                .font(AppFonts.body)
                                .foregroundColor(Color.textSecondary)
                        }
                        .padding(AppSpacing.lg)
                        .background(Color.cardBackground)
                        .cornerRadius(AppCornerRadius.medium)
                    }
                    .padding(.horizontal, AppSpacing.md)
                    .padding(.vertical, AppSpacing.lg)
                }
            }
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Color.accentYellow)
                }
            }
        }
    }
}

// MARK: - Feature Row
struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: AppSpacing.md) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(Color.accentYellow)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(title)
                    .font(AppFonts.callout)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(Color.textPrimary)
                
                Text(description)
                    .font(AppFonts.caption)
                    .foregroundColor(Color.textSecondary)
            }
            
            Spacer()
        }
    }
}

// MARK: - Preview
#Preview {
    SettingsView()
}
