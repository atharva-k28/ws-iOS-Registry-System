//
//  ThankYouNoteSheet.swift
//  iOS_Registry_System
//
//  Luxury thank-you note composer — matches the reference design:
//  avatar · serif headline · personal note card · gift item ·
//  emoji reactions · send button.
//

import SwiftUI

// MARK: - Contributor Note Model

private struct ContributorNote: Identifiable, Equatable {
    let id = UUID()
    let guestId: UUID?
    let name: String
    let avatar: String
    let giftName: String
    let giftImage: String?
    let amount: Int
    var noteText: String
    var isSent: Bool
}

// MARK: - Thank You Note Sheet

struct ThankYouNoteSheet: View {

    @Environment(\.dismiss) private var dismiss
    @State private var notes: [ContributorNote]
    @State private var selectedIndex = 0
    @State private var allSent = false
    @State private var isDraftingNote = false
    let eventTitle: String
    let organizerName: String

    init(eventTitle: String = "our event", organizerName: String = "Olivia & James", thankYouNotes: [EventCommandCenterView.ThankYouNoteItem] = [], initialSelectedIndex: Int = 0) {
        self.eventTitle = eventTitle
        self.organizerName = organizerName
        let mapped = thankYouNotes.map { note in
            let firstName = note.guestName.split(separator: " ").first ?? "Friend"
            let defaultText = "\(firstName) — your contribution to our \(note.itemName.lowercased()) means the world. With so much love, \(organizerName) ☕️"
            return ContributorNote(
                guestId: note.guestId,
                name: note.guestName,
                avatar: note.guestAvatar ?? "https://i.pravatar.cc/150?img=5",
                giftName: note.itemName,
                giftImage: note.itemImage,
                amount: Int(note.amount),
                noteText: defaultText,
                isSent: false
            )
        }
        self._notes = State(initialValue: mapped.isEmpty ? [
            ContributorNote(guestId: nil, name: "Maya Chen",    avatar: "https://i.pravatar.cc/150?img=5",  giftName: "Espresso Machine",   giftImage: "https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=300", amount: 50,  noteText: "Maya — your contribution to our espresso machine means the world. With so much love, \(organizerName) ☕️", isSent: false),
            ContributorNote(guestId: nil, name: "Liam Carter",  avatar: "https://i.pravatar.cc/150?img=8",  giftName: "Dinner Set",         giftImage: "https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=300", amount: 80,  noteText: "Liam — your contribution to our dinner set means the world. With so much love, \(organizerName) ☕️", isSent: false)
        ] : mapped)
        self._selectedIndex = State(initialValue: initialSelectedIndex)
    }

    private var currentNote: ContributorNote { notes[selectedIndex] }

    var body: some View {
        NavigationStack {
            Group {
                if allSent {
                    allSentView
                } else {
                    noteComposerView
                }
            }
            .navigationTitle("Thank-You Notes")
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

    // MARK: - Note Composer

    private var noteComposerView: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: AppSpacing.xl) {

                // Avatar + header
                VStack(spacing: AppSpacing.md) {
                    ZStack(alignment: .bottomTrailing) {
                        AsyncImage(url: URL(string: currentNote.avatar)) { img in
                            img.resizable().aspectRatio(contentMode: .fill)
                        } placeholder: { Circle().fill(AppColors.backgroundGray) }
                        .frame(width: 72, height: 72)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(AppColors.white, lineWidth: 3))
                        .shadow(color: .black.opacity(0.1), radius: 8, y: 4)

                        Circle()
                            .fill(AppColors.accentRed)
                            .frame(width: 20, height: 20)
                            .overlay(
                                Image(systemName: "heart.fill")
                                    .font(.system(size: 10))
                                    .foregroundStyle(.white)
                            )
                    }

                    VStack(spacing: 4) {
                        Text("A NOTE FROM YOU")
                            .font(AppTypography.caption1Medium)
                            .tracking(1.5)
                            .foregroundStyle(AppColors.secondaryGray)
                        Text("Thank you for being\npart of our journey.")
                            .font(.system(size: 26, weight: .regular, design: .serif))
                            .foregroundStyle(AppColors.primaryText)
                            .multilineTextAlignment(.center)
                    }
                }

                // Note card
                VStack(alignment: .leading, spacing: AppSpacing.md) {
                    HStack(spacing: 6) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 12))
                            .foregroundStyle(AppColors.accentRed)
                        Text("A PERSONAL NOTE")
                            .font(AppTypography.caption1Medium)
                            .tracking(1.5)
                            .foregroundStyle(AppColors.secondaryGray)
                            
                        Spacer()
                        
                        if isDraftingNote {
                            ProgressView()
                                .scaleEffect(0.6)
                        } else {
                            Button {
                                draftNoteWithAI()
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: "wand.and.stars")
                                    Text("AI Draft")
                                }
                                .font(AppTypography.caption1Medium)
                                .foregroundStyle(AppColors.accentRed)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(AppColors.accentRed.opacity(0.1))
                                .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    // Editable note text
                    TextEditor(text: $notes[selectedIndex].noteText)
                        .font(.system(size: 16, weight: .regular, design: .serif))
                        .foregroundStyle(AppColors.primaryText)
                        .scrollContentBackground(.hidden)
                        .frame(minHeight: 80)

                    Divider()

                    // Gift row
                    HStack(spacing: AppSpacing.sm) {
                        AsyncImage(url: URL(string: currentNote.giftImage ?? "")) { img in
                            img.resizable().aspectRatio(contentMode: .fill)
                        } placeholder: { Color(hex: "E8E2DC") }
                        .frame(width: 52, height: 52)
                        .clipShape(RoundedRectangle(cornerRadius: 8))

                        VStack(alignment: .leading, spacing: 2) {
                            Text(currentNote.giftName)
                                .font(AppTypography.bodyMedium)
                                .foregroundStyle(AppColors.primaryText)
                            Text("Your contribution: $\(currentNote.amount)")
                                .font(AppTypography.caption1)
                                .foregroundStyle(AppColors.secondaryGray)
                        }
                        Spacer()
                        Image(systemName: "heart.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(AppColors.accentRed)
                    }
                }
                .padding(AppSpacing.lg)
                .background(AppColors.white)
                .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.lg))
                .softShadow()

                Color.clear.frame(height: 40)
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.top, AppSpacing.md)
        }
        .appBackground()
        .safeAreaInset(edge: .bottom) {
            Button {
                withAnimation(.spring(response: 0.3)) {
                    notes[selectedIndex].isSent = true
                }
                
                // Send notification
                if let guestId = notes[selectedIndex].guestId {
                    Task {
                        try? await NotificationService.shared.createNotification(
                            userId: guestId,
                            type: "thank_you",
                            title: "New Thank-You Note",
                            body: "You received a thank-you note from \(organizerName)."
                        )
                    }
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    advanceOrFinish()
                }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "paperplane.fill")
                    Text("Send Note")
                }
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
            .background(AppColors.background.opacity(0.96))
        }
    }

    private func advanceOrFinish() {
        let nextUnsent = notes.indices.first(where: { !notes[$0].isSent && $0 != selectedIndex })
        if let next = nextUnsent {
            withAnimation(.spring(response: 0.4)) { selectedIndex = next }
        } else if notes.allSatisfy({ $0.isSent || $0 == notes[selectedIndex] }) {
            withAnimation { allSent = true }
        } else {
            dismiss()
        }
    }
    
    private func draftNoteWithAI() {
        let noteIndex = selectedIndex
        isDraftingNote = true
        
        Task {
            do {
                let note = notes[noteIndex]
                let aiDraft = try await AIService.shared.draftThankYouNote(
                    guestName: note.name,
                    productName: note.giftName,
                    occasion: "\(eventTitle) hosted by \(organizerName)",
                    tone: "warm, grateful, and elegant, correctly signed from the organizer \(organizerName)"
                )
                await MainActor.run {
                    withAnimation {
                        notes[noteIndex].noteText = aiDraft
                    }
                    isDraftingNote = false
                }
            } catch {
                print("❌ Failed to draft note with AI: \(error)")
                await MainActor.run {
                    isDraftingNote = false
                }
            }
        }
    }

    // MARK: - All Sent

    private var allSentView: some View {
        VStack(spacing: AppSpacing.xl) {
            Spacer()
            ZStack {
                Circle().fill(AppColors.accentRed.opacity(0.08)).frame(width: 110, height: 110)
                Circle().fill(AppColors.accentRed.opacity(0.15)).frame(width: 80, height: 80)
                Image(systemName: "heart.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(AppColors.accentRed)
            }

            VStack(spacing: 8) {
                Text("Thank-you notes sent.")
                    .font(.system(size: 28, weight: .regular, design: .serif))
                    .foregroundStyle(AppColors.primaryText)
                Text("Your contributors will feel the love.")
                    .font(AppTypography.footnote)
                    .foregroundStyle(AppColors.secondaryGray)
            }

            // Summary
            VStack(spacing: 8) {
                ForEach(notes) { note in
                    HStack {
                        AsyncImage(url: URL(string: note.avatar)) { img in
                            img.resizable().aspectRatio(contentMode: .fill)
                        } placeholder: { Circle().fill(AppColors.backgroundGray) }
                        .frame(width: 32, height: 32).clipShape(Circle())

                        Text(note.name).font(AppTypography.bodyMedium).foregroundStyle(AppColors.primaryText)
                        Spacer()
                        Image(systemName: note.isSent ? "checkmark.circle.fill" : "minus.circle")
                            .foregroundStyle(note.isSent ? Color(hex: "34C759") : AppColors.secondaryGray)
                    }
                    .padding(AppSpacing.sm)
                    .background(AppColors.white)
                    .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.sm))
                }
            }
            .padding(AppSpacing.md)
            .background(AppColors.backgroundGray)
            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.lg))

            Spacer()
            Button { dismiss() } label: {
                Text("Done")
                    .font(AppTypography.buttonLarge).foregroundStyle(.white)
                    .frame(maxWidth: .infinity).frame(height: 54)
                    .background(AppColors.primaryText).clipShape(Capsule())
            }
            .buttonStyle(.plain)
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.bottom, AppSpacing.xxl)
        }
        .padding(.horizontal, AppSpacing.screenHorizontal)
        .appBackground()
    }
}
