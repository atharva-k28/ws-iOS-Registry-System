//
//  ShippingAddressSheet.swift
//  iOS_Registry_System
//
//  Set shipping address for registry deliveries.
//

import SwiftUI

struct ShippingAddressSheet: View {

    @Environment(\.dismiss) private var dismiss
    @State private var recipientName = ""
    @State private var addressLine1  = ""
    @State private var addressLine2  = ""
    @State private var city          = ""
    @State private var state         = ""
    @State private var zip           = ""
    @State private var phone         = ""
    @State private var isSaved       = false
    @State private var isDefault     = true

    private var isComplete: Bool {
        !recipientName.isEmpty && !addressLine1.isEmpty && !city.isEmpty && !state.isEmpty && !zip.isEmpty
    }

    var body: some View {
        NavigationStack {
            Group {
                if isSaved {
                    successView
                } else {
                    formView
                }
            }
            .navigationTitle("Shipping Address")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(AppColors.primaryText)
                            .frame(width: 32, height: 32)
                            .background(Circle().fill(AppColors.white).shadow(color: .black.opacity(0.08), radius: 6, y: 2))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Form

    private var formView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.xl) {

                // Header
                VStack(alignment: .leading, spacing: 6) {
                    Text("Where should gifts be delivered?")
                        .font(.system(size: 24, weight: .regular, design: .serif))
                        .foregroundStyle(AppColors.primaryText)
                    Text("This address is shared with contributors when they purchase.")
                        .font(AppTypography.footnote)
                        .foregroundStyle(AppColors.secondaryGray)
                }

                // Form fields
                VStack(spacing: AppSpacing.md) {
                    field("Recipient Name", placeholder: "Sarah & James Carter", text: $recipientName)
                    field("Street Address", placeholder: "123 Main Street", text: $addressLine1)
                    field("Apt, Suite, etc. (optional)", placeholder: "Unit 4B", text: $addressLine2)

                    HStack(spacing: AppSpacing.sm) {
                        field("City", placeholder: "San Francisco", text: $city)
                        field("State", placeholder: "CA", text: $state)
                            .frame(maxWidth: 80)
                        field("ZIP", placeholder: "94102", text: $zip)
                            .frame(maxWidth: 100)
                    }

                    field("Phone (optional)", placeholder: "+1 (555) 000-0000", text: $phone, keyboard: .phonePad)
                }

                // Set as default toggle
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Set as default address")
                            .font(AppTypography.bodyMedium)
                            .foregroundStyle(AppColors.primaryText)
                        Text("Used for all future registry deliveries")
                            .font(AppTypography.caption1)
                            .foregroundStyle(AppColors.secondaryGray)
                    }
                    Spacer()
                    Toggle("", isOn: $isDefault)
                        .labelsHidden()
                        .tint(AppColors.accentRed)
                }
                .padding(AppSpacing.md)
                .background(AppColors.white)
                .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.md))
                .softShadow()

                // Privacy note
                HStack(spacing: 6) {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 11))
                        .foregroundStyle(AppColors.secondaryGray)
                    Text("Only contributors purchasing gifts will see this address.")
                        .font(AppTypography.caption1)
                        .foregroundStyle(AppColors.secondaryGray)
                }
                .padding(.horizontal, 4)

                Color.clear.frame(height: 80)
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.top, AppSpacing.md)
        }
        .appBackground()
        .safeAreaInset(edge: .bottom) {
            Button {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    isSaved = true
                }
            } label: {
                Text("Save Address")
                    .font(AppTypography.buttonLarge)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(isComplete ? AppColors.accentRed : AppColors.secondaryGray)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
            .disabled(!isComplete)
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.vertical, AppSpacing.md)
            .background(AppColors.background.opacity(0.96))
            .animation(.spring(response: 0.3), value: isComplete)
        }
    }

    @ViewBuilder
    private func field(_ title: String, placeholder: String, text: Binding<String>, keyboard: UIKeyboardType = .default) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(AppTypography.caption1Medium)
                .tracking(0.5)
                .foregroundStyle(AppColors.secondaryGray)
            TextField(placeholder, text: text)
                .keyboardType(keyboard)
                .font(AppTypography.body)
                .foregroundStyle(AppColors.primaryText)
                .padding(AppSpacing.sm)
                .background(AppColors.white)
                .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.sm))
                .overlay(
                    RoundedRectangle(cornerRadius: AppCornerRadius.sm)
                        .stroke(text.wrappedValue.isEmpty ? Color.black.opacity(0.07) : AppColors.primaryText.opacity(0.2), lineWidth: 1)
                )
        }
    }

    // MARK: - Success

    private var successView: some View {
        VStack(spacing: AppSpacing.xl) {
            Spacer()

            ZStack {
                Circle().fill(AppColors.accentRed.opacity(0.08)).frame(width: 100, height: 100)
                Circle().fill(AppColors.accentRed.opacity(0.15)).frame(width: 72, height: 72)
                Image(systemName: "house.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(AppColors.accentRed)
            }

            VStack(spacing: 8) {
                Text("Address saved.")
                    .font(.system(size: 28, weight: .regular, design: .serif))
                    .foregroundStyle(AppColors.primaryText)

                VStack(spacing: 4) {
                    Text(recipientName)
                        .font(AppTypography.bodyMedium)
                        .foregroundStyle(AppColors.primaryText)
                    Text("\(addressLine1)\(addressLine2.isEmpty ? "" : ", \(addressLine2)")")
                        .font(AppTypography.footnote)
                        .foregroundStyle(AppColors.secondaryGray)
                    Text("\(city), \(state) \(zip)")
                        .font(AppTypography.footnote)
                        .foregroundStyle(AppColors.secondaryGray)
                }
                .padding(AppSpacing.md)
                .background(AppColors.white)
                .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.md))
                .softShadow()
            }

            Spacer()

            Button { dismiss() } label: {
                Text("Done")
                    .font(AppTypography.buttonLarge)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(AppColors.primaryText)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.bottom, AppSpacing.xxl)
        }
        .appBackground()
    }
}
