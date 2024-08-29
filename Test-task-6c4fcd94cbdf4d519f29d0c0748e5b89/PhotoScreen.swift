//
//  PhotoScreen.swift
//  Test-task-6c4fcd94cbdf4d519f29d0c0748e5b89
//
//  Created by Personal on 29/08/2024.
//

import SwiftUI

struct PhotoScreen: View {
    @State private var scale: CGFloat = 1.0
    let imageUrl: String
    
    var body: some View {
        AsyncImage(url: URL(string: imageUrl)) { image in
            image.resizable().aspectRatio(contentMode: .fit)
                .scaleEffect(scale)
                .gesture(
                    MagnificationGesture()
                        .onChanged { value in
                            self.scale = value.magnitude
                        }
                        .onEnded { _ in
                            withAnimation {
                                scale = 1
                            }
                        }
                )
        } placeholder: {
            ProgressView()
        }
    }
}

#Preview {
    PhotoScreen(imageUrl: "https://letsenhance.io/static/8f5e523ee6b2479e26ecc91b9c25261e/1015f/MainAfter.jpg")
}
