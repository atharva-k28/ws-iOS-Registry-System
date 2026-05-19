//
//  EditProfileView.swift
//  iOS_Registry_System
//
//  Full-screen profile & settings editor
//

import SwiftUI
import PhotosUI

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss

    // Profile fields
    @State private var displayName = "Olivia Bennett"
    @State private var email = "olivia@example.com"
    @State private var username = "@olivia"

    // Photo
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var profileImage: UIImage? = nil
    @State private var showPhotoOptions = false
    @State private var showLibraryPicker = false
    @State private var showCamera = false

    // Notifications toggles
    @State private var pushNotifications = true
    @State private var emailUpdates = false

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: AppSpacing.xl) {

                    // MARK: — Avatar
                    avatarSection

                    // MARK: — Personal Info
                    sectionCard(title: "PERSONAL INFO") {
                        formField(label: "Display Name", text: $displayName, icon: "person")
                        Divider().padding(.leading, 48)
                        formField(label: "Username", text: $username, icon: "at")
                        Divider().padding(.leading, 48)
                        formField(label: "Email", text: $email, icon: "envelope")
                    }

                    // MARK: — Notifications
                    sectionCard(title: "NOTIFICATIONS") {
                        toggleRow(label: "Push Notifications", icon: "bell", isOn: $pushNotifications)
                        Divider().padding(.leading, 48)
                        toggleRow(label: "Email Updates", icon: "envelope.badge", isOn: $emailUpdates)
                    }

                    Color.clear.frame(height: 40)
                }
                .padding(.horizontal, AppSpacing.screenHorizontal)
                .padding(.top, AppSpacing.md)
            }
            .appBackground()
            .navigationBarBackButtonHidden(false)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(AppColors.primaryText)
                            .frame(width: 36, height: 36)
                            .background(
                                Circle()
                                    .fill(AppColors.backgroundGray)
                            )
                    }
                    .buttonStyle(.plain)
                }
                ToolbarItem(placement: .principal) {
                    Text("PROFILE & SETTINGS")
                        .font(AppTypography.caption1Medium)
                        .tracking(1.5)
                        .foregroundColor(AppColors.primaryText)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(AppColors.primaryDark)
                    }
                }
            }
            .fullScreenCover(isPresented: $showCamera) {
                ImagePicker(image: $profileImage)
            }
            .photosPicker(isPresented: $showLibraryPicker, selection: $selectedPhotoItem, matching: .images)
            .onChange(of: selectedPhotoItem) { _, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        await MainActor.run { profileImage = image }
                    }
                }
            }
        }
    }

    // MARK: — Avatar Section

    private var avatarSection: some View {
        VStack(spacing: AppSpacing.md) {
            ZStack(alignment: .bottomTrailing) {
                Circle()
                    .fill(AppColors.backgroundGray)
                    .frame(width: 100, height: 100)
                    .overlay {
                        if let profileImage {
                            Image(uiImage: profileImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                        } else {
                            AsyncImage(url: URL(string: "https://i.pravatar.cc/300?img=5")) { img in
                                img.resizable().scaledToFill()
                            } placeholder: {
                                Color.gray.opacity(0.2)
                            }
                            .clipShape(Circle())
                        }
                    }
                    .overlay(Circle().strokeBorder(AppColors.white, lineWidth: 3))
                    .softShadow()

                // Camera badge — tap for options
                Button(action: { showPhotoOptions = true }) {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(AppColors.white)
                        .frame(width: 28, height: 28)
                        .background(AppColors.primaryDark)
                        .clipShape(Circle())
                        .overlay(Circle().strokeBorder(AppColors.white, lineWidth: 2))
                }
            }

            VStack(spacing: 2) {
                Text(displayName)
                    .font(AppTypography.title2)
                    .foregroundStyle(AppColors.primaryText)
                Text(username + " · Joined Mar 2026")
                    .font(AppTypography.footnote)
                    .foregroundStyle(AppColors.secondaryGray)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, AppSpacing.lg)
        .confirmationDialog("Change Photo", isPresented: $showPhotoOptions, titleVisibility: .visible) {
            Button("Choose from Library") { showLibraryPicker = true }
            Button("Take Photo") { showCamera = true }
            if profileImage != nil {
                Button("Remove Photo", role: .destructive) { profileImage = nil }
            }
            Button("Cancel", role: .cancel) {}
        }
    }

    // MARK: — Section Card builder

    private func sectionCard<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(AppTypography.caption2)
                .tracking(1.2)
                .foregroundColor(AppColors.secondaryGray)
                .padding(.bottom, AppSpacing.sm)

            VStack(spacing: 0) {
                content()
            }
            .background(AppColors.white)
            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.lg, style: .continuous))
            .softShadow()
        }
    }

    // MARK: — Row builders

    private func formField(label: String, text: Binding<String>, icon: String) -> some View {
        HStack(spacing: AppSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(AppColors.secondaryGray)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(AppTypography.caption2)
                    .foregroundColor(AppColors.secondaryGray)
                TextField("", text: text)
                    .font(AppTypography.bodyMedium)
                    .foregroundColor(AppColors.primaryText)
            }
        }
        .padding(.horizontal, AppSpacing.md)
        .padding(.vertical, AppSpacing.md)
    }

    private func toggleRow(label: String, icon: String, isOn: Binding<Bool>) -> some View {
        HStack(spacing: AppSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(AppColors.secondaryGray)
                .frame(width: 24)
            Text(label)
                .font(AppTypography.bodyMedium)
                .foregroundColor(AppColors.primaryText)
            Spacer()
            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(AppColors.primaryDark)
        }
        .padding(.horizontal, AppSpacing.md)
        .padding(.vertical, AppSpacing.sm)
    }

}

#Preview {
    EditProfileView()
}
