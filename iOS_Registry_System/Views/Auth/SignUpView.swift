//
//  SignUpView.swift
//  iOS_Registry_System
//
//  Auth sign up view
//

import SwiftUI

struct SignUpView: View {
    var onSwitchToSignIn: (() -> Void)? = nil
    
    @State private var appState = AppState.shared
    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showPassword = false
    @State private var agreedToTerms = false
    
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack(alignment: .topLeading) {
            // Main scrollable content
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    
                    // MARK: - Hero Header
                    heroHeader
                    
                    // MARK: - Form Content
                    VStack(spacing: AppSpacing.lg) {
                        
                        // Full Name Field
                        authTextField(
                            icon: "person",
                            placeholder: "Full name",
                            text: $fullName
                        )
                        
                        // Email Field
                        authTextField(
                            icon: "envelope",
                            placeholder: "Email address",
                            text: $email,
                            keyboardType: .emailAddress
                        )
                        
                        // Password Field
                        authSecureField(
                            icon: "lock",
                            placeholder: "Password",
                            text: $password,
                            showPassword: $showPassword
                        )
                        
                        // Terms & Privacy
                        HStack(spacing: AppSpacing.xs) {
                            Button {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    agreedToTerms.toggle()
                                }
                            } label: {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                                        .fill(agreedToTerms ? AppColors.accentRed : Color.clear)
                                        .frame(width: 22, height: 22)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                                .strokeBorder(
                                                    agreedToTerms ? AppColors.accentRed : Color(hex: "C8C8C8"),
                                                    lineWidth: 1.5
                                                )
                                        )
                                    
                                    if agreedToTerms {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundStyle(.white)
                                    }
                                }
                            }
                            
                            HStack(spacing: 0) {
                                Text("I agree to the ")
                                    .font(AppTypography.subheadline)
                                    .foregroundStyle(AppColors.primaryDark)
                                
                                Button("Terms") {
                                    // TODO: Show terms
                                }
                                .font(AppTypography.subheadlineMedium)
                                .fontWeight(.bold)
                                .foregroundStyle(AppColors.primaryDark)
                                
                                Text(" & ")
                                    .font(AppTypography.subheadline)
                                    .foregroundStyle(AppColors.primaryDark)
                                
                                Button("Privacy") {
                                    // TODO: Show privacy
                                }
                                .font(AppTypography.subheadlineMedium)
                                .fontWeight(.bold)
                                .foregroundStyle(AppColors.primaryDark)
                                
                                Text(".")
                                    .font(AppTypography.subheadline)
                                    .foregroundStyle(AppColors.primaryDark)
                            }
                        }
                        .padding(.top, -AppSpacing.xxs)
                        
                        // Error Message
                        if let errorMessage {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .font(AppTypography.caption1)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        // Create Account Button
                        PrimaryButton(title: "Create account", style: .accent, isLoading: isLoading) {
                            Task {
                                await signUp()
                            }
                        }
                        .disabled(isLoading || email.isEmpty || password.isEmpty || fullName.isEmpty)
                        
                    }
                    .padding(.horizontal, AppSpacing.screenHorizontal + 4)
                    .padding(.top, AppSpacing.xl)
                    
                    Spacer(minLength: AppSpacing.huge)
                    
                    // Bottom Link
                    HStack(spacing: AppSpacing.xxs) {
                        Text("Already a member?")
                            .font(AppTypography.subheadline)
                            .foregroundStyle(AppColors.secondaryGray)
                        Button {
                            if let onSwitchToSignIn {
                                onSwitchToSignIn()
                            } else {
                                dismiss()
                            }
                        } label: {
                            Text("Sign in")
                                .font(AppTypography.subheadlineMedium)
                                .fontWeight(.bold)
                                .foregroundStyle(AppColors.primaryDark)
                        }
                    }
                    .padding(.vertical, AppSpacing.xl)
                    
                }
            }
            
            // Floating back button over the hero image
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(AppColors.primaryDark)
                    .frame(width: 40, height: 40)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
            }
            .padding(.leading, AppSpacing.screenHorizontal)
            .padding(.top, 8)
        }
        .background(Color.white.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
    }
    
    // MARK: - Hero Header
    
    private var heroHeader: some View {
        ZStack(alignment: .bottomLeading) {
            // Hero Image — edge-to-edge, behind status bar
            Image("AuthHeroImage")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 300)
                .frame(maxWidth: .infinity)
                .clipped()
                .overlay(
                    LinearGradient(
                        colors: [
                            .clear,
                            .clear,
                            Color.white.opacity(0.2),
                            Color.white.opacity(0.7),
                            Color.white
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            
            // Text Overlay
            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                Text("WILLIAMS SONOMA · SMART")
                    .font(.system(size: 11, weight: .medium))
                    .kerning(2)
                    .foregroundStyle(AppColors.primaryDark.opacity(0.6))
                
                Text("REGISTRY")
                    .font(.system(size: 11, weight: .medium))
                    .kerning(2)
                    .foregroundStyle(AppColors.primaryDark.opacity(0.6))
                
                Text("Begin your\ncelebration.")
                    .font(.system(size: 38, weight: .bold, design: .serif))
                    .foregroundStyle(AppColors.primaryDark)
                    .lineSpacing(2)
                    .padding(.top, 4)
                
                Text("Host registries. Gift to friends.")
                    .font(AppTypography.subheadline)
                    .foregroundStyle(AppColors.secondaryGray)
            }
            .padding(.horizontal, AppSpacing.screenHorizontal + 4)
            .padding(.bottom, AppSpacing.md)
        }
    }
    
    // MARK: - Sign Up Logic
    
    private func signUp() async {
        isLoading = true
        errorMessage = nil
        do {
            try await AuthService.shared.signUp(email: email, password: password, displayName: fullName)
            
            // Auto sign-in after successful sign up!
            try await AuthService.shared.signIn(email: email, password: password)
            
            // Update app state
            appState.isAuthenticated = AuthService.shared.isAuthenticated
            appState.mfaRequired = AuthService.shared.mfaRequired
            appState.currentUser = AuthService.shared.currentUser
        } catch {
            print("❌ Signup error details: \(error)")
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

}

#Preview {
    NavigationStack {
        SignUpView()
    }
}
