//
//  SignInView.swift
//  iOS_Registry_System
//
//  Auth sign in view
//

import SwiftUI

struct SignInView: View {
    @State private var appState = AppState.shared
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: AppSpacing.lg) {
            Text("Welcome Back")
                .font(AppTypography.largeTitle)
                .padding(.top, AppSpacing.xxl)
            
            VStack(spacing: AppSpacing.md) {
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
            
            PrimaryButton(title: "Sign In", style: .accent) {
                Task {
                    await signIn()
                }
            }
            .disabled(isLoading || email.isEmpty || password.isEmpty)
            .padding(.horizontal, AppSpacing.screenHorizontal)
            
            if isLoading {
                ProgressView()
            }
            
            Spacer()
        }
        .appBackground()
    }
    
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

#Preview {
    SignInView()
}
