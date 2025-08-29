import MetalKit

final class Renderer: NSObject, MTKViewDelegate {
    private let device: MTLDevice
    private let commandQueue: MTLCommandQueue
    
    override init() {
        guard let device = MTLCreateSystemDefaultDevice(),
              let commandQueue = device.makeCommandQueue()
        else {
            fatalError("Metal is not supported")
        }
        
        self.device = device
        self.commandQueue = commandQueue
    }
    
    @MainActor
    func makeUIView() -> MTKView {
        let view = MTKView(frame: .zero, device: device)
        view.clearColor = MTLClearColor(red: 1, green: 1, blue: 0.8, alpha: 1)
        view.delegate = self
        return view
    }
    
    func draw(in view: MTKView) {
        guard let commandBuffer = commandQueue.makeCommandBuffer(),
              let renderPassDescriptor = view.currentRenderPassDescriptor,
              let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor),
              let drawable = view.currentDrawable
        else { return }
        
        renderEncoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        // handle resizing
    }
}
