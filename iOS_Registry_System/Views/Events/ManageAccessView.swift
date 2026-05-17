//
//  ManageAccessView.swift
//  iOS_Registry_System
//
//  Screen 6 — Premium iOS settings-style permissions editor.
//  Grouped toggles + danger zone remove button.
//

import SwiftUI

struct ManageAccessView: View {

    let role: CollaboratorRole
    @Binding var permissions: CollaboratorPermissions
    @Environment(\.dismiss) private var dismiss
    @State private var showRemoveAlert = false

    var body: some View {
        NavigationStack {
            List {
                // MARK: Registry
                Section {
                    Toggle("Edit Registry",  isOn: $permissions.editRegistry)
                    Toggle("Add Gifts",      isOn: $permissions.addGifts)
                    Toggle("Remove Gifts",   isOn: $permissions.removeGifts)
                } header: {
                    sectionHeader("REGISTRY")
                }

                // MARK: Guests
                Section {
                    Toggle("Invite Guests",  isOn: $permissions.inviteGuests)
                    Toggle("Manage RSVPs",   isOn: $permissions.manageRSVPs)
                } header: {
                    sectionHeader("GUESTS")
                }

                // MARK: Timeline
                Section {
                    Toggle("Edit Timeline",   isOn: $permissions.editTimeline)
                    Toggle("Send Reminders",  isOn: $permissions.sendReminders)
                } header: {
                    sectionHeader("EVENT TIMELINE")
                }

                // MARK: Contributions
                Section {
                    Toggle("View Contributions",  isOn: $permissions.viewContributions)
                    Toggle("Manage Group Gifts",  isOn: $permissions.manageGroupGifts)
                } header: {
                    sectionHeader("CONTRIBUTIONS")
                }

                // MARK: Danger Zone
                Section {
                    Button(role: .destructive) {
                        showRemoveAlert = true
                    } label: {
                        HStack {
                            Spacer()
                            Text("Remove Collaborator")
                                .font(AppTypography.bodyMedium)
                            Spacer()
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .tint(AppColors.accentRed)
            .navigationTitle("\(role.rawValue) Access")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(AppColors.secondaryGray)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") { dismiss() }
                        .foregroundStyle(AppColors.accentRed)
                        .fontWeight(.semibold)
                }
            }
            .alert("Remove Collaborator?", isPresented: $showRemoveAlert) {
                Button("Remove", role: .destructive) { dismiss() }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("They will lose all access to this event. This cannot be undone.")
            }
        }
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(AppTypography.caption1Medium)
            .tracking(1.5)
            .foregroundStyle(AppColors.secondaryGray)
    }
}

#Preview("Manage Access") {
    @Previewable @State var perms = CollaboratorRole.partner.defaultPermissions
    ManageAccessView(role: .partner, permissions: $perms)
}
