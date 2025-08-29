import MetalKit

public final class KestrelCore {
    private let renderer = Renderer()
    // add other systems like audio and input later
    
    public init() {}
    
    func beginDrawing() {
        
    }
    
    func drawGeometry() {
        
    }
    
    func endDrawing() {
        
    }
    
    @MainActor
    func makeUIView() -> MTKView {
        return renderer.makeUIView()
    }
}
