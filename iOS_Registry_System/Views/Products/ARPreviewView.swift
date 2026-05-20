//
//  ARPreviewView.swift
//  iOS_Registry_System
//
//  AR Preview — uses live ARKit camera on device,
//  shows a premium placeholder on Simulator with product name.
//

import SwiftUI
import RealityKit
import ARKit

struct ARPreviewView: View {
    @Environment(\.dismiss) private var dismiss
    let product: Product

    @State private var isPlaced = false

    private var imageURL: String {
        product.imageUrl ?? "https://images.unsplash.com/photo-1556911220-bff31c812dba?w=900"
    }

    /// Product dimensions in cm (fallback to category-based estimates)
    private var widthCM: Int { Int(product.width ?? estimatedWidth) }
    private var heightCM: Int { Int(product.height ?? estimatedHeight) }
    private var depthCM: Int { Int(product.depth ?? estimatedDepth) }

    private var estimatedWidth: Double {
        let cat = product.category.lowercased()
        if cat.contains("cook") || cat.contains("pan") || cat.contains("skillet") { return 28 }
        if cat.contains("appli") { return 35 }
        if cat.contains("bake") { return 24 }
        if cat.contains("table") || cat.contains("din") { return 20 }
        return 25
    }
    private var estimatedHeight: Double {
        let cat = product.category.lowercased()
        if cat.contains("cook") || cat.contains("pan") { return 8 }
        if cat.contains("appli") { return 30 }
        if cat.contains("bake") { return 6 }
        return 15
    }
    private var estimatedDepth: Double {
        let cat = product.category.lowercased()
        if cat.contains("cook") || cat.contains("pan") { return 28 }
        if cat.contains("appli") { return 25 }
        return 20
    }

    var body: some View {
        #if targetEnvironment(simulator)
        simulatorPlaceholder
        #else
        liveARExperience
        #endif
    }

    // MARK: - Simulator Placeholder

    private var simulatorPlaceholder: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            // Close button — top trailing
            VStack {
                HStack {
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white.opacity(0.85))
                            .frame(width: 44, height: 44)
                            .background(Color.white.opacity(0.15))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                    .padding(.trailing, AppSpacing.screenHorizontal)
                    .padding(.top, AppSpacing.lg)
                }
                Spacer()
            }

            // Centered content
            VStack(spacing: 20) {
                // AR cube icon
                Image(systemName: "arkit")
                    .font(.system(size: 56, weight: .thin))
                    .foregroundColor(.white)
                    .padding(.bottom, 4)

                // Title
                Text("AR View")
                    .font(.system(size: 28, weight: .bold, design: .default))
                    .foregroundColor(.white)

                // Instruction with product name
                VStack(spacing: 4) {
                    Text("Point your camera at a flat surface")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.white.opacity(0.6))

                    Text("to place \(product.name)")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.white.opacity(0.6))
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }

                // Simulator disclaimer
                VStack(spacing: 2) {
                    Text("AR requires a physical device.")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(.white.opacity(0.35))

                    Text("Please run on iPhone or iPad.")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(.white.opacity(0.35))
                }
                .padding(.top, 16)
            }
            .padding(.horizontal, 40)
        }
    }

    // MARK: - Live AR Experience (Real Device)

    private var liveARExperience: some View {
        GeometryReader { proxy in
            ZStack {
                ARViewContainer(product: product, isPlaced: $isPlaced)
                    .ignoresSafeArea()

                // Corner brackets while scanning
                if !isPlaced {
                    cornerBrackets
                        .padding(.horizontal, AppSpacing.xl)
                        .padding(.vertical, 96)
                }

                // Floating product after placement
                if isPlaced {
                    floatingProductCard
                        .position(x: proxy.size.width * 0.48, y: proxy.size.height * 0.38)
                        .transition(.scale.combined(with: .opacity))
                }

                // Top bar
                VStack(spacing: 0) {
                    topBar
                        .padding(.horizontal, AppSpacing.screenHorizontal)
                        .padding(.top, AppSpacing.md)
                    Spacer()
                }

                // Bottom UI
                VStack(spacing: AppSpacing.sm) {
                    Spacer()
                    infoCard
                        .padding(.horizontal, AppSpacing.screenHorizontal)
                    bottomDock
                        .padding(.horizontal, AppSpacing.screenHorizontal)
                        .padding(.bottom, AppSpacing.md)
                }
            }
            .ignoresSafeArea()
        }
    }

    // MARK: - Floating Product Card (placed in AR)

    private var floatingProductCard: some View {
        ZStack(alignment: .topTrailing) {
            AsyncImage(url: URL(string: imageURL)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                AppColors.backgroundGray
                    .overlay {
                        Image(systemName: "cube.transparent")
                            .font(.system(size: 36, weight: .medium))
                            .foregroundColor(AppColors.secondaryGray.opacity(0.5))
                    }
            }
            .frame(width: 200, height: 160)
            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.lg, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AppCornerRadius.lg, style: .continuous)
                    .stroke(AppColors.white.opacity(0.6), lineWidth: 1.5)
            )
            .shadow(color: .black.opacity(0.35), radius: 30, y: 20)

            // Dimension pills
            VStack(alignment: .trailing, spacing: 6) {
                dimensionPill(icon: "arrow.left.and.right", text: "\(widthCM) cm")
                dimensionPill(icon: "arrow.up.and.down", text: "\(heightCM) cm")
            }
            .offset(x: 22, y: -14)

            // Ground shadow
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [.black.opacity(0.25), .clear],
                        center: .center, startRadius: 10, endRadius: 80
                    )
                )
                .frame(width: 160, height: 30)
                .offset(y: 170)
        }
        .rotation3DEffect(.degrees(-10), axis: (x: 0, y: 1, z: 0), perspective: 0.6)
        .rotation3DEffect(.degrees(6), axis: (x: 1, y: 0, z: 0), perspective: 0.6)
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            glassCircleButton(systemName: "chevron.left") { dismiss() }
            Spacer()

            HStack(spacing: AppSpacing.xs) {
                Image(systemName: "arkit")
                    .font(.system(size: 14, weight: .semibold))
                Text("AR Preview")
                    .font(AppTypography.subheadlineMedium)
            }
            .foregroundColor(.white)
            .padding(.horizontal, AppSpacing.md)
            .frame(height: 40)
            .background(.ultraThinMaterial.opacity(0.85))
            .clipShape(Capsule())
            .overlay(Capsule().stroke(Color.white.opacity(0.4), lineWidth: 0.5))
            .shadow(color: .black.opacity(0.2), radius: 8, y: 2)

            Spacer()
            glassCircleButton(systemName: "camera.fill") {}
        }
    }

    // MARK: - Info Card

    private var infoCard: some View {
        HStack(spacing: AppSpacing.md) {
            AsyncImage(url: URL(string: imageURL)) { image in
                image.resizable().aspectRatio(contentMode: .fill)
            } placeholder: {
                AppColors.backgroundGray
            }
            .frame(width: 54, height: 54)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            VStack(alignment: .leading, spacing: 3) {
                Text(product.name)
                    .font(AppTypography.bodySemibold)
                    .foregroundColor(.white)
                    .lineLimit(1)

                Text(isPlaced ? "Pinch to scale · drag to move" : "Tap surface to place item")
                    .font(AppTypography.caption1)
                    .foregroundColor(.white.opacity(0.65))
                    .lineLimit(1)

                HStack(spacing: 6) {
                    Text(CurrencyFormatter.format(product.price))
                        .font(AppTypography.subheadlineMedium)
                        .foregroundColor(.white)

                    if isPlaced {
                        Text("\(widthCM)×\(heightCM)×\(depthCM) cm")
                            .font(AppTypography.caption2)
                            .foregroundColor(.white.opacity(0.5))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.white.opacity(0.15))
                            .clipShape(Capsule())
                    }
                }
            }
            Spacer(minLength: 0)
        }
        .padding(AppSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: AppCornerRadius.lg, style: .continuous)
                .fill(.ultraThinMaterial.opacity(0.9))
                .shadow(color: .black.opacity(0.2), radius: 16, y: 6)
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppCornerRadius.lg, style: .continuous)
                .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
        )
    }

    // MARK: - Bottom Dock

    private var bottomDock: some View {
        HStack(spacing: AppSpacing.sm) {
            dockButton(systemName: "arrow.up.and.down.and.arrow.left.and.right", title: "Move")
            dockButton(systemName: "rotate.3d", title: "Rotate")

            Button {} label: {
                Circle().fill(.white).frame(width: 58, height: 58)
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [Color(hex: "FF6B6B"), Color(hex: "FF8C7A")],
                                    startPoint: .topLeading, endPoint: .bottomTrailing
                                ),
                                lineWidth: 4
                            )
                            .frame(width: 66, height: 66)
                    )
                    .shadow(color: Color(hex: "FF8C7A").opacity(0.35), radius: 14, y: 0)
            }.buttonStyle(.plain)

            dockButton(systemName: "arrow.up.left.and.arrow.down.right", title: "Scale")

            Button {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                dismiss()
            } label: {
                Text("Add")
                    .font(AppTypography.buttonSmall)
                    .foregroundColor(.white)
                    .frame(width: 52, height: 40)
                    .background(AppColors.accentRed)
                    .clipShape(Capsule())
                    .shadow(color: AppColors.accentRed.opacity(0.4), radius: 8, y: 2)
            }.buttonStyle(.plain)
        }
        .padding(.horizontal, AppSpacing.md)
        .padding(.vertical, AppSpacing.sm)
        .background(
            Capsule().fill(.ultraThinMaterial.opacity(0.9))
                .shadow(color: .black.opacity(0.2), radius: 16, y: 6)
        )
        .overlay(Capsule().stroke(Color.white.opacity(0.2), lineWidth: 0.5))
    }

    // MARK: - Helpers

    private func glassCircleButton(systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 42, height: 42)
                .background(.ultraThinMaterial.opacity(0.8))
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white.opacity(0.3), lineWidth: 0.5))
                .shadow(color: .black.opacity(0.15), radius: 6, y: 2)
        }.buttonStyle(.plain)
    }

    private func dockButton(systemName: String, title: String) -> some View {
        Button {} label: {
            VStack(spacing: 2) {
                Image(systemName: systemName)
                    .font(.system(size: 14, weight: .semibold))
                Text(title)
                    .font(.system(size: 9, weight: .medium))
            }
            .foregroundColor(.white.opacity(0.85))
            .frame(width: 46, height: 46)
        }.buttonStyle(.plain)
    }

    private func dimensionPill(icon: String, text: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon).font(.system(size: 9, weight: .bold))
            Text(text).font(.system(size: 12, weight: .semibold, design: .rounded))
        }
        .foregroundColor(.white)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Capsule().fill(Color.black.opacity(0.55)))
    }

    private var cornerBrackets: some View {
        VStack {
            HStack { bracket(corner: .topLeading); Spacer(); bracket(corner: .topTrailing) }
            Spacer()
            HStack { bracket(corner: .bottomLeading); Spacer(); bracket(corner: .bottomTrailing) }
        }
    }

    private func bracket(corner: BracketCorner) -> some View {
        Path { path in
            switch corner {
            case .topLeading:
                path.move(to: CGPoint(x: 0, y: 40)); path.addLine(to: CGPoint(x: 0, y: 0)); path.addLine(to: CGPoint(x: 40, y: 0))
            case .topTrailing:
                path.move(to: CGPoint(x: 0, y: 0)); path.addLine(to: CGPoint(x: 40, y: 0)); path.addLine(to: CGPoint(x: 40, y: 40))
            case .bottomLeading:
                path.move(to: CGPoint(x: 40, y: 40)); path.addLine(to: CGPoint(x: 0, y: 40)); path.addLine(to: CGPoint(x: 0, y: 0))
            case .bottomTrailing:
                path.move(to: CGPoint(x: 0, y: 40)); path.addLine(to: CGPoint(x: 40, y: 40)); path.addLine(to: CGPoint(x: 40, y: 0))
            }
        }
        .stroke(Color.white.opacity(0.7), style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
        .frame(width: 40, height: 40)
    }
}

// MARK: - Bracket Corner

private enum BracketCorner {
    case topLeading, topTrailing, bottomLeading, bottomTrailing
}

// MARK: - ARViewContainer (Real Device)

struct ARViewContainer: UIViewRepresentable {
    let product: Product
    @Binding var isPlaced: Bool

    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)

        #if targetEnvironment(simulator)
        arView.environment.background = .color(.black)
        #else
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        config.environmentTexturing = .automatic
        arView.session.run(config)

        let coachingOverlay = ARCoachingOverlayView()
        coachingOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        coachingOverlay.session = arView.session
        coachingOverlay.goal = .horizontalPlane
        arView.addSubview(coachingOverlay)
        #endif

        let tapGesture = UITapGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handleTap(_:))
        )
        arView.addGestureRecognizer(tapGesture)
        context.coordinator.arView = arView
        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(product: product, isPlaced: $isPlaced)
    }

    class Coordinator: NSObject {
        weak var arView: ARView?
        let product: Product
        @Binding var isPlaced: Bool
        var anchorEntity: AnchorEntity?

        init(product: Product, isPlaced: Binding<Bool>) {
            self.product = product
            self._isPlaced = isPlaced
        }

        @objc func handleTap(_ recognizer: UITapGestureRecognizer) {
            guard let arView = arView else { return }
            let location = recognizer.location(in: arView)

            #if !targetEnvironment(simulator)
            if let result = arView.raycast(
                from: location,
                allowing: .estimatedPlane,
                alignment: .horizontal
            ).first {
                placeProduct(at: result.worldTransform)
            }
            #else
            var transform = matrix_identity_float4x4
            transform.columns.3.z = -0.5
            placeProduct(at: transform)
            #endif
        }

        func placeProduct(at transform: simd_float4x4) {
            guard let arView = arView else { return }

            if let existing = anchorEntity {
                arView.scene.removeAnchor(existing)
            }

            let anchor = AnchorEntity(world: transform)

            let width  = Float(product.width ?? 28.0) / 100.0
            let height = Float(product.height ?? 12.0) / 100.0
            let depth  = Float(product.depth ?? 28.0) / 100.0

            let mesh = MeshResource.generateBox(
                width: width, height: height, depth: depth,
                cornerRadius: 0.005
            )
            var material = SimpleMaterial(color: .systemGray5, isMetallic: false)
            material.roughness = 0.6

            let modelEntity = ModelEntity(mesh: mesh, materials: [material])
            modelEntity.position.y = height / 2
            modelEntity.generateCollisionShapes(recursive: true)

            anchor.addChild(modelEntity)
            arView.scene.addAnchor(anchor)
            self.anchorEntity = anchor

            DispatchQueue.main.async {
                self.isPlaced = true
            }

            // Load product image as texture
            if let urlString = product.imageUrl, let url = URL(string: urlString) {
                Task {
                    do {
                        let (data, _) = try await URLSession.shared.data(from: url)
                        if let uiImage = UIImage(data: data),
                           let cgImage = uiImage.cgImage {
                            let texture = try await TextureResource.generate(
                                from: cgImage,
                                options: .init(semantic: .color)
                            )
                            var imageMaterial = SimpleMaterial()
                            imageMaterial.color = .init(tint: .white, texture: .init(texture))
                            await MainActor.run {
                                modelEntity.model?.materials = [imageMaterial]
                            }
                        }
                    } catch {
                        print("AR Texture load error: \(error)")
                    }
                }
            }
        }
    }
}
