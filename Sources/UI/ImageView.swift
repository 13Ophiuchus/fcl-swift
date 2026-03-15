	// UI/ImageView.swift

import SwiftUI
@preconcurrency import Combine

#if canImport(UIKit)
import UIKit
#endif

final class ImageLoader: ObservableObject {
	let didChange = PassthroughSubject<Data, Never>()

	func load(from url: URL) {
		let subject = didChange
		URLSession.shared.dataTask(with: url) { data, _, _ in
			guard let data else { return }
			DispatchQueue.main.async {
				subject.send(data)
			}
		}.resume()
	}
}

@available(macOS 11.0, *)
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
				if let uiImage = UIImage(data: data) {
					image = Image(uiImage: uiImage)
				}
#endif
			}
#if canImport(UIKit)
			.background(Color(UIColor.tertiarySystemBackground))
#else
			.background(Color.gray)
#endif
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

