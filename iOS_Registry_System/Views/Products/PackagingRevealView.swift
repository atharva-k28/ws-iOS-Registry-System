//
//  PackagingRevealView.swift
//  iOS_Registry_System
//
//  Signature bundle unwrap interaction
//

import SwiftUI

struct PackagingRevealView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Namespace private var revealNamespace

    @State private var isRevealed = false
    @State private var pressProgress: CGFloat = 0
    @State private var isPressing = false
    @State private var didPlayHalfHaptic = false
    @State private var visibleItemIDs: Set<UUID> = []
    @State private var showToast = false

    private let bundleItems = BundleItem.samples

    var body: some View {
        ZStack(alignment: .bottom) {
            packagingBackdrop

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: AppSpacing.xl) {
                    topBar

                    revealStage
                        .frame(height: isRevealed ? 360 : 560)

                    if isRevealed {
                        insideBundleCard
                            .padding(.horizontal, AppSpacing.screenHorizontal)
                            .transition(reduceMotion ? .opacity : .opacity.combined(with: .move(edge: .bottom)))
                    }

                    Color.clear.frame(height: AppSpacing.tabBarHeight + AppSpacing.massive)
                }
                .padding(.top, AppSpacing.md)
            }

            if isRevealed {
                ctaDock
                    .transition(reduceMotion ? .opacity : .opacity.combined(with: .move(edge: .bottom)))
            }

            if showToast {
                toastView
            }
        }
        .appBackground()
        .navigationBarBackButtonHidden(true)
        .onChange(of: isRevealed) { _, newValue in
            guard newValue else { return }
            revealCardsIfNeeded()
        }
        .animation(reduceMotion ? .easeInOut(duration: 0.18) : .spring(response: 0.5, dampingFraction: 0.82), value: isRevealed)
    }

    private var topBar: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppColors.primaryDark)
                    .frame(width: 44, height: 44)
                    .background(AppColors.white)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(AppColors.backgroundGray, lineWidth: 1))
            }

            Spacer()

            Text("PACKAGING REVEAL")
                .font(AppTypography.caption1Medium)
                .tracking(1.8)
                .foregroundColor(AppColors.secondaryGray)

            Spacer()

            Color.clear.frame(width: 44, height: 44)
        }
        .padding(.horizontal, AppSpacing.screenHorizontal)
    }

    private var packagingBackdrop: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            LinearGradient(
                colors: [
                    Color(hex: "FFF8EF").opacity(0.78),
                    AppColors.background.opacity(0.95),
                    Color(hex: "F3ECE3").opacity(0.72)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            RadialGradient(
                colors: [Color(hex: "F6D8BA").opacity(0.44), .clear],
                center: .topTrailing,
                startRadius: 20,
                endRadius: 320
            )
            .ignoresSafeArea()

            RadialGradient(
                colors: [Color(hex: "8F5E45").opacity(0.14), .clear],
                center: .bottomLeading,
                startRadius: 40,
                endRadius: 360
            )
            .ignoresSafeArea()
        }
    }

    private var revealStage: some View {
        ZStack {
            if isRevealed {
                revealedCards
                    .transition(reduceMotion ? .opacity : .opacity.combined(with: .scale(scale: 0.96)))
            } else {
                packagedBox
                    .transition(reduceMotion ? .opacity : .opacity.combined(with: .scale(scale: 0.96)))
            }
        }
        .frame(maxWidth: .infinity)
        .animation(reduceMotion ? .easeInOut(duration: 0.18) : .spring(response: 0.5, dampingFraction: 0.78), value: isRevealed)
    }

    private var packagedBox: some View {
        ZStack {
            VStack(spacing: AppSpacing.xl) {
                VStack(spacing: AppSpacing.sm) {
                    Text("A CURATED BUNDLE")
                        .font(AppTypography.caption1Medium)
                        .tracking(1.8)
                        .foregroundColor(AppColors.secondaryGray)
                        .padding(.horizontal, AppSpacing.md)
                        .padding(.vertical, AppSpacing.xs)
                        .background(AppColors.white.opacity(0.72))
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(AppColors.white.opacity(0.86), lineWidth: 1))

                    Text("Unwrap a table\nmade for hosting.")
                        .font(.system(size: 32, weight: .bold, design: .serif))
                        .multilineTextAlignment(.center)
                        .foregroundColor(AppColors.primaryDark)
                        .lineSpacing(2)

                    Text("Four pieces, chosen to feel effortless together.")
                        .font(AppTypography.subheadline)
                        .foregroundColor(AppColors.secondaryGray)
                        .multilineTextAlignment(.center)
                }

                ZStack {
                    RoundedRectangle(cornerRadius: 36, style: .continuous)
                        .fill(AppColors.white.opacity(0.46))
                        .frame(width: 300, height: 254)
                        .overlay(
                            RoundedRectangle(cornerRadius: 36, style: .continuous)
                                .stroke(AppColors.white.opacity(0.72), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.05), radius: 34, y: 18)

                    Circle()
                        .fill(Color(hex: "D7B48F").opacity(0.16))
                        .frame(width: 246, height: 246)

                    ZStack {
                        giftBox
                            .matchedGeometryEffect(id: "bundleSurface", in: revealNamespace)

                        Circle()
                            .trim(from: 0, to: pressProgress)
                            .stroke(
                                LinearGradient(
                                    colors: [Color(hex: "6A4533"), AppColors.primaryDark],
                                    startPoint: .top,
                                    endPoint: .bottom
                                ),
                                style: StrokeStyle(lineWidth: 4, lineCap: .round)
                            )
                            .rotationEffect(.degrees(-90))
                            .frame(width: 214, height: 214)
                            .opacity(pressProgress > 0 ? 1 : 0)
                    }
                    .onLongPressGesture(
                        minimumDuration: 0.5,
                        maximumDistance: 44,
                        pressing: { pressing in
                            handlePressing(pressing)
                        },
                        perform: revealBundle
                    )
                }

                HStack(spacing: AppSpacing.sm) {
                    ZStack {
                        Circle()
                            .fill(Color(hex: "F6D8BA").opacity(0.62))
                            .frame(width: 32, height: 32)
                        Image(systemName: "hand.tap.fill")
                            .font(.system(size: 14, weight: .semibold))
                    }

                    Text("Press & hold to unwrap")
                        .font(AppTypography.buttonMedium)
                }
                .foregroundColor(AppColors.primaryDark)
                .padding(.horizontal, AppSpacing.lg)
                .padding(.vertical, AppSpacing.sm)
                .background(AppColors.white.opacity(0.92))
                .clipShape(Capsule())
                .overlay(Capsule().stroke(AppColors.white.opacity(0.88), lineWidth: 1))
                .shadow(color: .black.opacity(0.06), radius: 18, y: 8)
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
        }
    }

    private var giftBox: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "1E1B18"), Color(hex: "32302C")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 176, height: 176)
                .shadow(color: Color(hex: "6A4533").opacity(0.24), radius: 34, y: 22)
                .shadow(color: .black.opacity(0.12), radius: 18, y: 10)

            Rectangle()
                .fill(espressoRibbon)
                .frame(width: 34, height: 176)

            Rectangle()
                .fill(espressoRibbon)
                .frame(width: 176, height: 34)

//            VStack(spacing: AppSpacing.xxs) {
//                Text("Williams Sonoma")
//                    .font(.system(size: 18, weight: .semibold, design: .serif))
//                Text("EST. 1956")
//                    .font(AppTypography.caption2)
//                    .tracking(1.6)
//            }
//            .foregroundColor(AppColors.white)
//            .padding(.horizontal, AppSpacing.md)
//            .padding(.vertical, AppSpacing.sm)
//            .background(Color.black.opacity(0.24))
//            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.sm, style: .continuous))
        }
        .accessibilityLabel("Williams Sonoma curated gift box. Press and hold to unwrap.")
    }

    private var revealedCards: some View {
        ZStack {
            ForEach(Array(bundleItems.prefix(4).enumerated()), id: \.element.id) { index, item in
                revealCard(item, index: index)
                    .opacity(visibleItemIDs.contains(item.id) ? 1 : 0)
                    .offset(visibleItemIDs.contains(item.id) ? spreadOffset(for: index) : .zero)
                    .rotationEffect(.degrees(visibleItemIDs.contains(item.id) ? rotation(for: index) : 0))
                    .matchedGeometryEffect(id: item.id, in: revealNamespace)
            }
        }
        .matchedGeometryEffect(id: "bundleSurface", in: revealNamespace)
        .accessibilityElement(children: .contain)
    }

    private func revealCard(_ item: BundleItem, index: Int) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            AsyncImage(url: URL(string: item.imageURL)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                AppColors.backgroundGray
                    .overlay {
                        Image(systemName: item.symbol)
                            .font(.system(size: 30, weight: .medium))
                            .foregroundColor(AppColors.secondaryGray.opacity(0.5))
                    }
            }
            .frame(width: 132, height: 116)
            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.md, style: .continuous))

            Text(item.name)
                .font(AppTypography.caption1Medium)
                .foregroundColor(AppColors.primaryDark)
                .lineLimit(2)

            Text(item.price)
                .font(AppTypography.caption1)
                .foregroundColor(AppColors.secondaryGray)
        }
        .padding(AppSpacing.xs)
        .frame(width: 148)
        .background(AppColors.white)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.lg, style: .continuous))
        .shadow(color: .black.opacity(0.12), radius: 32, y: 14)
        .accessibilityLabel("\(item.name), \(item.price)")
    }

    private var insideBundleCard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("INSIDE THE BUNDLE")
                .font(AppTypography.caption1Medium)
                .tracking(1.6)
                .foregroundColor(AppColors.secondaryGray)

            ForEach(bundleItems) { item in
                HStack(spacing: AppSpacing.sm) {
                    Circle()
                        .fill(AppColors.primaryDark)
                        .frame(width: 6, height: 6)

                    Text(item.name)
                        .font(AppTypography.bodyMedium)
                        .foregroundColor(AppColors.primaryDark)

                    Spacer()

                    Text(item.price)
                        .font(AppTypography.subheadlineMedium)
                        .foregroundColor(AppColors.secondaryGray)
                }
                .frame(minHeight: 34)
            }
        }
        .padding(AppSpacing.xl)
        .background(AppColors.white)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.lg, style: .continuous))
        .softShadow()
    }

    private var ctaDock: some View {
        HStack(spacing: AppSpacing.sm) {
            Button {
                UIImpactFeedbackGenerator(style: .soft).impactOccurred()
            } label: {
                Text("Save bundle")
                    .font(AppTypography.buttonMedium)
                    .foregroundColor(AppColors.primaryDark)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(AppColors.white)
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(AppColors.primaryDark.opacity(0.12), lineWidth: 1))
            }

            Button {
                addBundleToRegistry()
            } label: {
                Text("Add to registry")
                    .font(AppTypography.buttonMedium)
                    .foregroundColor(AppColors.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(AppColors.accentRed)
                    .clipShape(Capsule())
                    .shadow(color: AppColors.accentRed.opacity(0.28), radius: 14, y: 6)
            }
        }
        .padding(AppSpacing.sm)
        .background(AppColors.white.opacity(0.94))
        .clipShape(Capsule())
        .shadow(color: .black.opacity(0.08), radius: 18, y: 8)
        .padding(.horizontal, AppSpacing.screenHorizontal)
        .padding(.bottom, AppSpacing.md)
    }

    private var toastView: some View {
        VStack {
            Text("Bundle added to registry")
                .font(AppTypography.caption1Medium)
                .foregroundColor(AppColors.white)
                .padding(.horizontal, AppSpacing.md)
                .padding(.vertical, AppSpacing.xs)
                .background(AppColors.primaryDark)
                .clipShape(Capsule())
                .transition(.move(edge: .top).combined(with: .opacity))

            Spacer()
        }
        .padding(.top, AppSpacing.xxl)
        .zIndex(2)
    }

    private var espressoRibbon: LinearGradient {
        LinearGradient(
            colors: [Color(hex: "3B2419"), Color(hex: "6A4533")],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    private func handlePressing(_ pressing: Bool) {
        guard !isRevealed else { return }

        if pressing {
            isPressing = true
            didPlayHalfHaptic = false

            if reduceMotion {
                pressProgress = 1
            } else {
                withAnimation(.linear(duration: 0.5)) {
                    pressProgress = 1
                }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                guard isPressing, !didPlayHalfHaptic else { return }
                didPlayHalfHaptic = true
                UIImpactFeedbackGenerator(style: .soft).impactOccurred()
            }
        } else {
            isPressing = false
            guard !isRevealed else { return }

            withAnimation(.easeOut(duration: 0.18)) {
                pressProgress = 0
            }
        }
    }

    private func revealBundle() {
        guard !isRevealed else { return }
        isPressing = false
        pressProgress = 1
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()

        if reduceMotion {
            isRevealed = true
        } else {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.78)) {
                isRevealed = true
            }
        }
    }

    private func revealCardsIfNeeded() {
        guard visibleItemIDs.isEmpty else { return }

        for (index, item) in bundleItems.prefix(4).enumerated() {
            let delay = reduceMotion ? 0 : Double(index) * 0.05
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                if reduceMotion {
                    _ = visibleItemIDs.insert(item.id)
                } else {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.78)) {
                        _ = visibleItemIDs.insert(item.id)
                    }
                }
            }
        }
    }

    private func addBundleToRegistry() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()

        withAnimation {
            showToast = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            dismiss()
        }
    }

    private func rotation(for index: Int) -> Double {
        [-8, 4, -3, 6][index]
    }

    private func spreadOffset(for index: Int) -> CGSize {
        [
            CGSize(width: -84, height: -34),
            CGSize(width: 82, height: -44),
            CGSize(width: -54, height: 96),
            CGSize(width: 78, height: 88)
        ][index]
    }
}

private struct BundleItem: Identifiable {
    let id = UUID()
    let name: String
    let price: String
    let imageURL: String
    let symbol: String

    static let samples = [
        BundleItem(
            name: "Cast Iron Skillet",
            price: "$189.95",
            imageURL: "https://images.unsplash.com/photo-1556911220-bff31c812dba?w=500",
            symbol: "frying.pan"
        ),
        BundleItem(
            name: "Linen Napkin Set",
            price: "$48",
            imageURL: "https://images.unsplash.com/photo-1615873968403-89e068629265?w=500",
            symbol: "square.stack.3d.up"
        ),
        BundleItem(
            name: "Stoneware Plates",
            price: "$72",
            imageURL: "https://images.unsplash.com/photo-1610701596007-11502861dcfa?w=500",
            symbol: "circle.grid.cross"
        ),
        BundleItem(
            name: "Olive Wood Board",
            price: "$65",
            imageURL: "https://images.unsplash.com/photo-1556910103-1c02745aae4d?w=500",
            symbol: "rectangle.roundedtop"
        )
    ]
}

#Preview {
    NavigationStack {
        PackagingRevealView()
    }
}
