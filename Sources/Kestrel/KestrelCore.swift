import MetalKit

public final class KestrelCore {
    private let renderer = Renderer()
    // add other systems like audio and input later
    // these functions are just wrappers around internal classes without exposing them
    
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
