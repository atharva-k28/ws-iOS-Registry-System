//
//  MemoryCardView.swift
//  iOS_Registry_System
//
//  Memory Card View
//

import SwiftUI

struct MemoryCardView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedCardTheme: Color = Color(red: 0.96, green: 0.93, blue: 0.88) // Default beige
    
    let themes: [Color] = [
        Color(red: 0.96, green: 0.93, blue: 0.88), // Beige
        Color(red: 0.93, green: 0.74, blue: 0.74), // Pink
        Color(red: 0.23, green: 0.21, blue: 0.20), // Dark
        Color(red: 0.78, green: 0.85, blue: 0.76)  // Light Green
    ]
    
    var isDarkTheme: Bool {
        selectedCardTheme == themes[2]
    }
    
    var body: some View {
        ZStack {
            AppColors.primaryDark.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Main Memory Card
                ScrollView(.vertical, showsIndicators: false) {
                    memoryCard
                        .padding(.top, AppSpacing.lg)
                        .padding(.horizontal, AppSpacing.screenHorizontal)
                }
                
                // Bottom Controls
                bottomControls
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(AppColors.white)
                        .frame(width: 36, height: 36)
                        .background(
                            Circle()
                                .fill(Color.white.opacity(0.15))
                                .shadow(color: .black.opacity(0.08), radius: 8, y: 2)
                        )
                }
                .buttonStyle(.plain)
            }
            ToolbarItem(placement: .principal) {
                Text("MEMORY CARD")
                    .font(AppTypography.caption1Medium)
                    .tracking(1.5)
                    .foregroundColor(AppColors.secondaryGray)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {}) {
                    Image(systemName: "square.and.arrow.down")
                        .foregroundColor(AppColors.white)
                        .frame(width: 40, height: 40)
                        .background(Color.white.opacity(0.15))
                        .clipShape(Circle())
                }
            }
        }
    }
    
    // MARK: - Subviews
    
    private var memoryCard: some View {
        VStack(spacing: 0) {
            // Header Image
            ZStack(alignment: .topLeading) {
                AsyncImage(url: URL(string: "https://images.unsplash.com/photo-1511795409834-ef04bbd61622?w=800")) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Color.gray.opacity(0.3)
                }
                .frame(height: 200)
                .clipped()
                
                Text("A keepsake")
                    .font(.system(size: 14, weight: .medium, design: .serif))
                    .italic()
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.white.opacity(0.9))
                    .clipShape(Capsule())
                    .padding(16)
            }
            
            // Content
            VStack(spacing: AppSpacing.lg) {
                VStack(spacing: AppSpacing.xs) {
                    Text("JUNE 14, 2026")
                        .font(AppTypography.caption1Medium)
                        .tracking(1.5)
                        .foregroundColor(isDarkTheme ? .white.opacity(0.7) : AppColors.secondaryGray)
                    
                    Text("Emma & Noah's\nWedding")
                        .font(.system(size: 32, weight: .regular, design: .serif))
                        .multilineTextAlignment(.center)
                        .foregroundColor(isDarkTheme ? .white : AppColors.primaryText)
                    
                    Text("\"Celebrating meaningful moments,\ntogether.\"")
                        .font(.system(size: 16, weight: .regular, design: .serif))
                        .italic()
                        .multilineTextAlignment(.center)
                        .foregroundColor(isDarkTheme ? .white.opacity(0.8) : AppColors.secondaryGray)
                        .padding(.top, 4)
                }
                .padding(.top, AppSpacing.xl)
                
                // 3 Images
                HStack(spacing: AppSpacing.sm) {
                    ForEach(0..<3) { i in
                        AsyncImage(url: URL(string: "https://images.unsplash.com/photo-\(1500000000000 + i)?w=200")) { image in
                            image.resizable().scaledToFill()
                        } placeholder: {
                            Color.gray.opacity(0.3)
                        }
                        .frame(width: 80, height: 100)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white, lineWidth: 3)
                        )
                        .rotationEffect(.degrees(i == 0 ? -5 : i == 2 ? 5 : 0))
                        .offset(y: i == 1 ? 5 : 0)
                    }
                }
                .padding(.vertical, AppSpacing.md)
                
                // Featured Gift
                VStack(spacing: 4) {
                    Text("FEATURED GIFT")
                        .font(AppTypography.caption1Medium)
                        .tracking(1.5)
                        .foregroundColor(isDarkTheme ? .white.opacity(0.7) : AppColors.secondaryGray)
                    
                    Text("Le Creuset Collection")
                        .font(.system(size: 18, weight: .medium, design: .serif))
                        .foregroundColor(isDarkTheme ? .white : AppColors.primaryText)
                }
                
                Divider()
                    .background(isDarkTheme ? .white.opacity(0.2) : .black.opacity(0.1))
                    .padding(.horizontal, AppSpacing.xl)
                
                // Gifted By
                VStack(spacing: 4) {
                    Text("GIFTED WITH LOVE BY")
                        .font(AppTypography.caption1Medium)
                        .tracking(1.5)
                        .foregroundColor(isDarkTheme ? .white.opacity(0.7) : AppColors.secondaryGray)
                    
                    Text("Olivia • Mia • Ethan ")
                        .foregroundColor(isDarkTheme ? .white : AppColors.primaryText)
                    + Text("+ 12 others")
                        .foregroundColor(isDarkTheme ? .white.opacity(0.7) : AppColors.secondaryGray)
                }
                .font(AppTypography.bodyMedium)
                
                // Brand Button
                Text("WILLIAMS SONOMA")
                    .font(AppTypography.caption1Medium)
                    .tracking(1.5)
                    .foregroundColor(AppColors.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color(hex: "231F20"))
                    .clipShape(Capsule())
                    .padding(.top, AppSpacing.sm)
                    .padding(.bottom, AppSpacing.xl)
            }
            .frame(maxWidth: .infinity)
        }
        .background(selectedCardTheme)
        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
    }
    
    private var bottomControls: some View {
        VStack(spacing: AppSpacing.lg) {
            Text("CARD THEME")
                .font(AppTypography.caption1Medium)
                .tracking(1.5)
                .foregroundColor(AppColors.secondaryGray)
            
            HStack(spacing: AppSpacing.lg) {
                ForEach(themes, id: \.self) { theme in
                    Circle()
                        .fill(theme)
                        .frame(width: 44, height: 44)
                        .overlay(
                            Circle()
                                .strokeBorder(Color.white, lineWidth: selectedCardTheme == theme ? 3 : 0)
                        )
                        .onTapGesture {
                            withAnimation {
                                selectedCardTheme = theme
                            }
                        }
                }
            }
            
            HStack(spacing: AppSpacing.md) {
                Button(action: {}) {
                    HStack {
                        Image(systemName: "square.and.arrow.down")
                        Text("Save")
                    }
                    .font(AppTypography.buttonMedium)
                    .foregroundColor(AppColors.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.white.opacity(0.15))
                    .clipShape(Capsule())
                    .overlay(
                        Capsule().strokeBorder(Color.white.opacity(0.2), lineWidth: 1)
                    )
                }
                
                Button(action: {}) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text("Share")
                    }
                    .font(AppTypography.buttonMedium)
                    .foregroundColor(AppColors.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(AppColors.accentRed)
                    .clipShape(Capsule())
                }
            }
            .padding(.top, AppSpacing.sm)
            .padding(.bottom, AppSpacing.xl)
        }
        .padding(.horizontal, AppSpacing.screenHorizontal)
        .padding(.top, AppSpacing.xl)
        .background(
            Color(hex: "222222")
                .clipShape(RoundedCorner(radius: 32, corners: [.topLeft, .topRight]))
                .ignoresSafeArea()
        )
    }
}

#Preview {
    NavigationStack {
        MemoryCardView()
    }
}
