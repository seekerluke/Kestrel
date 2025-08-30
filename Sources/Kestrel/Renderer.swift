import MetalKit
import simd

public struct Vertex {
    var position: SIMD3<Float>
    var uv: SIMD2<Float>
}

final public class RenderQueue {
    var items: [Renderable] = []
}

final class Renderer: NSObject, MTKViewDelegate {
    private let device: MTLDevice
    private let commandQueue: MTLCommandQueue
    
    private let pipelineState: MTLRenderPipelineState
    private let depthState: MTLDepthStencilState
    private let samplerState: MTLSamplerState
    
    private let game: KestrelGame
    private var renderQueue = RenderQueue()
    
    init(game: KestrelGame) {
        guard let device = MTLCreateSystemDefaultDevice(),
              let commandQueue = device.makeCommandQueue()
        else {
            fatalError("Metal is not supported")
        }
        
        Assets.shared.initialize(device: device)
        
        self.game = game
        self.device = device
        self.commandQueue = commandQueue
        
        // load default shaders
        let library = try! device.makeDefaultLibrary(bundle: Bundle.module)
        let vertexFunction = library.makeFunction(name: "vertex_main")!
        let fragmentFunction = library.makeFunction(name: "fragment_main")!
        
        let vertexDescriptor = MTLVertexDescriptor()
        
        // position
        vertexDescriptor.attributes[0].format = .float3
        vertexDescriptor.attributes[0].offset = MemoryLayout.offset(of: \Vertex.position)!
        vertexDescriptor.attributes[0].bufferIndex = 0
        // uv
        vertexDescriptor.attributes[1].format = .float2
        vertexDescriptor.attributes[1].offset = MemoryLayout.offset(of: \Vertex.uv)!
        vertexDescriptor.attributes[1].bufferIndex = 0
        
        vertexDescriptor.layouts[0].stride = MemoryLayout<Vertex>.stride
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.vertexDescriptor = vertexDescriptor
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        pipelineDescriptor.depthAttachmentPixelFormat = .depth32Float
        self.pipelineState = try! device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        
        let depthDescriptor = MTLDepthStencilDescriptor()
        depthDescriptor.depthCompareFunction = .less
        depthDescriptor.isDepthWriteEnabled = true
        self.depthState = device.makeDepthStencilState(descriptor: depthDescriptor)!
        
        let samplerDescriptor = MTLSamplerDescriptor()
        samplerDescriptor.minFilter = .nearest
        samplerDescriptor.magFilter = .nearest
        self.samplerState = device.makeSamplerState(descriptor: samplerDescriptor)!
        
        game.create()
    }
    
    @MainActor
    func makeUIView() -> MTKView {
        let view = MTKView(frame: .zero, device: device)
        view.clearColor = MTLClearColor(red: 1, green: 1, blue: 0.8, alpha: 1)
        view.depthStencilPixelFormat = .depth32Float
        view.colorPixelFormat = .bgra8Unorm
        view.delegate = self
        return view
    }
    
    func draw(in view: MTKView) {
        // TODO: add delta time, core animation might have something to use here
        game.update(deltaTime: 0)
        
        guard let commandBuffer = commandQueue.makeCommandBuffer(),
              let renderPassDescriptor = view.currentRenderPassDescriptor,
              let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor),
              let drawable = view.currentDrawable
        else { return }
        
        let orthoWidth = Float(view.drawableSize.width)
        let orthoHeight = Float(view.drawableSize.height)
        let defaultProjection = float4x4.orthographic(left: 0, right: orthoWidth, bottom: orthoHeight, top: 0, near: -1000, far: 1000)
        let context = RenderContext(renderEncoder, renderQueue, defaultProjection, view.drawableSize)
        game.render(ctx: context)
        
        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setDepthStencilState(depthState)
        renderEncoder.setFragmentSamplerState(samplerState, index: 0)
        
        for renderable in renderQueue.items {
            // TODO: need view matrix
            var mvp = context.projection * renderable.modelMatrix
            renderEncoder.setVertexBytes(&mvp, length: MemoryLayout<float4x4>.stride, index: 1)
            
            if let texture = renderable.texture {
                renderEncoder.setFragmentTexture(texture, index: 0)
            }
            
            let verticesLength = MemoryLayout<Vertex>.stride * renderable.vertices.count
            let indicesLength = MemoryLayout<UInt16>.stride * renderable.indices.count
            
            renderEncoder.setVertexBytes(renderable.vertices, length: verticesLength, index: 0)
            
            let ibuf = device.makeBuffer(bytes: renderable.indices, length: indicesLength)!
            renderEncoder.drawIndexedPrimitives(type: .triangle, indexCount: renderable.indices.count, indexType: .uint16, indexBuffer: ibuf, indexBufferOffset: 0)
        }
        
        renderEncoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
        
        renderQueue.items.removeAll()
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        // handle resizing
    }
}
