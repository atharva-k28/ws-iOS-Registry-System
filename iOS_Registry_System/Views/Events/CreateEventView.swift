//
//  CreateEventView.swift
//  iOS_Registry_System
//
//  Premium single-scroll Create Event flow.
//  Matches the Apple-inspired reference layout:
//    · event type grid
//    · horizontal theme carousel
//    · date picker row
//    · collaborator invitation card
//    · sticky Continue CTA
//

import SwiftUI

// MARK: - Event Type Item

private struct CreateEventType: Identifiable {
    let id = UUID()
    let type: EventType
    let icon: String
    let label: String

    static let all: [CreateEventType] = [
        .init(type: .wedding,      icon: "heart",         label: "Wedding"),
        .init(type: .housewarming, icon: "house",         label: "Housewarming"),
        .init(type: .specialEvent, icon: "gift",          label: "Anniversary"),
        .init(type: .babyShower,   icon: "stroller",      label: "Baby"),
        .init(type: .birthday,     icon: "graduationcap", label: "Graduation"),
        .init(type: .specialEvent, icon: "sparkles",      label: "Other"),
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
    .init(title: "Italian Dinner Party",  subtitle: "Terracotta, candlelight, pasta",  imageUrl: "https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=600&q=80"),
    .init(title: "Scandinavian Minimal",  subtitle: "Pale wood, calm whites",          imageUrl: "https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=600&q=80"),
    .init(title: "Garden Party",          subtitle: "Blooms, linen, open air",          imageUrl: "https://images.unsplash.com/photo-1416879595882-3373a0480b5b?w=600&q=80"),
    .init(title: "Modern Coastal",        subtitle: "Blue tones, natural light",        imageUrl: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=600&q=80"),
]

// MARK: - Create Event View

struct CreateEventView: View {

    @Environment(\.dismiss) private var dismiss

    // Form state
    @State private var selectedType: EventType? = .wedding
    @State private var selectedTheme: UUID?      = nil
    @State private var eventDate                  = Date()
    @State private var eventTitle                 = ""
    @State private var isPublic                   = true
    @State private var showDatePicker             = false

    // Collaborator flow
    @State private var collaborators: [Collaborator]   = []
    @State private var showRolePicker                  = false
    @State private var showInviteFlow                  = false
    @State private var pendingRole: CollaboratorRole?  = nil

    var body: some View {
        ZStack(alignment: .bottom) {
            // Main scrollable content
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: AppSpacing.xxl) {

                    // ── Header ──────────────────────────────────────
                    VStack(alignment: .leading, spacing: 6) {
                        Text("NEW EVENT")
                            .font(AppTypography.caption1Medium)
                            .tracking(2)
                            .foregroundStyle(AppColors.secondaryGray)

                        Text("What are we\ncelebrating?")
                            .font(.system(size: 34, weight: .regular, design: .serif))
                            .foregroundStyle(AppColors.primaryText)
                    }

                    // ── Event Type Grid ──────────────────────────────
                    LazyVGrid(
                        columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())],
                        spacing: AppSpacing.sm
                    ) {
                        ForEach(CreateEventType.all) { item in
                            eventTypeCard(item: item)
                        }
                    }

                    // ── Theme Carousel ───────────────────────────────
                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        Text("CHOOSE A THEME")
                            .font(AppTypography.caption1Medium)
                            .tracking(2)
                            .foregroundStyle(AppColors.secondaryGray)

                        Text("Set the mood.")
                            .font(.system(size: 28, weight: .regular, design: .serif))
                            .foregroundStyle(AppColors.primaryText)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: AppSpacing.sm) {
                                ForEach(themeOptions) { theme in
                                    themeCard(theme: theme)
                                }
                            }
                            .padding(.horizontal, AppSpacing.screenHorizontal)
                        }
                        .padding(.horizontal, -AppSpacing.screenHorizontal)
                    }

                    // ── Date Row ─────────────────────────────────────
                    VStack(spacing: AppSpacing.sm) {
                        HStack {
                            Text("Event date")
                                .font(AppTypography.body)
                                .foregroundStyle(AppColors.secondaryGray)
                            Spacer()
                            DatePicker("", selection: $eventDate, displayedComponents: .date)
                                .datePickerStyle(.compact)
                                .labelsHidden()
                                .tint(AppColors.accentRed)
                        }
                        .padding(.horizontal, AppSpacing.md)
                        .padding(.vertical, AppSpacing.md)
                        .background(AppColors.white)
                        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.lg))
                        .softShadow()

                        // ── Collaborator Card ─────────────────────────────
                        collaboratorSection
                    }

                    // Bottom clearance for sticky CTA
                    Color.clear.frame(height: 180)
                }
                .padding(.horizontal, AppSpacing.screenHorizontal)
                .padding(.top, AppSpacing.md)
            }

            // ── Sticky Continue Button ───────────────────────────
            continueButton
        }
        .appBackground()
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            // Back / close button (left)
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(AppColors.primaryText)
                        .frame(width: 36, height: 36)
                        .background(
                            Circle()
                                .fill(AppColors.white)
                                .shadow(color: .black.opacity(0.1), radius: 8, y: 2)
                        )
                }
                .buttonStyle(.plain)
            }
            // Step label (center)
            ToolbarItem(placement: .principal) {
                Text("CREATE EVENT")
                    .font(AppTypography.caption1Medium)
                    .tracking(1.5)
                    .foregroundStyle(AppColors.secondaryGray)
            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
        // Role picker sheet (Screen 2)
        .sheet(isPresented: $showRolePicker) {
            CollaboratorTypeSheet(selectedRole: $pendingRole) { role in
                pendingRole = role
                showRolePicker = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    showInviteFlow = true
                }
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(32)
        }
        // Invite flow sheet (Screen 3)
        .sheet(isPresented: $showInviteFlow) {
            if let role = pendingRole {
                InviteCollaboratorView(role: role) { collaborator in
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        collaborators.append(collaborator)
                    }
                }
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(32)
            }
        }
    }

    // MARK: - Event Type Card

    private func eventTypeCard(item: CreateEventType) -> some View {
        let isSelected = selectedType == item.type

        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedType = item.type
            }
        } label: {
            VStack(spacing: 10) {
                Image(systemName: item.icon)
                    .font(.system(size: 26))
                    .foregroundStyle(isSelected ? AppColors.white : AppColors.secondaryGray)
                Text(item.label)
                    .font(AppTypography.caption1Medium)
                    .foregroundStyle(isSelected ? AppColors.white : AppColors.primaryText)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppSpacing.lg)
            .background(
                RoundedRectangle(cornerRadius: AppCornerRadius.lg)
                    .fill(isSelected ? AnyShapeStyle(AppColors.primaryText) : AnyShapeStyle(AppColors.white))
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppCornerRadius.lg)
                    .stroke(isSelected ? Color.clear : Color.black.opacity(0.07), lineWidth: 1)
            )
            .shadow(
                color: isSelected ? Color.black.opacity(0.15) : Color.black.opacity(0.04),
                radius: isSelected ? 10 : 4,
                y: isSelected ? 4 : 2
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Theme Card

    private func themeCard(theme: ThemeOption) -> some View {
        let isSelected = selectedTheme == theme.id

        return Button {
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
                .frame(width: 200, height: 140)
                .clipped()

                VStack(alignment: .leading, spacing: 3) {
                    Text(theme.title)
                        .font(AppTypography.bodyMedium)
                        .foregroundStyle(AppColors.primaryText)
                        .lineLimit(1)
                    Text(theme.subtitle)
                        .font(AppTypography.caption1)
                        .foregroundStyle(AppColors.secondaryGray)
                        .lineLimit(2)
                }
                .padding(.horizontal, AppSpacing.sm)
                .padding(.vertical, AppSpacing.sm)
            }
            .frame(width: 200)
            .background(AppColors.white)
            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: AppCornerRadius.lg)
                    .stroke(isSelected ? AppColors.primaryText : Color.clear, lineWidth: 2)
            )
            .shadow(
                color: isSelected ? Color.black.opacity(0.12) : Color.black.opacity(0.05),
                radius: isSelected ? 12 : 4,
                y: isSelected ? 4 : 2
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Collaborator Section

    private var collaboratorSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            if collaborators.isEmpty {
                // Empty invitation card
                VStack(alignment: .leading, spacing: AppSpacing.md) {
                    HStack(alignment: .top, spacing: AppSpacing.sm) {
                        Image(systemName: "person.2.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(AppColors.secondaryGray.opacity(0.6))
                            .frame(width: 32)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Planning together?")
                                .font(AppTypography.bodyMedium)
                                .foregroundStyle(AppColors.primaryText)
                            Text("Invite a partner, family member, or planner to help organize this event.")
                                .font(AppTypography.caption1)
                                .foregroundStyle(AppColors.secondaryGray)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }

                    Button {
                        showRolePicker = true
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "plus")
                                .font(.system(size: 13, weight: .bold))
                            Text("Add collaborator")
                                .font(AppTypography.buttonSmall)
                        }
                        .foregroundStyle(AppColors.primaryText)
                        .frame(maxWidth: .infinity)
                        .frame(height: 42)
                        .background(
                            RoundedRectangle(cornerRadius: AppCornerRadius.md)
                                .stroke(Color.black.opacity(0.14), lineWidth: 1.5)
                        )
                    }
                    .buttonStyle(.plain)
                }
                .padding(AppSpacing.md)
                .background(AppColors.white)
                .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.lg))
                .overlay(
                    RoundedRectangle(cornerRadius: AppCornerRadius.lg)
                        .stroke(Color.black.opacity(0.06), lineWidth: 1)
                )
                .softShadow()

                Text("You can manage permissions later.")
                    .font(AppTypography.caption1)
                    .foregroundStyle(AppColors.secondaryGray)
                    .padding(.horizontal, 4)

            } else {
                // Collaborator cards
                ForEach(collaborators) { c in
                    CollaboratorCard(collaborator: c)
                }

                // Add another
                Button {
                    showRolePicker = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "plus")
                            .font(.system(size: 12, weight: .bold))
                        Text("Add another")
                            .font(AppTypography.caption1Medium)
                    }
                    .foregroundStyle(AppColors.secondaryGray)
                    .frame(maxWidth: .infinity)
                    .frame(height: 38)
                    .background(
                        RoundedRectangle(cornerRadius: AppCornerRadius.md)
                            .stroke(Color.black.opacity(0.08), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Continue Button

    private var continueButton: some View {
        VStack(spacing: 0) {
            // Fade gradient above button
            LinearGradient(
                colors: [Color.clear, AppColors.background],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 24)
            .allowsHitTesting(false)

            Button { dismiss() } label: {
                Text("Continue")
                    .font(AppTypography.buttonLarge)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(AppColors.accentRed)
                    .clipShape(Capsule())
                    .shadow(color: AppColors.accentRed.opacity(0.35), radius: 16, y: 6)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.bottom, AppSpacing.lg + 80) // Push above custom tab bar
            .background(AppColors.background)
        }
    }
}

// MARK: - Preview

#Preview("Create Event") {
    NavigationStack {
        CreateEventView()
    }
}
