import MetalKit

final class Renderer: NSObject, MTKViewDelegate {
    private let commandQueue: MTLCommandQueue
    
    init(device: MTLDevice) {
        guard let cq = device.makeCommandQueue() else {
            fatalError("Command queue could not be initialised")
        }
        commandQueue = cq
    }
    
    func draw(in view: MTKView) {
        guard let commandBuffer = commandQueue.makeCommandBuffer(),
              let renderPassDescriptor = view.currentRenderPassDescriptor,
              let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor),
              let drawable = view.currentDrawable else { return }
        
        renderEncoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        // handle resizing
    }
}
