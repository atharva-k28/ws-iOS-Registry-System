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
    let name: String
    let avatar: String
    let giftName: String
    let giftImage: String
    let amount: Int
    var noteText: String
    var isSent: Bool
}

// MARK: - Thank You Note Sheet

struct ThankYouNoteSheet: View {

    @Environment(\.dismiss) private var dismiss
    @State private var notes: [ContributorNote] = [
        ContributorNote(name: "Maya Chen",    avatar: "https://i.pravatar.cc/150?img=5",  giftName: "Espresso Machine",   giftImage: "https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=300", amount: 50,  noteText: "", isSent: false),
        ContributorNote(name: "Liam Carter",  avatar: "https://i.pravatar.cc/150?img=8",  giftName: "Dinner Set",         giftImage: "https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=300", amount: 80,  noteText: "", isSent: false),
        ContributorNote(name: "Sofia Rivera", avatar: "https://i.pravatar.cc/150?img=9",  giftName: "Kitchen Stand Mixer",giftImage: "https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=300", amount: 120, noteText: "", isSent: false),
        ContributorNote(name: "James Park",   avatar: "https://i.pravatar.cc/150?img=14", giftName: "Dutch Oven",         giftImage: "https://images.unsplash.com/photo-1513558161293-cdaf765ed2fd?w=300", amount: 60,  noteText: "", isSent: false),
    ]
    @State private var selectedIndex = 0
    @State private var allSent = false

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

                // Progress chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: AppSpacing.sm) {
                        ForEach(notes.indices, id: \.self) { i in
                            Button {
                                withAnimation(.spring(response: 0.3)) { selectedIndex = i }
                            } label: {
                                HStack(spacing: 5) {
                                    if notes[i].isSent {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 12))
                                            .foregroundStyle(Color(hex: "34C759"))
                                    }
                                    Text(String(notes[i].name.split(separator: " ").first ?? ""))
                                        .font(AppTypography.caption1Medium)
                                        .foregroundStyle(selectedIndex == i ? .white : AppColors.primaryText)
                                }
                                .padding(.horizontal, AppSpacing.sm)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule()
                                        .fill(selectedIndex == i ? AppColors.primaryText : AppColors.white)
                                )
                                .overlay(
                                    Capsule()
                                        .stroke(selectedIndex == i ? Color.clear : Color.black.opacity(0.08), lineWidth: 1)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, AppSpacing.screenHorizontal)
                }
                .padding(.horizontal, -AppSpacing.screenHorizontal)

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
                    }

                    // Editable note text
                    ZStack(alignment: .topLeading) {
                        if notes[selectedIndex].noteText.isEmpty {
                            Text("\"\(currentNote.name.split(separator: " ").first ?? "") — your contribution to our \(currentNote.giftName.lowercased()) means the world. With so much love, Olivia & James ☕️\"")
                                .font(.system(size: 16, weight: .regular, design: .serif))
                                .foregroundStyle(AppColors.secondaryGray.opacity(0.6))
                                .italic()
                        }
                        TextEditor(text: $notes[selectedIndex].noteText)
                            .font(.system(size: 16, weight: .regular, design: .serif))
                            .foregroundStyle(AppColors.primaryText)
                            .scrollContentBackground(.hidden)
                            .frame(minHeight: 80)
                    }

                    Divider()

                    // Gift row
                    HStack(spacing: AppSpacing.sm) {
                        AsyncImage(url: URL(string: currentNote.giftImage)) { img in
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

                // Delivery channel
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    Text("SEND VIA")
                        .font(AppTypography.caption1Medium)
                        .tracking(1.5)
                        .foregroundStyle(AppColors.secondaryGray)
                    HStack(spacing: AppSpacing.sm) {
                        channelChip(icon: "envelope.fill", label: "Email")
                        channelChip(icon: "message.fill",  label: "iMessage")
                        channelChip(icon: "square.and.arrow.up", label: "Share")
                    }
                }

                Color.clear.frame(height: 100)
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.top, AppSpacing.md)
        }
        .appBackground()
        .safeAreaInset(edge: .bottom) {
            HStack(spacing: AppSpacing.sm) {
                Button {
                    // Skip
                    advanceOrFinish()
                } label: {
                    Text("Skip")
                        .font(AppTypography.buttonMedium)
                        .foregroundStyle(AppColors.secondaryGray)
                        .frame(height: 54)
                        .frame(maxWidth: 90)
                        .background(AppColors.white)
                        .clipShape(Capsule())
                        .softShadow()
                }
                .buttonStyle(.plain)

                Button {
                    withAnimation(.spring(response: 0.3)) {
                        notes[selectedIndex].isSent = true
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
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.vertical, AppSpacing.md)
            .background(AppColors.background.opacity(0.96))
        }
    }

    @State private var selectedChannel = "Email"
    private func channelChip(icon: String, label: String) -> some View {
        let isSelected = selectedChannel == label
        return Button { selectedChannel = label } label: {
            HStack(spacing: 5) {
                Image(systemName: icon).font(.system(size: 13))
                Text(label).font(AppTypography.caption1Medium)
            }
            .foregroundStyle(isSelected ? .white : AppColors.primaryText)
            .padding(.horizontal, AppSpacing.sm)
            .padding(.vertical, 10)
            .background(Capsule().fill(isSelected ? AppColors.primaryText : AppColors.white))
            .overlay(Capsule().stroke(isSelected ? Color.clear : Color.black.opacity(0.08), lineWidth: 1))
        }
        .buttonStyle(.plain)
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
