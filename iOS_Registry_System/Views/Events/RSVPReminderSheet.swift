//
//  RSVPReminderSheet.swift
//  iOS_Registry_System
//
//  Send RSVP reminders to pending guests.
//

import SwiftUI

struct RSVPReminderSheet: View {

    @Environment(\.dismiss) private var dismiss
    @State private var selectedGuests: Set<String> = []
    @State private var customMessage = ""
    @State private var isSending = false
    @State private var didSend = false

    private let pendingGuests: [(name: String, avatar: String, invitedDate: String)] = [
        ("Ethan Brooks",  "https://i.pravatar.cc/150?img=11", "Invited May 8"),
        ("Mia Johnson",   "https://i.pravatar.cc/150?img=23", "Invited May 6"),
        ("Lucas Kim",     "https://i.pravatar.cc/150?img=33", "Invited May 7"),
    ]

    var body: some View {
        NavigationStack {
            Group {
                if didSend {
                    successView
                } else {
                    formView
                }
            }
            .navigationTitle("RSVP Reminders")
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

    // MARK: - Form View

    private var formView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.xl) {

                // Header
                VStack(alignment: .leading, spacing: 6) {
                    Text("3 guests haven't responded yet.")
                        .font(.system(size: 24, weight: .regular, design: .serif))
                        .foregroundStyle(AppColors.primaryText)
                    Text("Send a gentle reminder to follow up.")
                        .font(AppTypography.footnote)
                        .foregroundStyle(AppColors.secondaryGray)
                }

                // Guest list
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    Text("SELECT GUESTS")
                        .font(AppTypography.caption1Medium)
                        .tracking(1.5)
                        .foregroundStyle(AppColors.secondaryGray)

                    ForEach(pendingGuests, id: \.name) { guest in
                        guestCheckRow(guest: guest)
                    }

                    // Select all
                    Button {
                        if selectedGuests.count == pendingGuests.count {
                            selectedGuests.removeAll()
                        } else {
                            selectedGuests = Set(pendingGuests.map(\.name))
                        }
                    } label: {
                        Text(selectedGuests.count == pendingGuests.count ? "Deselect All" : "Select All")
                            .font(AppTypography.caption1Medium)
                            .foregroundStyle(AppColors.accentRed)
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 4)
                }

                // Message
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    Text("MESSAGE")
                        .font(AppTypography.caption1Medium)
                        .tracking(1.5)
                        .foregroundStyle(AppColors.secondaryGray)

                    ZStack(alignment: .topLeading) {
                        if customMessage.isEmpty {
                            Text("Hi! Just a gentle reminder to RSVP for our celebration. We'd love to have you there 🎉")
                                .font(AppTypography.body)
                                .foregroundStyle(AppColors.secondaryGray.opacity(0.6))
                                .padding(AppSpacing.sm)
                        }
                        TextEditor(text: $customMessage)
                            .font(AppTypography.body)
                            .foregroundStyle(AppColors.primaryText)
                            .scrollContentBackground(.hidden)
                            .frame(minHeight: 100)
                            .padding(AppSpacing.xs)
                    }
                    .padding(AppSpacing.sm)
                    .background(AppColors.white)
                    .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.md))
                    .softShadow()
                }

                Color.clear.frame(height: 80)
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.top, AppSpacing.md)
        }
        .appBackground()
        .safeAreaInset(edge: .bottom) {
            Button {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    isSending = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    withAnimation { didSend = true }
                }
            } label: {
                Group {
                    if isSending && !didSend {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("Send Reminder\(selectedGuests.count > 1 ? "s" : "") (\(selectedGuests.count))")
                            .font(AppTypography.buttonLarge)
                    }
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(selectedGuests.isEmpty ? AppColors.secondaryGray : AppColors.accentRed)
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)
            .disabled(selectedGuests.isEmpty || isSending)
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.vertical, AppSpacing.md)
            .background(AppColors.background.opacity(0.96))
            .animation(.spring(response: 0.3), value: selectedGuests.count)
        }
    }

    private func guestCheckRow(guest: (name: String, avatar: String, invitedDate: String)) -> some View {
        let isSelected = selectedGuests.contains(guest.name)
        return Button {
            withAnimation(.spring(response: 0.3)) {
                if isSelected { selectedGuests.remove(guest.name) }
                else { selectedGuests.insert(guest.name) }
            }
        } label: {
            HStack(spacing: AppSpacing.md) {
                AsyncImage(url: URL(string: guest.avatar)) { img in
                    img.resizable().aspectRatio(contentMode: .fill)
                } placeholder: { Circle().fill(AppColors.backgroundGray) }
                .frame(width: 40, height: 40)
                .clipShape(Circle())

                VStack(alignment: .leading, spacing: 2) {
                    Text(guest.name)
                        .font(AppTypography.bodyMedium)
                        .foregroundStyle(AppColors.primaryText)
                    Text(guest.invitedDate)
                        .font(AppTypography.caption1)
                        .foregroundStyle(AppColors.secondaryGray)
                }
                Spacer()
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundStyle(isSelected ? Color(hex: "34C759") : AppColors.secondaryGray.opacity(0.4))
            }
            .padding(AppSpacing.sm)
            .background(AppColors.white)
            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.md))
            .overlay(RoundedRectangle(cornerRadius: AppCornerRadius.md).stroke(isSelected ? Color(hex: "34C759").opacity(0.3) : Color.clear, lineWidth: 1.5))
            .softShadow()
        }
        .buttonStyle(.plain)
    }

    // MARK: - Success View

    private var successView: some View {
        VStack(spacing: AppSpacing.xl) {
            Spacer()
            ZStack {
                Circle().fill(Color(hex: "34C759").opacity(0.1)).frame(width: 96, height: 96)
                Circle().fill(Color(hex: "34C759").opacity(0.2)).frame(width: 72, height: 72)
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(Color(hex: "34C759"))
            }
            VStack(spacing: 8) {
                Text("Reminders sent!")
                    .font(.system(size: 28, weight: .regular, design: .serif))
                    .foregroundStyle(AppColors.primaryText)
                Text("Your guests will receive a gentle nudge to RSVP.")
                    .font(AppTypography.footnote)
                    .foregroundStyle(AppColors.secondaryGray)
                    .multilineTextAlignment(.center)
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
