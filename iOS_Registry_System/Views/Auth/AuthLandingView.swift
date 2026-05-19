//
//  AuthLandingView.swift
//  iOS_Registry_System
//
//  Auth landing / welcome screen — starter
//

import SwiftUI

// MARK: - Auth Landing View

struct AuthLandingView: View {
    
    @State private var appState = AppState.shared
    @State private var showSignIn = false
    @State private var showSignUp = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: AppSpacing.xxl) {
                Spacer()
                
                // MARK: Logo Area
                
                VStack(spacing: AppSpacing.md) {
                    Image(systemName: "gift.fill")
                        .font(.system(size: 56))
                        .foregroundStyle(AppColors.accentRed)
                    
                    VStack(spacing: AppSpacing.xs) {
                        // Williams Sonoma branding
                        Text("WILLIAMS SONOMA")
                            .font(.system(size: 12, weight: .medium))
                            .kerning(3)
                            .foregroundStyle(AppColors.secondaryGray)
                        
                        Text(AppConstants.appName)
                            .font(AppTypography.largeTitle)
                            .foregroundStyle(AppColors.primaryText)
                        
                        Text(AppConstants.tagline)
                            .font(AppTypography.premiumSubtitle)
                            .foregroundStyle(AppColors.secondaryGray)
                    }
                }
                
                Spacer()
                
                // MARK: CTAs
                
                VStack(spacing: AppSpacing.sm) {
                    PrimaryButton(title: "Get Started", style: .accent) {
                        showSignUp = true
                    }
                    
                    PrimaryButton(title: "I Already Have an Account", style: .outline) {
                        showSignIn = true
                    }
                }
                .padding(.horizontal, AppSpacing.screenHorizontal)
                
                // MARK: Terms
                
                Text("By continuing, you agree to our Terms & Privacy Policy")
                    .font(AppTypography.caption1)
                    .foregroundStyle(AppColors.secondaryGray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppSpacing.xxl)
                    .padding(.bottom, AppSpacing.lg)
            }
            .appBackground()
            .navigationDestination(isPresented: $showSignIn) {
                SignInView(onSwitchToSignUp: {
                    showSignIn = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                        showSignUp = true
                    }
                })
            }
            .navigationDestination(isPresented: $showSignUp) {
                SignUpView(onSwitchToSignIn: {
                    showSignUp = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                        showSignIn = true
                    }
                })
            }
        }
    }
}
