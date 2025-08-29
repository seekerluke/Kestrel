import SwiftUI
import MetalKit

public struct KestrelView: UIViewRepresentable {
    private let renderer = Renderer()
    
    public init() {}
    
    public func makeUIView(context: Context) -> MTKView {
        return renderer.makeUIView()
    }
    
    public func updateUIView(_ uiView: UIViewType, context: Context) {
        // later
    }
}
