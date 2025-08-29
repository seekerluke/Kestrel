import SwiftUI
import MetalKit

public struct KestrelView: UIViewRepresentable {
    private let device: MTLDevice
    private let renderer: Renderer
    
    public init() {
        guard let mtlDevice = MTLCreateSystemDefaultDevice() else {
            fatalError("Metal is not supported")
        }
        device = mtlDevice
        renderer = Renderer(device: mtlDevice)
    }
    
    public func makeUIView(context: Context) -> MTKView {
        let view = MTKView(frame: .zero, device: device)
        view.clearColor = MTLClearColor(red: 1, green: 1, blue: 0.8, alpha: 1)
        view.delegate = renderer
        return view
    }
    
    public func updateUIView(_ uiView: UIViewType, context: Context) {
        // later
    }
}
