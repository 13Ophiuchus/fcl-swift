// UI/ImageView.swift

import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

final class ImageLoader: ObservableObject {
    let didChange = PassthroughSubject<Data, Never>()
    private(set) var data = Data() {
        didSet { didChange.send(data) }
    }

    func load(from url: URL) {
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data, let self = self else { return }
            DispatchQueue.main.async {
                self.data = data
            }
        }.resume()
    }
}

struct ImageView: View {
    let url: URL
    @StateObject private var imageLoader = ImageLoader()
    @State private var image: Image = Image(systemName: "photo")

    var body: some View {
        image
            .resizable()
            .aspectRatio(contentMode: .fit)
            .onReceive(imageLoader.didChange) { data in
                #if canImport(UIKit)
                if let uiImage = UIImage( data) {
                    image = Image(uiImage: uiImage)
                }
                #endif
            }
            .background(
                Color(
                    #if canImport(UIKit)
                    UIColor.tertiarySystemBackground
                    #else
                    .gray
                    #endif
                )
            )
            .onAppear {
                imageLoader.load(from: url)
            }
    }
}

#if canImport(UIKit)
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}
#endif
