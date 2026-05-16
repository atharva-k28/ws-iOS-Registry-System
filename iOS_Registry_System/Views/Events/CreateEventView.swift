//
//  CreateEventView.swift
//  iOS_Registry_System
//
//  Multi-step event creation flow:
//  Step 1 → Event Type
//  Step 2 → Event Details
//  Step 3 → Theme & Mood
//  Step 4 → Review & Publish
//

import SwiftUI

// MARK: - Create Event Type

private struct CreateEventType: Identifiable {
    let id = UUID()
    let type: EventType
    let icon: String
    let label: String

    static let all: [CreateEventType] = [
        .init(type: .wedding, icon: "heart", label: "Wedding"),
        .init(type: .housewarming, icon: "house", label: "Housewarming"),
        .init(type: .specialEvent, icon: "gift", label: "Anniversary"),
        .init(type: .babyShower, icon: "stroller", label: "Baby"),
        .init(type: .birthday, icon: "graduationcap", label: "Graduation"),
        .init(type: .specialEvent, icon: "sparkles", label: "Other"),
    ]
}

// MARK: - Theme Option

private struct ThemeOption: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let imageUrl: String
}

private let themeOptions: [ThemeOption] = [
    .init(title: "Italian Dinner Party", subtitle: "Terracotta, candlelight, pasta", imageUrl: "https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=400&q=80"),
    .init(title: "Scandinavian Minimal", subtitle: "Pale wood, calm whites", imageUrl: "https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=400&q=80"),
    .init(title: "Garden Party", subtitle: "Blooms, linen, open air", imageUrl: "https://images.unsplash.com/photo-1416879595882-3373a0480b5b?w=400&q=80"),
    .init(title: "Modern Coastal", subtitle: "Blue tones, natural light", imageUrl: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&q=80"),
]

// MARK: - Create Event View

struct CreateEventView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var currentStep = 0
    @State private var selectedType: EventType? = .wedding
    @State private var selectedTheme: UUID? = nil
    @State private var eventTitle = ""
    @State private var eventDate = Date()
    @State private var partnerName = ""
    @State private var isPublic = true

    private let totalSteps = 4

    var body: some View {
        VStack(spacing: 0) {
            // Progress dots
            progressIndicator
                .padding(.top, AppSpacing.sm)

            // Step content
            TabView(selection: $currentStep) {
                step1EventType.tag(0)
                step2Details.tag(1)
                step3Theme.tag(2)
                step4Review.tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut(duration: 0.3), value: currentStep)

            // Bottom CTA
            bottomButton
        }
        .appBackground()
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    if currentStep > 0 {
                        withAnimation { currentStep -= 1 }
                    } else {
                        dismiss()
                    }
                } label: {
                    Image(systemName: currentStep > 0 ? "chevron.left" : "xmark")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(AppColors.primaryText)
                        .frame(width: 36, height: 36)
                        .background(
                            Circle()
                                .fill(AppColors.white)
                                .shadow(color: .black.opacity(0.08), radius: 6, y: 2)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
    }

    // MARK: - Progress

    private var progressIndicator: some View {
        HStack(spacing: 6) {
            ForEach(0..<totalSteps, id: \.self) { step in
                Capsule()
                    .fill(step <= currentStep ? AppColors.primaryText : AppColors.backgroundGray)
                    .frame(width: step == currentStep ? 24 : 8, height: 4)
                    .animation(.spring(response: 0.3), value: currentStep)
            }
        }
        .padding(.bottom, AppSpacing.sm)
    }

    // MARK: - Step 1: Event Type

    private var step1EventType: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: AppSpacing.xl) {
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    Text("NEW EVENT")
                        .font(AppTypography.caption1Medium)
                        .tracking(2)
                        .foregroundStyle(AppColors.secondaryGray)

                    Text("What are we\ncelebrating?")
                        .font(.system(size: 32, weight: .regular, design: .serif))
                        .foregroundStyle(AppColors.primaryText)
                }

                LazyVGrid(
                    columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())],
                    spacing: AppSpacing.sm
                ) {
                    ForEach(CreateEventType.all) { item in
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedType = item.type
                            }
                        } label: {
                            VStack(spacing: 8) {
                                Image(systemName: item.icon)
                                    .font(.system(size: 24))
                                    .foregroundStyle(selectedType == item.type ? AppColors.primaryText : AppColors.secondaryGray)
                                Text(item.label)
                                    .font(AppTypography.caption1Medium)
                                    .foregroundStyle(AppColors.primaryText)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, AppSpacing.lg)
                            .background(
                                RoundedRectangle(cornerRadius: AppCornerRadius.md)
                                    .fill(AppColors.white)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: AppCornerRadius.md)
                                            .stroke(selectedType == item.type ? AppColors.primaryText : Color.black.opacity(0.06), lineWidth: selectedType == item.type ? 2 : 1)
                                    )
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }

                Color.clear.frame(height: AppSpacing.xxl)
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.top, AppSpacing.md)
        }
    }

    // MARK: - Step 2: Details

    private var step2Details: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: AppSpacing.xl) {
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    Text("EVENT DETAILS")
                        .font(AppTypography.caption1Medium)
                        .tracking(2)
                        .foregroundStyle(AppColors.secondaryGray)
                    Text("Tell us a little\nmore.")
                        .font(.system(size: 32, weight: .regular, design: .serif))
                        .foregroundStyle(AppColors.primaryText)
                }

                VStack(spacing: AppSpacing.md) {
                    formField(title: "Event Title", placeholder: "Olivia & James's Wedding", text: $eventTitle)
                    formField(title: "Partner Name (optional)", placeholder: "James", text: $partnerName)

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Event Date")
                            .font(AppTypography.footnoteSemibold)
                            .foregroundStyle(AppColors.secondaryGray)
                        DatePicker("", selection: $eventDate, displayedComponents: .date)
                            .datePickerStyle(.compact)
                            .labelsHidden()
                            .padding(AppSpacing.md)
                            .background(AppColors.white)
                            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.md))
                            .softShadow()
                    }

                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Public Event")
                                .font(AppTypography.bodyMedium)
                                .foregroundStyle(AppColors.primaryText)
                            Text("Guests can discover your registry")
                                .font(AppTypography.caption1)
                                .foregroundStyle(AppColors.secondaryGray)
                        }
                        Spacer()
                        Toggle("", isOn: $isPublic)
                            .labelsHidden()
                            .tint(AppColors.accentRed)
                    }
                    .padding(AppSpacing.md)
                    .background(AppColors.white)
                    .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.md))
                    .softShadow()
                }

                Color.clear.frame(height: AppSpacing.xxl)
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.top, AppSpacing.md)
        }
    }

    private func formField(title: String, placeholder: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(AppTypography.footnoteSemibold)
                .foregroundStyle(AppColors.secondaryGray)
            TextField(placeholder, text: text)
                .font(AppTypography.body)
                .foregroundStyle(AppColors.primaryText)
                .padding(AppSpacing.md)
                .background(AppColors.white)
                .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.md))
                .softShadow()
        }
    }

    // MARK: - Step 3: Theme

    private var step3Theme: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: AppSpacing.xl) {
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    Text("CHOOSE A THEME")
                        .font(AppTypography.caption1Medium)
                        .tracking(2)
                        .foregroundStyle(AppColors.secondaryGray)
                    Text("Set the mood.")
                        .font(.system(size: 32, weight: .regular, design: .serif))
                        .foregroundStyle(AppColors.primaryText)
                }

                LazyVGrid(
                    columns: [GridItem(.flexible()), GridItem(.flexible())],
                    spacing: AppSpacing.md
                ) {
                    ForEach(themeOptions) { theme in
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedTheme = theme.id
                            }
                        } label: {
                            VStack(alignment: .leading, spacing: 0) {
                                AsyncImage(url: URL(string: theme.imageUrl)) { img in
                                    img.resizable().aspectRatio(contentMode: .fill)
                                } placeholder: {
                                    Color(hex: "E8E2DC")
                                }
                                .frame(height: 130)
                                .clipped()

                                VStack(alignment: .leading, spacing: 3) {
                                    Text(theme.title)
                                        .font(AppTypography.bodyMedium)
                                        .foregroundStyle(AppColors.primaryText)
                                        .lineLimit(1)
                                    Text(theme.subtitle)
                                        .font(AppTypography.caption1)
                                        .foregroundStyle(AppColors.secondaryGray)
                                        .lineLimit(1)
                                }
                                .padding(AppSpacing.sm)
                            }
                            .background(AppColors.white)
                            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.lg))
                            .overlay(
                                RoundedRectangle(cornerRadius: AppCornerRadius.lg)
                                    .stroke(selectedTheme == theme.id ? AppColors.primaryText : Color.clear, lineWidth: 2)
                            )
                            .softShadow()
                        }
                        .buttonStyle(.plain)
                    }
                }

                Color.clear.frame(height: AppSpacing.xxl)
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.top, AppSpacing.md)
        }
    }

    // MARK: - Step 4: Review

    private var step4Review: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: AppSpacing.xl) {
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    Text("REVIEW")
                        .font(AppTypography.caption1Medium)
                        .tracking(2)
                        .foregroundStyle(AppColors.secondaryGray)
                    Text("Looking\nbeautiful.")
                        .font(.system(size: 32, weight: .regular, design: .serif))
                        .foregroundStyle(AppColors.primaryText)
                }

                // Summary card
                VStack(alignment: .leading, spacing: AppSpacing.md) {
                    HStack {
                        Text(eventTitle.isEmpty ? "Your Event" : eventTitle)
                            .font(AppTypography.headline)
                            .foregroundStyle(AppColors.primaryText)
                        Spacer()
                        Image(systemName: selectedType?.icon ?? "sparkles")
                            .font(.system(size: 20))
                            .foregroundStyle(AppColors.accentRed)
                    }

                    Divider()

                    detailRow(label: "Type", value: selectedType?.displayName ?? "—")
                    detailRow(label: "Date", value: eventDate.formattedLong)
                    detailRow(label: "Privacy", value: isPublic ? "Public" : "Private")
                    if !partnerName.isEmpty {
                        detailRow(label: "Partner", value: partnerName)
                    }
                }
                .padding(AppSpacing.lg)
                .background(AppColors.white)
                .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.lg))
                .softShadow()

                // AI suggestion
                SuggestionCard(
                    title: "Build your registry with AI",
                    subtitle: "Answer a quick style quiz and we'll curate items for you"
                )

                Color.clear.frame(height: AppSpacing.xxl)
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.top, AppSpacing.md)
        }
    }

    private func detailRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(AppTypography.footnote)
                .foregroundStyle(AppColors.secondaryGray)
            Spacer()
            Text(value)
                .font(AppTypography.bodyMedium)
                .foregroundStyle(AppColors.primaryText)
        }
    }

    // MARK: - Bottom Button

    private var bottomButton: some View {
        Button {
            if currentStep < totalSteps - 1 {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    currentStep += 1
                }
            } else {
                dismiss()
            }
        } label: {
            Text(currentStep == totalSteps - 1 ? "Publish Event" : "Continue")
                .font(AppTypography.buttonLarge)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(AppColors.accentRed)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .padding(.horizontal, AppSpacing.screenHorizontal)
        .padding(.bottom, AppSpacing.lg)
    }
}

// MARK: - Preview

#Preview("Create Event") {
    NavigationStack {
        CreateEventView()
    }
}
