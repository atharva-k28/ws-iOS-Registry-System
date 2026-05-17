//
//  ARPreviewView.swift
//  iOS_Registry_System
//
//  Static AR preview stub for product placement
//

import SwiftUI

struct ARPreviewView: View {
    @Environment(\.dismiss) private var dismiss

    let product: Product

    private var imageURL: String {
        product.imageUrl ?? "https://images.unsplash.com/photo-1556911220-bff31c812dba?w=900"
    }

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                cameraBackdrop

                cornerBrackets
                    .padding(.horizontal, AppSpacing.xl)
                    .padding(.vertical, 96)

                VStack(spacing: 0) {
                    topBar
                        .padding(.horizontal, AppSpacing.screenHorizontal)
                        .padding(.top, AppSpacing.md)

                    Spacer()
                }

                floatingProductCard
                    .position(x: proxy.size.width / 2, y: proxy.size.height * 0.42)

                infoCard
                    .padding(.horizontal, AppSpacing.screenHorizontal)
                    .position(x: proxy.size.width / 2, y: proxy.size.height * 0.58)

                VStack {
                    Spacer()
                    bottomDock
                        .padding(.horizontal, AppSpacing.screenHorizontal)
                        .padding(.bottom, AppSpacing.md)
                }
            }
            .ignoresSafeArea()
        }
    }

    private var cameraBackdrop: some View {
        AsyncImage(url: URL(string: "https://images.unsplash.com/photo-1556910103-1c02745aae4d?w=1200")) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
        } placeholder: {
            LinearGradient(
                colors: [Color(hex: "28322D"), Color(hex: "647268")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        .overlay(Color.black.opacity(0.16))
        .ignoresSafeArea()
    }

    private var topBar: some View {
        HStack {
            glassCircleButton(systemName: "chevron.left") {
                dismiss()
            }

            Spacer()

            HStack(spacing: AppSpacing.xs) {
                Image(systemName: "sparkles")
                    .font(.system(size: 13, weight: .semibold))
                Text("AR Preview")
                    .font(AppTypography.subheadlineMedium)
            }
            .foregroundColor(AppColors.primaryDark)
            .padding(.horizontal, AppSpacing.md)
            .frame(height: 44)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(AppColors.white.opacity(0.5), lineWidth: 1))

            Spacer()

            glassCircleButton(systemName: "camera") {}
        }
    }

    private var cornerBrackets: some View {
        VStack {
            HStack {
                bracket(corner: .topLeading)
                Spacer()
                bracket(corner: .topTrailing)
            }

            Spacer()

            HStack {
                bracket(corner: .bottomLeading)
                Spacer()
                bracket(corner: .bottomTrailing)
            }
        }
    }

    private var floatingProductCard: some View {
        ZStack(alignment: .topTrailing) {
            AsyncImage(url: URL(string: imageURL)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                AppColors.backgroundGray
                    .overlay {
                        Image(systemName: "frying.pan")
                            .font(.system(size: 46, weight: .medium))
                            .foregroundColor(AppColors.secondaryGray.opacity(0.5))
                    }
            }
            .frame(width: 190, height: 150)
            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.lg, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: AppCornerRadius.lg, style: .continuous).stroke(AppColors.white.opacity(0.55), lineWidth: 1))
            .shadow(color: .black.opacity(0.22), radius: 26, y: 18)

            VStack(alignment: .trailing, spacing: AppSpacing.xs) {
                dimensionPill("↔ 28 cm")
                dimensionPill("↕ 12 cm")
            }
            .offset(x: 18, y: -18)
        }
        .rotation3DEffect(.degrees(-12), axis: (x: 0, y: 1, z: 0), perspective: 0.7)
        .rotation3DEffect(.degrees(8), axis: (x: 1, y: 0, z: 0), perspective: 0.7)
    }

    private var infoCard: some View {
        HStack(spacing: AppSpacing.md) {
            AsyncImage(url: URL(string: imageURL)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                AppColors.backgroundGray
            }
            .frame(width: 58, height: 58)
            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.sm, style: .continuous))

            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                Text("Cast Iron Skillet 12\"")
                    .font(AppTypography.bodySemibold)
                    .foregroundColor(AppColors.primaryDark)
                    .lineLimit(1)

                Text("Tap surface to place · pinch to scale")
                    .font(AppTypography.caption1)
                    .foregroundColor(AppColors.secondaryGray)
                    .lineLimit(1)

                Text(CurrencyFormatter.format(product.price))
                    .font(AppTypography.subheadlineMedium)
                    .foregroundColor(AppColors.primaryDark)
            }

            Spacer(minLength: 0)
        }
        .padding(AppSpacing.md)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.lg, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: AppCornerRadius.lg, style: .continuous).stroke(AppColors.white.opacity(0.52), lineWidth: 1))
        .shadow(color: .black.opacity(0.14), radius: 22, y: 10)
    }

    private var bottomDock: some View {
        HStack(spacing: AppSpacing.sm) {
            dockButton(systemName: "arrow.up.and.down.and.arrow.left.and.right", title: "Move")
            dockButton(systemName: "rotate.3d", title: "Rotate")

            Button {} label: {
                Circle()
                    .fill(AppColors.white)
                    .frame(width: 62, height: 62)
                    .overlay(Circle().stroke(Color(hex: "FF8C7A").opacity(0.55), lineWidth: 5))
                    .shadow(color: Color(hex: "FF8C7A").opacity(0.42), radius: 18, y: 0)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Capture AR preview")

            dockButton(systemName: "arrow.up.left.and.arrow.down.right", title: "Maximize")

            Button {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                dismiss()
            } label: {
                Text("Add")
                    .font(AppTypography.buttonSmall)
                    .foregroundColor(AppColors.white)
                    .frame(width: 56, height: 44)
                    .background(AppColors.accentRed)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, AppSpacing.sm)
        .padding(.vertical, AppSpacing.xs)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
        .overlay(Capsule().stroke(AppColors.white.opacity(0.5), lineWidth: 1))
        .shadow(color: .black.opacity(0.16), radius: 20, y: 10)
    }

    private func glassCircleButton(systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppColors.primaryDark)
                .frame(width: 44, height: 44)
                .background(.ultraThinMaterial)
                .clipShape(Circle())
                .overlay(Circle().stroke(AppColors.white.opacity(0.5), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    private func dockButton(systemName: String, title: String) -> some View {
        Button {} label: {
            VStack(spacing: AppSpacing.xxxs) {
                Image(systemName: systemName)
                    .font(.system(size: 15, weight: .semibold))
                Text(title)
                    .font(AppTypography.caption2)
            }
            .foregroundColor(AppColors.primaryDark)
            .frame(width: 48, height: 48)
        }
        .buttonStyle(.plain)
    }

    private func dimensionPill(_ text: String) -> some View {
        Text(text)
            .font(AppTypography.caption1Medium)
            .foregroundColor(AppColors.primaryDark)
            .padding(.horizontal, AppSpacing.sm)
            .padding(.vertical, AppSpacing.xs)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(AppColors.white.opacity(0.48), lineWidth: 1))
    }

    private func bracket(corner: BracketCorner) -> some View {
        Path { path in
            switch corner {
            case .topLeading:
                path.move(to: CGPoint(x: 0, y: 40))
                path.addLine(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: 40, y: 0))
            case .topTrailing:
                path.move(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: 40, y: 0))
                path.addLine(to: CGPoint(x: 40, y: 40))
            case .bottomLeading:
                path.move(to: CGPoint(x: 40, y: 40))
                path.addLine(to: CGPoint(x: 0, y: 40))
                path.addLine(to: CGPoint(x: 0, y: 0))
            case .bottomTrailing:
                path.move(to: CGPoint(x: 0, y: 40))
                path.addLine(to: CGPoint(x: 40, y: 40))
                path.addLine(to: CGPoint(x: 40, y: 0))
            }
        }
        .stroke(AppColors.white.opacity(0.78), style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
        .frame(width: 40, height: 40)
    }
}

private enum BracketCorner {
    case topLeading
    case topTrailing
    case bottomLeading
    case bottomTrailing
}

