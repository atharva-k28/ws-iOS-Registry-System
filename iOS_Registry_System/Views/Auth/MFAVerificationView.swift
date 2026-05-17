//
//  MFAVerificationView.swift
//  iOS_Registry_System
//
//  Auth MFA Verification view
//

import SwiftUI
import Supabase

struct MFAVerificationView: View {
    @State private var appState = AppState.shared
    @State private var verificationCode = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    // We assume the user has only 1 factor enrolled. We will fetch the first factor.
    @State private var factorId: String?

    var body: some View {
        VStack(spacing: AppSpacing.lg) {
            Text("Two-Factor Auth")
                .font(AppTypography.largeTitle)
                .padding(.top, AppSpacing.xxl)
            
            Text("Please enter the 6-digit code from your authenticator app.")
                .multilineTextAlignment(.center)
                .font(AppTypography.body)
                .padding(.horizontal, AppSpacing.lg)
            
            VStack(spacing: AppSpacing.md) {
                TextField("000000", text: $verificationCode)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.center)
                    .font(.system(size: 32, weight: .bold, design: .monospaced))
                
                if let errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            
            PrimaryButton(title: "Verify", style: .accent) {
                Task {
                    await verifyCode()
                }
            }
            .disabled(isLoading || verificationCode.count < 6)
            .padding(.horizontal, AppSpacing.screenHorizontal)
            
            if isLoading {
                ProgressView()
            }
            
            Spacer()
        }
        .appBackground()
        .task {
            await fetchFactorId()
        }
    }
    
    private func fetchFactorId() async {
        do {
            let factors = try await SupabaseManager.shared.client.auth.mfa.listFactors()
            if let firstFactor = factors.totp.first {
                factorId = firstFactor.id
            } else {
                errorMessage = "No MFA factor found."
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    private func verifyCode() async {
        guard let factorId = factorId else {
            errorMessage = "No factor available"
            return
        }
        isLoading = true
        errorMessage = nil
        do {
            let challengeId = try await AuthService.shared.challengeMFA(factorId: factorId)
            try await AuthService.shared.verifyMFA(factorId: factorId, challengeId: challengeId, code: verificationCode)
            
            appState.mfaRequired = AuthService.shared.mfaRequired
        } catch {
            errorMessage = "Verification failed: \(error.localizedDescription)"
        }
        isLoading = false
    }
}

#Preview {
    MFAVerificationView()
}
