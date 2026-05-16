//
//  ProgressBar.swift
//  iOS_Registry_System
//
//  Reusable progress indicator for group gifts
//

import SwiftUI

struct ProgressBar: View {
    var progress: Double // 0.0 to 1.0
    var height: CGFloat = 8
    var filledColor: Color = AppColors.accentRed
    var trackColor: Color = AppColors.backgroundGray

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(trackColor)
                    .frame(height: height)
                    .frame(maxWidth: .infinity)

                Capsule()
                    .fill(filledColor)
                    .frame(width: max(0, min(geometry.size.width * progress, geometry.size.width)))
                    .frame(height: height)
            }
        }
        .frame(height: height)
    }
}

#Preview {
    VStack(spacing: 20) {
        ProgressBar(progress: 0.3)
        ProgressBar(progress: 0.75, height: 12)
        ProgressBar(progress: 1.0, filledColor: AppColors.primaryDark)
    }
    .padding()
}
