import SwiftUI
import MetalKit

public struct KestrelView: UIViewRepresentable {
    private let core: KestrelCore
    
    public init(core: KestrelCore) {
        self.core = core
    }
    
    public func makeUIView(context: Context) -> MTKView {
        return core.makeUIView()
    }
    
    public func updateUIView(_ uiView: UIViewType, context: Context) {
        // later
    }
}
