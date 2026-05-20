import SwiftUI

struct SelectRegistrySheet: View {
    let product: Product
    var onSelect: (Event) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var events: [Event] = []
    @State private var isLoading = true
    
    var body: some View {
        NavigationStack {
            VStack {
                if isLoading {
                    ProgressView()
                } else if events.isEmpty {
                    VStack(spacing: AppSpacing.md) {
                        Image(systemName: "list.clipboard")
                            .font(.system(size: 40))
                            .foregroundColor(AppColors.secondaryGray)
                        Text("No registries found")
                            .font(AppTypography.bodyMedium)
                            .foregroundColor(AppColors.secondaryGray)
                    }
                } else {
                    List {
                        ForEach(events) { event in
                            Button {
                                onSelect(event)
                                dismiss()
                            } label: {
                                HStack(spacing: AppSpacing.md) {
                                    ZStack {
                                        Circle()
                                            .fill(AppColors.backgroundGray)
                                            .frame(width: 48, height: 48)
                                        Image(systemName: EventType(rawValue: event.eventType)?.icon ?? "star.fill")
                                            .font(.system(size: 20))
                                            .foregroundColor(AppColors.primaryDark)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(event.title)
                                            .font(AppTypography.bodyMedium)
                                            .foregroundColor(AppColors.primaryText)
                                        Text((EventType(rawValue: event.eventType)?.displayName ?? event.eventType).capitalized)
                                            .font(AppTypography.caption1)
                                            .foregroundColor(AppColors.secondaryGray)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(AppColors.secondaryGray.opacity(0.5))
                                }
                                .padding(.vertical, AppSpacing.xs)
                            }
                            .buttonStyle(.plain)
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                        }
                    }
                    .listStyle(.plain)
                    .padding(.top, AppSpacing.sm)
                }
            }
            .navigationTitle("Select Registry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(AppColors.primaryDark)
                }
            }
            .appBackground()
            .task {
                await loadEvents()
            }
        }
    }
    
    private func loadEvents() async {
        do {
            events = try await EventService.shared.fetchMyEvents()
        } catch {
            print("Failed to fetch events: \(error)")
        }
        isLoading = false
    }
}
