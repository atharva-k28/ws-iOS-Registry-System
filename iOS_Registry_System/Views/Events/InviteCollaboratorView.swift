//
//  InviteCollaboratorView.swift
//  iOS_Registry_System
//
//  Screen 3 — Full-screen invite flow with contact search,
//  invite method picker, role summary, and Send Invite CTA.
//

import SwiftUI

// MARK: - Invite Method

private enum InviteMethod: String, CaseIterable {
    case phone    = "Phone"
    case email    = "Email"
    case link     = "Share Link"
    case contacts = "Contacts"
}

// MARK: - Mock Contact

private struct MockContact: Identifiable {
    let id = UUID()
    let name: String
    let meta: String
    let avatar: String
}

private let suggestedContacts: [MockContact] = [
    .init(name: "James Carter",  meta: "Recently contacted", avatar: "https://i.pravatar.cc/150?img=11"),
    .init(name: "Priya Patel",   meta: "In your family group", avatar: "https://i.pravatar.cc/150?img=20"),
    .init(name: "Marcus Reed",   meta: "Saved contact",       avatar: "https://i.pravatar.cc/150?img=33"),
    .init(name: "Zoey Nguyen",   meta: "From event guests",   avatar: "https://i.pravatar.cc/150?img=23"),
]

// MARK: - Invite Collaborator View

struct InviteCollaboratorView: View {

    let role: CollaboratorRole
    var onInviteSent: (Collaborator) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var inviteMethod: InviteMethod = .contacts
    @State private var searchText = ""
    @State private var selectedContact: MockContact? = nil
    @State private var phoneInput = ""
    @State private var emailInput = ""
    @State private var showCustomiseAccess = false
    @State private var permissions: CollaboratorPermissions
    
    // Real user search state
    @State private var searchResults: [User] = []
    @State private var isSearching = false
    @State private var selectedUser: User? = nil

    init(role: CollaboratorRole, onInviteSent: @escaping (Collaborator) -> Void) {
        self.role = role
        self.onInviteSent = onInviteSent
        _permissions = State(initialValue: role.defaultPermissions)
    }

    private func performSearch(query: String) async {
        guard !query.isEmpty else {
            searchResults = []
            return
        }
        isSearching = true
        defer { isSearching = false }
        do {
            searchResults = try await AuthService.shared.searchUsers(query: query)
        } catch {
            print("Error searching users: \(error)")
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: AppSpacing.xl) {

                    // Invite Method
                    inviteMethodPicker

                    // Input field or contact search
                    switch inviteMethod {
                    case .phone:    phoneSection
                    case .email:    emailSection
                    case .link:     shareLinkSection
                    case .contacts: contactsSection
                    }

                    // Role Summary Card
                    roleSummaryCard

                    Color.clear.frame(height: AppSpacing.tabBarHeight + 80)
                }
                .padding(.horizontal, AppSpacing.screenHorizontal)
                .padding(.top, AppSpacing.md)
            }
            .appBackground()
            .navigationTitle("Invite Collaborator")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(AppColors.primaryText)
                            .frame(width: 32, height: 32)
                            .background(Circle().fill(AppColors.white).shadow(color: .black.opacity(0.08), radius: 6, y: 2))
                    }
                    .buttonStyle(.plain)
                }
            }
            .sheet(isPresented: $showCustomiseAccess) {
                ManageAccessView(role: role, permissions: $permissions)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
                    .presentationCornerRadius(32)
            }
            .safeAreaInset(edge: .bottom) { sendButton }
            .onChange(of: searchText) { _ in
                Task {
                    await performSearch(query: searchText)
                }
            }
        }
    }

    // MARK: - Invite Method Picker

    private var inviteMethodPicker: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("INVITE VIA")
                .font(AppTypography.caption1Medium)
                .tracking(1.5)
                .foregroundStyle(AppColors.secondaryGray)

            HStack(spacing: 0) {
                ForEach(InviteMethod.allCases, id: \.self) { method in
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            inviteMethod = method
                        }
                    } label: {
                        Text(method.rawValue)
                            .font(AppTypography.caption1Medium)
                            .foregroundStyle(inviteMethod == method ? .white : AppColors.primaryText)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: AppCornerRadius.sm)
                                    .fill(inviteMethod == method ? AppColors.primaryText : Color.clear)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(4)
            .background(AppColors.white)
            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.sm + 4))
            .softShadow()
        }
    }

    // MARK: - Phone

    private var phoneSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Phone Number")
                .font(AppTypography.footnoteSemibold)
                .foregroundStyle(AppColors.secondaryGray)
            TextField("+1 (555) 000-0000", text: $phoneInput)
                .keyboardType(.phonePad)
                .font(AppTypography.body)
                .foregroundStyle(AppColors.primaryText)
                .padding(AppSpacing.md)
                .background(AppColors.white)
                .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.md))
                .softShadow()
        }
    }

    // MARK: - Email

    private var emailSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Email Address")
                .font(AppTypography.footnoteSemibold)
                .foregroundStyle(AppColors.secondaryGray)
            TextField("name@example.com", text: $emailInput)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .font(AppTypography.body)
                .foregroundStyle(AppColors.primaryText)
                .padding(AppSpacing.md)
                .background(AppColors.white)
                .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.md))
                .softShadow()
        }
    }

    // MARK: - Share Link

    private var shareLinkSection: some View {
        VStack(spacing: AppSpacing.md) {
            HStack {
                Text("registry.app/invite/abc123")
                    .font(AppTypography.footnote)
                    .foregroundStyle(AppColors.secondaryGray)
                    .lineLimit(1)
                Spacer()
                Button {
                    // Copy to clipboard
                    UIPasteboard.general.string = "registry.app/invite/abc123"
                } label: {
                    Text("Copy")
                        .font(AppTypography.caption1Medium)
                        .foregroundStyle(AppColors.accentRed)
                }
                .buttonStyle(.plain)
            }
            .padding(AppSpacing.md)
            .background(AppColors.white)
            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.md))
            .overlay(
                RoundedRectangle(cornerRadius: AppCornerRadius.md)
                    .stroke(Color.black.opacity(0.08), lineWidth: 1)
            )

            Button {
                // Share sheet
            } label: {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                    Text("Share Link")
                }
                .font(AppTypography.buttonMedium)
                .foregroundStyle(AppColors.primaryText)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(AppColors.white)
                .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.md))
                .softShadow()
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Contacts

    private var contactsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            // Search bar
            HStack(spacing: AppSpacing.sm) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(AppColors.secondaryGray)
                TextField("Search contacts", text: $searchText)
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.primaryText)
                if !searchText.isEmpty {
                    Button { searchText = "" } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(AppColors.secondaryGray)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(AppSpacing.sm)
            .background(AppColors.white)
            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.md))
            .softShadow()

            if isSearching {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                .padding(.vertical, AppSpacing.md)
            } else {
                VStack(alignment: .leading, spacing: 6) {
                    if searchText.isEmpty {
                        Text("SUGGESTED")
                            .font(AppTypography.caption1Medium)
                            .tracking(1.5)
                            .foregroundStyle(AppColors.secondaryGray)

                        ForEach(suggestedContacts) { contact in
                            mockContactRow(contact: contact)
                        }
                    } else {
                        Text("SEARCH RESULTS")
                            .font(AppTypography.caption1Medium)
                            .tracking(1.5)
                            .foregroundStyle(AppColors.secondaryGray)

                        if searchResults.isEmpty {
                            Text("No users found")
                                .font(AppTypography.footnote)
                                .foregroundStyle(AppColors.secondaryGray)
                                .padding(.vertical, AppSpacing.sm)
                        } else {
                            ForEach(searchResults) { user in
                                userRow(user: user)
                            }
                        }
                    }
                }
            }
        }
    }

    private func mockContactRow(contact: MockContact) -> some View {
        let isSelected = selectedContact?.id == contact.id

        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                if isSelected {
                    selectedContact = nil
                } else {
                    selectedContact = contact
                    selectedUser = nil
                }
            }
        } label: {
            HStack(spacing: AppSpacing.md) {
                AsyncImage(url: URL(string: contact.avatar)) { img in
                    img.resizable().aspectRatio(contentMode: .fill)
                } placeholder: {
                    Circle().fill(AppColors.backgroundGray)
                }
                .frame(width: 44, height: 44)
                .clipShape(Circle())

                VStack(alignment: .leading, spacing: 2) {
                    Text(contact.name)
                        .font(AppTypography.bodyMedium)
                        .foregroundStyle(AppColors.primaryText)
                    Text(contact.meta)
                        .font(AppTypography.caption1)
                        .foregroundStyle(AppColors.secondaryGray)
                }
                Spacer()

                Image(systemName: isSelected ? "checkmark.circle.fill" : "plus.circle")
                    .font(.system(size: 22))
                    .foregroundStyle(isSelected ? Color(hex: "34C759") : AppColors.secondaryGray)
            }
            .padding(AppSpacing.sm)
            .background(AppColors.white)
            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.md))
            .overlay(
                RoundedRectangle(cornerRadius: AppCornerRadius.md)
                    .stroke(isSelected ? Color(hex: "34C759").opacity(0.4) : Color.clear, lineWidth: 1.5)
            )
            .softShadow()
        }
        .buttonStyle(.plain)
    }

    private func userRow(user: User) -> some View {
        let isSelected = selectedUser?.id == user.id

        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                if isSelected {
                    selectedUser = nil
                } else {
                    selectedUser = user
                    selectedContact = nil
                }
            }
        } label: {
            HStack(spacing: AppSpacing.md) {
                AsyncImage(url: URL(string: user.avatarUrl ?? "")) { img in
                    img.resizable().aspectRatio(contentMode: .fill)
                } placeholder: {
                    Circle().fill(AppColors.backgroundGray)
                        .overlay(
                            Text(String(user.fullName.prefix(1)))
                                .font(AppTypography.bodyMedium)
                                .foregroundStyle(AppColors.secondaryGray)
                        )
                }
                .frame(width: 44, height: 44)
                .clipShape(Circle())

                VStack(alignment: .leading, spacing: 2) {
                    Text(user.fullName)
                        .font(AppTypography.bodyMedium)
                        .foregroundStyle(AppColors.primaryText)
                    Text(user.email)
                        .font(AppTypography.caption1)
                        .foregroundStyle(AppColors.secondaryGray)
                }
                Spacer()

                Image(systemName: isSelected ? "checkmark.circle.fill" : "plus.circle")
                    .font(.system(size: 22))
                    .foregroundStyle(isSelected ? Color(hex: "34C759") : AppColors.secondaryGray)
            }
            .padding(AppSpacing.sm)
            .background(AppColors.white)
            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.md))
            .overlay(
                RoundedRectangle(cornerRadius: AppCornerRadius.md)
                    .stroke(isSelected ? Color(hex: "34C759").opacity(0.4) : Color.clear, lineWidth: 1.5)
            )
            .softShadow()
        }
        .buttonStyle(.plain)
    }

    // MARK: - Role Summary Card

    private var roleSummaryCard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(role.rawValue) Access")
                        .font(AppTypography.headline)
                        .foregroundStyle(AppColors.primaryText)
                    Text("What they'll be able to manage")
                        .font(AppTypography.caption1)
                        .foregroundStyle(AppColors.secondaryGray)
                }
                Spacer()
                Image(systemName: role.icon)
                    .font(.system(size: 20))
                    .foregroundStyle(AppColors.accentRed)
            }

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                permissionRow("Edit Registry",     enabled: permissions.editRegistry)
                permissionRow("Invite Guests",     enabled: permissions.inviteGuests)
                permissionRow("Manage Timeline",   enabled: permissions.editTimeline)
                permissionRow("View Contributions",enabled: permissions.viewContributions)
            }

            Button {
                showCustomiseAccess = true
            } label: {
                Text("Customise Access")
                    .font(AppTypography.buttonSmall)
                    .foregroundStyle(AppColors.accentRed)
                    .frame(maxWidth: .infinity)
                    .frame(height: 38)
                    .background(
                        RoundedRectangle(cornerRadius: AppCornerRadius.sm)
                            .stroke(AppColors.accentRed.opacity(0.3), lineWidth: 1.5)
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(AppSpacing.lg)
        .background(AppColors.white)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.lg))
        .softShadow()
    }

    private func permissionRow(_ label: String, enabled: Bool) -> some View {
        HStack(spacing: 8) {
            Image(systemName: enabled ? "checkmark.circle.fill" : "xmark.circle")
                .font(.system(size: 15))
                .foregroundStyle(enabled ? Color(hex: "34C759") : AppColors.secondaryGray.opacity(0.5))
            Text(label)
                .font(AppTypography.footnote)
                .foregroundStyle(enabled ? AppColors.primaryText : AppColors.secondaryGray.opacity(0.6))
        }
    }

    // MARK: - Send Button

    private var sendButton: some View {
        Button {
            let name: String
            let avatar: String?
            let userId: UUID?

            if let user = selectedUser {
                name = user.fullName
                avatar = user.avatarUrl
                userId = user.id
            } else if let contact = selectedContact {
                name = contact.name
                avatar = contact.avatar
                userId = nil
            } else {
                name = emailInput.isEmpty ? phoneInput : emailInput
                avatar = nil
                userId = nil
            }

            guard !name.isEmpty else { return }
            
            let collaborator = Collaborator(
                userId: userId,
                name: name,
                avatarURL: avatar,
                role: role,
                status: .pending,
                invitedDate: .now,
                permissions: permissions
            )
            onInviteSent(collaborator)
            dismiss()
        } label: {
            Text("Send Invite")
                .font(AppTypography.buttonLarge)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(AppColors.accentRed)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .padding(.horizontal, AppSpacing.screenHorizontal)
        .padding(.vertical, AppSpacing.md)
        .background(AppColors.background.opacity(0.95))
    }
}
