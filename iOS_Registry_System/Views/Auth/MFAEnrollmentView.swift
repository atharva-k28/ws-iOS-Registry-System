//
//  MFAEnrollmentView.swift
//  iOS_Registry_System
//
//  Auth MFA Enrollment view
//

import SwiftUI
import CoreImage.CIFilterBuiltins

struct MFAEnrollmentView: View {
    @State private var appState = AppState.shared
    @State private var factorId: String?
    @State private var qrCodeURI: String?
    @State private var verificationCode = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: AppSpacing.lg) {
            Text("Secure Your Account")
                .font(AppTypography.largeTitle)
                .padding(.top, AppSpacing.xxl)
            
            Text("Scan this QR code with your authenticator app (like Google Authenticator or Authy).")
                .multilineTextAlignment(.center)
                .font(AppTypography.body)
                .padding(.horizontal, AppSpacing.lg)
            
            if let qrCodeURI = qrCodeURI, let uiImage = generateQRCode(from: qrCodeURI) {
                Image(uiImage: uiImage)
                    .resizable()
                    .interpolation(.none)
                    .scaledToFit()
                    .frame(width: 200, height: 200)
            } else if isLoading {
                ProgressView()
                    .frame(width: 200, height: 200)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 200, height: 200)
            }
            
            VStack(spacing: AppSpacing.md) {
                TextField("Enter 6-digit code", text: $verificationCode)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.center)
                    .font(.title2)
                
                if let errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            
            PrimaryButton(title: "Verify & Complete", style: .accent) {
                Task {
                    await verifyMFA()
                }
            }
            .disabled(isLoading || verificationCode.count != 6 || factorId == nil)
            .padding(.horizontal, AppSpacing.screenHorizontal)
            
            Spacer()
        }
        .appBackground()
        .task {
            await startEnrollment()
        }
    }
    
    private func startEnrollment() async {
        isLoading = true
        errorMessage = nil
        do {
            let result = try await AuthService.shared.enrollMFA()
            factorId = result.factorId
            qrCodeURI = result.qrCode
        } catch {
            errorMessage = "Failed to start enrollment: \(error.localizedDescription)"
        }
        isLoading = false
    }
    
    private func verifyMFA() async {
        guard let factorId = factorId else { return }
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
    
    private func generateQRCode(from string: String) -> UIImage? {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(string.utf8)

        if let outputImage = filter.outputImage {
            if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
                return UIImage(cgImage: cgImage)
            }
        }
        return nil
    }
}

#Preview {
    MFAEnrollmentView()
}
