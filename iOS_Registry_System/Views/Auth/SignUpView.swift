//
//  SignUpView.swift
//  iOS_Registry_System
//
//  Auth sign up view
//

import SwiftUI

struct SignUpView: View {
    @State private var appState = AppState.shared
    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: AppSpacing.lg) {
            Text("Create Account")
                .font(AppTypography.largeTitle)
                .padding(.top, AppSpacing.xxl)
            
            VStack(spacing: AppSpacing.md) {
                TextField("Full Name", text: $fullName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                if let errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            
            PrimaryButton(title: "Sign Up", style: .accent) {
                Task {
                    await signUp()
                }
            }
            .disabled(isLoading || email.isEmpty || password.isEmpty || fullName.isEmpty)
            .padding(.horizontal, AppSpacing.screenHorizontal)
            
            if isLoading {
                ProgressView()
            }
            
            Spacer()
        }
        .appBackground()
    }
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

