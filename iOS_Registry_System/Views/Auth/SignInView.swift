//
//  SignInView.swift
//  iOS_Registry_System
//
//  Auth sign in view
//

import SwiftUI

struct SignInView: View {
    var onSwitchToSignUp: (() -> Void)? = nil
    
    @State private var appState = AppState.shared
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showPassword = false
    
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
                        
                        // Forgot Password
                        HStack {
                            Spacer()
                            Button("Forgot password?") {
                                // TODO: Implement forgot password
                            }
                            .font(AppTypography.subheadline)
                            .foregroundStyle(AppColors.secondaryGray)
                        }
                        .padding(.top, -AppSpacing.xs)
                        
                        // Error Message
                        if let errorMessage {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .font(AppTypography.caption1)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        // Sign In Button
                        PrimaryButton(title: "Sign in", style: .accent, isLoading: isLoading) {
                            Task {
                                await signIn()
                            }
                        }
                        .disabled(isLoading || email.isEmpty || password.isEmpty)
                        
                    }
                    .padding(.horizontal, AppSpacing.screenHorizontal + 4)
                    .padding(.top, AppSpacing.xl)
                    
                    Spacer(minLength: AppSpacing.huge)
                    
                    // Bottom Link
                    HStack(spacing: AppSpacing.xxs) {
                        Text("New here?")
                            .font(AppTypography.subheadline)
                            .foregroundStyle(AppColors.secondaryGray)
                        Button {
                            if let onSwitchToSignUp {
                                onSwitchToSignUp()
                            } else {
                                dismiss()
                            }
                        } label: {
                            Text("Create an account")
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
                
                Text("Welcome back.")
                    .font(.system(size: 38, weight: .bold, design: .serif))
                    .foregroundStyle(AppColors.primaryDark)
                    .padding(.top, 4)
                
                Text("Sign in to continue your celebrations.")
                    .font(AppTypography.subheadline)
                    .foregroundStyle(AppColors.secondaryGray)
            }
            .padding(.horizontal, AppSpacing.screenHorizontal + 4)
            .padding(.bottom, AppSpacing.md)
        }
    }
    
    // MARK: - Sign In Logic
    
    private func signIn() async {
        isLoading = true
        errorMessage = nil
        do {
            try await AuthService.shared.signIn(email: email, password: password)
            appState.isAuthenticated = AuthService.shared.isAuthenticated
            appState.mfaRequired = AuthService.shared.mfaRequired
            appState.currentUser = AuthService.shared.currentUser
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}

// MARK: - Shared Auth UI Components

/// Styled text field with leading icon for auth screens
func authTextField(
    icon: String,
    placeholder: String,
    text: Binding<String>,
    keyboardType: UIKeyboardType = .default
) -> some View {
    HStack(spacing: AppSpacing.sm) {
        Image(systemName: icon)
            .font(.system(size: 16))
            .foregroundStyle(AppColors.secondaryGray)
            .frame(width: 24)
        
        TextField(placeholder, text: text)
            .font(AppTypography.body)
            .keyboardType(keyboardType)
            .autocapitalization(.none)
            .autocorrectionDisabled()
    }
    .padding(.horizontal, AppSpacing.md)
    .frame(height: 54)
    .background(Color.white)
    .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.sm, style: .continuous))
    .overlay(
        RoundedRectangle(cornerRadius: AppCornerRadius.sm, style: .continuous)
            .strokeBorder(Color(hex: "E0E0E0"), lineWidth: 1)
    )
}

/// Styled secure field with leading icon and eye toggle for auth screens
func authSecureField(
    icon: String,
    placeholder: String,
    text: Binding<String>,
    showPassword: Binding<Bool>
) -> some View {
    HStack(spacing: AppSpacing.sm) {
        Image(systemName: icon)
            .font(.system(size: 16))
            .foregroundStyle(AppColors.secondaryGray)
            .frame(width: 24)
        
        Group {
            if showPassword.wrappedValue {
                TextField(placeholder, text: text)
            } else {
                SecureField(placeholder, text: text)
            }
        }
        .font(AppTypography.body)
        .autocapitalization(.none)
        .autocorrectionDisabled()
        
        Button {
            showPassword.wrappedValue.toggle()
        } label: {
            Image(systemName: showPassword.wrappedValue ? "eye" : "eye.slash")
                .font(.system(size: 16))
                .foregroundStyle(AppColors.secondaryGray)
        }
    }
    .padding(.horizontal, AppSpacing.md)
    .frame(height: 54)
    .background(Color.white)
    .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.sm, style: .continuous))
    .overlay(
        RoundedRectangle(cornerRadius: AppCornerRadius.sm, style: .continuous)
            .strokeBorder(Color(hex: "E0E0E0"), lineWidth: 1)
    )
}

#Preview {
    NavigationStack {
        SignInView()
    }
}
