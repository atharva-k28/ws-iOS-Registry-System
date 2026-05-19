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
    let user: User?
    let viewModel: ProfileViewModel

    // Profile fields
    @State private var editName: String
    @State private var editEmail: String
    @State private var editPhone: String

    @State private var isSaving = false
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var profileImage: UIImage?
    @FocusState private var focusedField: Field?

    private enum Field: Hashable {
        case displayName
        case email
        case phone
    }

    init(user: User?, viewModel: ProfileViewModel) {
        self.user = user
        self.viewModel = viewModel
        _editName = State(initialValue: Self.initialDisplayName(for: user))
        _editEmail = State(initialValue: user?.email ?? "")
        _editPhone = State(initialValue: user?.phone ?? "")
    }

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: AppSpacing.xl) {

                    // MARK: — Avatar
                    avatarSection

                    // MARK: — Personal Info
                    sectionCard(title: "PERSONAL INFO") {
                        formField(label: "Display Name", text: $editName, icon: "person")
                        Divider().padding(.leading, 48)
                        formField(label: "Email", text: $editEmail, icon: "envelope")
                        Divider().padding(.leading, 48)
                        formField(label: "Phone", text: $editPhone, icon: "phone")
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
                    Button {
                        focusedField = nil
                        // Build input struct on the spot — no multi-param closure needed
                        let input = ProfileViewModel.ProfileSaveInput(
                            name: String(editName),
                            email: String(editEmail),
                            phone: editPhone.isEmpty ? nil : String(editPhone),
                            image: profileImage
                        )
                        Task {
                            isSaving = true
                            await viewModel.saveProfile(input)
                            isSaving = false
                            if viewModel.errorMessage == nil {
                                await MainActor.run {
                                    dismiss()
                                }
                            }
                        }
                    } label: {
                        if isSaving {
                            ProgressView()
                                .tint(AppColors.primaryDark)
                        } else {
                            Image(systemName: "checkmark")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(AppColors.primaryDark)
                        }
                    }
                    .disabled(isSaving || editName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || editEmail.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .onChange(of: selectedPhotoItem) { _, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        await MainActor.run {
                            profileImage = image
                        }
                    }
                }
            }
            .alert(
                "Error",
                isPresented: Binding(
                    get: { viewModel.errorMessage != nil },
                    set: { if !$0 { viewModel.errorMessage = nil } }
                ),
                presenting: viewModel.errorMessage
            ) { _ in
                Button("OK", role: .cancel) { }
            } message: { msg in
                Text(msg)
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
                        } else if let avatarUrl = user?.avatarUrl,
                                  let url = URL(string: avatarUrl) {
                            AsyncImage(url: url) { img in
                                img.resizable().scaledToFill()
                            } placeholder: {
                                AppColors.backgroundGray
                            }
                            .clipShape(Circle())
                        } else {
                            Text(initials)
                                .font(AppTypography.title2)
                                .foregroundStyle(AppColors.primaryText)
                        }
                    }
                    .overlay(Circle().strokeBorder(AppColors.white, lineWidth: 3))
                    .softShadow()

                PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(AppColors.white)
                        .frame(width: 28, height: 28)
                        .background(AppColors.primaryDark)
                        .clipShape(Circle())
                        .overlay(Circle().strokeBorder(AppColors.white, lineWidth: 2))
                }
                .buttonStyle(.plain)
            }

            VStack(spacing: 2) {
                Text(editName)
                    .font(AppTypography.title2)
                    .foregroundStyle(AppColors.primaryText)

                if !profileSubtitle.isEmpty {
                    Text(profileSubtitle)
                        .font(AppTypography.footnote)
                        .foregroundStyle(AppColors.secondaryGray)
                        .multilineTextAlignment(.center)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, AppSpacing.lg)
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
                    .focused($focusedField, equals: field(for: label))
            }
        }
        .padding(.horizontal, AppSpacing.md)
        .padding(.vertical, AppSpacing.md)
    }

    private func field(for label: String) -> Field? {
        switch label {
        case "Display Name":
            return .displayName
        case "Email":
            return .email
        case "Phone":
            return .phone
        default:
            return nil
        }
    }

    private var profileSubtitle: String {
        var parts: [String] = []
        let cleanEmail = editEmail.trimmingCharacters(in: .whitespacesAndNewlines)
        if !cleanEmail.isEmpty {
            parts.append(cleanEmail)
        }
        if let createdAt = user?.createdAt {
            parts.append("Joined \(createdAt.formatted(.dateTime.month(.abbreviated).year()))")
        }
        return parts.joined(separator: " · ")
    }

    private var initials: String {
        let source = editName.isEmpty ? editEmail : editName
        let words = source.split(separator: " ")
        let letters = words.prefix(2).compactMap { $0.first }
        let value = String(letters).uppercased()
        return value.isEmpty ? "U" : value
    }

    private static func initialDisplayName(for user: User?) -> String {
        guard let user else { return "" }
        let fullName = user.fullName.trimmingCharacters(in: .whitespacesAndNewlines)
        if !fullName.isEmpty { return fullName }

        let firstLast = [user.firstName, user.lastName]
            .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .joined(separator: " ")
        if !firstLast.isEmpty { return firstLast }

        return user.email
    }

}

#Preview {
    EditProfileView(user: nil, viewModel: ProfileViewModel())
}
