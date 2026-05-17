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
                    
                    VStack(spacing: AppSpacing.xxs) {
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
                    
                    // Apple sign in placeholder
                    PrimaryButton(title: "Continue with Apple", icon: "apple.logo", style: .dark) {
                        // TODO: Implement Sign in with Apple
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
                SignInView()
            }
            .navigationDestination(isPresented: $showSignUp) {
                SignUpView()
            }
        }
    }
}
