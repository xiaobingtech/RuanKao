import SwiftUI
import UIKit

struct FullScreenImageView: View {
    let imageUrl: URL
    @Binding var isPresented: Bool
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            ZoomableImageView(url: imageUrl)
                .edgesIgnoringSafeArea(.all)
            
            // Close button
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        isPresented = false
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white.opacity(0.7))
                            .padding()
//                            .padding(.top, 40) // Add some top padding for status bar area
                    }
                }
                Spacer()
            }
        }
    }
}

struct ImageItem: Identifiable {
    let id = UUID()
    let url: URL
}

struct ZoomableImageView: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.delegate = context.coordinator
        scrollView.maximumZoomScale = 5.0
        scrollView.minimumZoomScale = 0.1 // Will be adjusted in layout
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.backgroundColor = .black
        scrollView.contentInsetAdjustmentBehavior = .never
        
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit // Initial mode, but we will resize it
        imageView.tag = 100
        
        scrollView.addSubview(imageView)
        
        context.coordinator.loadImage(url: url, into: imageView, scrollView: scrollView)
        
        // Add double tap gesture
        let doubleTapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleDoubleTap(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTapGesture)
        
        return scrollView
    }
    
    func updateUIView(_ uiView: UIScrollView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, UIScrollViewDelegate {
        var imageView: UIImageView?
        
        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            return scrollView.viewWithTag(100)
        }
        
        func scrollViewDidZoom(_ scrollView: UIScrollView) {
            centerImage(in: scrollView)
        }
        
        func centerImage(in scrollView: UIScrollView) {
            guard let imageView = scrollView.viewWithTag(100) else { return }
            
            let boundsSize = scrollView.bounds.size
            var frameToCenter = imageView.frame
            
            if frameToCenter.size.width < boundsSize.width {
                frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2.0
            } else {
                frameToCenter.origin.x = 0
            }
            
            if frameToCenter.size.height < boundsSize.height {
                frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2.0
            } else {
                frameToCenter.origin.y = 0
            }
            
            imageView.frame = frameToCenter
        }
        
        func loadImage(url: URL, into imageView: UIImageView, scrollView: UIScrollView) {
            self.imageView = imageView
            
            URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
                guard let self = self, let data = data, let image = UIImage(data: data) else { return }
                
                DispatchQueue.main.async {
                    imageView.image = image
                    imageView.frame = CGRect(origin: .zero, size: image.size)
                    scrollView.contentSize = image.size
                    
                    self.updateZoomScale(for: scrollView, imageSize: image.size)
                    self.centerImage(in: scrollView)
                }
            }.resume()
        }
        
        func updateZoomScale(for scrollView: UIScrollView, imageSize: CGSize) {
            let boundsSize = scrollView.bounds.size
            let imageSize = imageSize
            
            let xScale = boundsSize.width / imageSize.width
            let yScale = boundsSize.height / imageSize.height
            let minScale = min(xScale, yScale)
            
            scrollView.minimumZoomScale = minScale
            scrollView.zoomScale = minScale
            scrollView.maximumZoomScale = max(minScale * 2, 2.0)
        }
        
        @objc func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
            guard let scrollView = gesture.view as? UIScrollView else { return }
            
            if scrollView.zoomScale > scrollView.minimumZoomScale {
                scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
            } else {
                // Zoom to point
                let pointInView = gesture.location(in: scrollView.viewWithTag(100))
                let newZoomScale = scrollView.maximumZoomScale
                let scrollViewSize = scrollView.bounds.size
                
                let w = scrollViewSize.width / newZoomScale
                let h = scrollViewSize.height / newZoomScale
                let x = pointInView.x - (w / 2.0)
                let y = pointInView.y - (h / 2.0)
                
                let rectToZoomTo = CGRect(x: x, y: y, width: w, height: h)
                scrollView.zoom(to: rectToZoomTo, animated: true)
            }
        }
    }
}
