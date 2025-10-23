//
//  OnboardingView.swift
//  QuizVeNacional
//
//  Created by Вячеслав on 10/23/25.
//

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var viewModel: OnboardingViewModel
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color.primaryBackground, Color.secondaryBackground],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Progress bar
                ProgressView(value: viewModel.progress)
                    .progressViewStyle(LinearProgressViewStyle(tint: Color.accentYellow))
                    .scaleEffect(x: 1, y: 2, anchor: .center)
                    .padding(.horizontal, AppSpacing.lg)
                    .padding(.top, AppSpacing.sm)
                
                // Main content
                TabView(selection: $viewModel.currentPage) {
                    ForEach(0..<viewModel.onboardingPages.count, id: \.self) { index in
                        OnboardingPageView(page: viewModel.onboardingPages[index])
                            .tag(index)
                            .onAppear {
                                // Mark page as viewed for analytics
                                viewModel.markPageViewed(index)
                            }
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.5), value: viewModel.currentPage)
                .disabled(viewModel.isAnimating)
                
                // Navigation buttons
                HStack(spacing: AppSpacing.lg) {
                    // Skip/Back button
                    Button(action: {
                        if viewModel.isFirstPage {
                            viewModel.skipOnboarding()
                        } else {
                            viewModel.previousPage()
                        }
                    }) {
                        Text(viewModel.isFirstPage ? "Skip" : "Back")
                            .font(AppFonts.callout)
                            .foregroundColor(Color.textSecondary)
                            .frame(width: 80, height: 44)
                    }
                    .disabled(viewModel.isAnimating)
                    
                    Spacer()
                    
                    // Page indicators
                    HStack(spacing: AppSpacing.sm) {
                        ForEach(0..<viewModel.onboardingPages.count, id: \.self) { index in
                            Button(action: {
                                viewModel.goToPage(index)
                            }) {
                                Circle()
                                    .fill(index == viewModel.currentPage ? Color.accentYellow : Color.textSecondary.opacity(0.3))
                                    .frame(width: 8, height: 8)
                                    .scaleEffect(index == viewModel.currentPage ? 1.2 : 1.0)
                                    .animation(.easeInOut(duration: 0.3), value: viewModel.currentPage)
                            }
                            .disabled(viewModel.isAnimating)
                        }
                    }
                    
                    Spacer()
                    
                    // Next/Get Started button
                    Button(action: {
                        viewModel.nextPage()
                    }) {
                        Text(viewModel.isLastPage ? "Get Started" : "Next")
                            .font(AppFonts.callout)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(viewModel.isLastPage ? Color.primaryBackground : Color.accentYellow)
                            .frame(width: 80, height: 44)
                            .background(
                                RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                                    .fill(viewModel.isLastPage ? Color.accentYellow : Color.clear)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                                    .stroke(Color.accentYellow, lineWidth: viewModel.isLastPage ? 0 : 1)
                            )
                    }
                    .disabled(viewModel.isAnimating)
                }
                .padding(.horizontal, AppSpacing.lg)
                .padding(.bottom, AppSpacing.xl)
            }
        }
        .onAppear {
            setupPageControlAppearance()
        }
    }
    
    private func setupPageControlAppearance() {
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor(Color.accentYellow)
        UIPageControl.appearance().pageIndicatorTintColor = UIColor(Color.textSecondary.opacity(0.3))
    }
}

// MARK: - Onboarding Page View
struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: AppSpacing.xl) {
            Spacer()
            
            // Icon
            ZStack {
                Circle()
                    .fill(Color.cardBackground)
                    .frame(width: 120, height: 120)
                
                Image(systemName: page.imageName)
                    .font(.system(size: 50, weight: .light))
                    .foregroundColor(Color.accentYellow)
            }
            .padding(.top, AppSpacing.xxl)
            
            // Content
            VStack(spacing: AppSpacing.lg) {
                Text(page.title)
                    .font(AppFonts.largeTitle)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(Color.textPrimary)
                    .multilineTextAlignment(.center)
                
                Text(page.description)
                    .font(AppFonts.body)
                    .foregroundColor(Color.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .padding(.horizontal, AppSpacing.lg)
            }
            
            Spacer()
            Spacer()
        }
        .padding(.horizontal, AppSpacing.lg)
    }
}

// MARK: - Preview
#Preview {
    OnboardingView()
}
