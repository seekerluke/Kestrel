import MetalKit
import simd

struct Vertex {
    var position: SIMD3<Float>
    var uv: SIMD2<Float>
}

final class Renderer: NSObject, MTKViewDelegate {
    private let device: MTLDevice
    private let commandQueue: MTLCommandQueue
    
    private let cubeVertices: [Vertex]
    private let cubeIndices: [UInt16]
    private let vertexBuffer: MTLBuffer
    private let indexBuffer: MTLBuffer
    
    private let texture: MTLTexture
    
    private let pipelineState: MTLRenderPipelineState
    private let depthState: MTLDepthStencilState
    private let samplerState: MTLSamplerState
    
    private var rotation: Float = 0
    
    override init() {
        guard let device = MTLCreateSystemDefaultDevice(),
              let commandQueue = device.makeCommandQueue()
        else {
            fatalError("Metal is not supported")
        }
        
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
        
        // 6 faces × 4 vertices per face
        self.cubeVertices = [
            // Front (+Z)
            Vertex(position: [-1, -1,  1], uv: [0, 0]),
            Vertex(position: [ 1, -1,  1], uv: [1, 0]),
            Vertex(position: [ 1,  1,  1], uv: [1, 1]),
            Vertex(position: [-1,  1,  1], uv: [0, 1]),

            // Back (-Z)
            Vertex(position: [ 1, -1, -1], uv: [0, 0]),
            Vertex(position: [-1, -1, -1], uv: [1, 0]),
            Vertex(position: [-1,  1, -1], uv: [1, 1]),
            Vertex(position: [ 1,  1, -1], uv: [0, 1]),

            // Left (-X)
            Vertex(position: [-1, -1, -1], uv: [0, 0]),
            Vertex(position: [-1, -1,  1], uv: [1, 0]),
            Vertex(position: [-1,  1,  1], uv: [1, 1]),
            Vertex(position: [-1,  1, -1], uv: [0, 1]),

            // Right (+X)
            Vertex(position: [ 1, -1,  1], uv: [0, 0]),
            Vertex(position: [ 1, -1, -1], uv: [1, 0]),
            Vertex(position: [ 1,  1, -1], uv: [1, 1]),
            Vertex(position: [ 1,  1,  1], uv: [0, 1]),

            // Top (+Y)
            Vertex(position: [-1,  1,  1], uv: [0, 0]),
            Vertex(position: [ 1,  1,  1], uv: [1, 0]),
            Vertex(position: [ 1,  1, -1], uv: [1, 1]),
            Vertex(position: [-1,  1, -1], uv: [0, 1]),

            // Bottom (-Y)
            Vertex(position: [-1, -1, -1], uv: [0, 0]),
            Vertex(position: [ 1, -1, -1], uv: [1, 0]),
            Vertex(position: [ 1, -1,  1], uv: [1, 1]),
            Vertex(position: [-1, -1,  1], uv: [0, 1])
        ]

        self.cubeIndices = [
            0, 1, 2, 2, 3, 0,       // front
            4, 5, 6, 6, 7, 4,       // back
            8, 9,10,10,11, 8,       // left
           12,13,14,14,15,12,       // right
           16,17,18,18,19,16,       // top
           20,21,22,22,23,20        // bottom
        ]
        
        self.vertexBuffer = device.makeBuffer(bytes: cubeVertices, length: MemoryLayout<Vertex>.stride * cubeVertices.count)!
        self.indexBuffer = device.makeBuffer(bytes: cubeIndices, length: MemoryLayout<UInt16>.stride * cubeIndices.count)!
        
        let textureLoader = MTKTextureLoader(device: device)
        let textureUrl = Bundle.module.url(forResource: "default", withExtension: "png")!
        texture = try! textureLoader.newTexture(URL: textureUrl)
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
        guard let commandBuffer = commandQueue.makeCommandBuffer(),
              let renderPassDescriptor = view.currentRenderPassDescriptor,
              let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor),
              let drawable = view.currentDrawable
        else { return }
        
        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setDepthStencilState(depthState)
        
        renderEncoder.setFragmentTexture(texture, index: 0)
        renderEncoder.setFragmentSamplerState(samplerState, index: 0)
        
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        
        // placeholder perspective matrix with rotation
        rotation += 0.01
        let aspect = Float(view.drawableSize.width / view.drawableSize.height)
        let projection = float4x4.perspective(fovY: .pi / 4, aspect: aspect, nearZ: 0.1, farZ: 100)
        let viewMatrix = float4x4.translation(x: 0, y: 0, z: -10)
        let modelMatrix = float4x4.rotationX(rotation) * float4x4.rotationY(rotation) * float4x4.scale(x: 2, y: 2)
        var mvp = projection * viewMatrix * modelMatrix
        
        renderEncoder.setVertexBytes(&mvp, length: MemoryLayout<float4x4>.stride, index: 1)
        
        renderEncoder.drawIndexedPrimitives(type: .triangle, indexCount: cubeIndices.count, indexType: .uint16, indexBuffer: indexBuffer, indexBufferOffset: 0)
        
        renderEncoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        // handle resizing
    }
}
