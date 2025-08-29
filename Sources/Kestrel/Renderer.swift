import MetalKit
import simd

struct Vertex {
    var position: SIMD3<Float>
    var color: SIMD4<Float>
}

final class Renderer: NSObject, MTKViewDelegate {
    private let device: MTLDevice
    private let commandQueue: MTLCommandQueue
    private let pipelineState: MTLRenderPipelineState
    
    private let cubeVertices: [Vertex]
    private let cubeIndices: [UInt16]
    private let vertexBuffer: MTLBuffer
    private let indexBuffer: MTLBuffer
    
    private let depthState: MTLDepthStencilState
    
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
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.attributes[0].bufferIndex = 0
        // color
        vertexDescriptor.attributes[1].format = .float4
        vertexDescriptor.attributes[1].offset = MemoryLayout<SIMD3<Float>>.stride
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
        
        // placeholder cube vertices and indices
        self.cubeVertices = [
            // front face
            Vertex(position: [-1, -1, 1], color: [1, 0, 0, 1]),
            Vertex(position: [1, -1, 1], color: [0, 1, 0, 1]),
            Vertex(position: [1, 1, 1], color: [0, 0, 1, 1]),
            Vertex(position: [-1, 1, 1], color: [1, 1, 0, 1]),

            // back face
            Vertex(position: [-1, -1, -1], color: [1, 0, 1, 1]),
            Vertex(position: [1, -1, -1], color: [0, 1, 1, 1]),
            Vertex(position: [1, 1, -1], color: [1, 1, 1, 1]),
            Vertex(position: [-1, 1, -1], color: [0, 0, 0, 1]),
        ]
        
        self.cubeIndices = [
            // Front
            0, 1, 2, 2, 3, 0,
            // Right
            1, 5, 6, 6, 2, 1,
            // Back
            5, 4, 7, 7, 6, 5,
            // Left
            4, 0, 3, 3, 7, 4,
            // Top
            3, 2, 6, 6, 7, 3,
            // Bottom
            4, 5, 1, 1, 0, 4
        ]
        
        self.vertexBuffer = device.makeBuffer(bytes: cubeVertices, length: MemoryLayout<Vertex>.stride * cubeVertices.count)!
        self.indexBuffer = device.makeBuffer(bytes: cubeIndices, length: MemoryLayout<UInt16>.stride * cubeIndices.count)!
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
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        
        rotation += 0.01
        let aspect = Float(view.drawableSize.width / view.drawableSize.height)
        let projection = float4x4.perspective(fovY: .pi/4, aspect: aspect, nearZ: 0.1, farZ: 100)
        let viewMatrix = float4x4.translation(0, 0, -10)
        let modelMatrix = float4x4.rotationY(rotation)
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

// temporary AI functions
extension float4x4 {
    static func perspective(fovY: Float, aspect: Float, nearZ: Float, farZ: Float) -> float4x4 {
        let y = 1 / tan(fovY * 0.5)
        let x = y / aspect
        let zRange = farZ - nearZ
        let z = -(farZ + nearZ) / zRange
        let wz = -2 * farZ * nearZ / zRange

        return float4x4([
            SIMD4<Float>(x, 0, 0, 0),
            SIMD4<Float>(0, y, 0, 0),
            SIMD4<Float>(0, 0, z, -1),
            SIMD4<Float>(0, 0, wz, 0)
        ])
    }

    static func translation(_ x: Float, _ y: Float, _ z: Float) -> float4x4 {
        var matrix = matrix_identity_float4x4
        matrix.columns.3 = [x, y, z, 1]
        return matrix
    }

    static func rotationY(_ angle: Float) -> float4x4 {
        let c = cos(angle)
        let s = sin(angle)
        return float4x4([
            SIMD4<Float>( c, 0, s, 0),
            SIMD4<Float>( 0, 1, 0, 0),
            SIMD4<Float>(-s, 0, c, 0),
            SIMD4<Float>( 0, 0, 0, 1)
        ])
    }

    init(_ columns: [SIMD4<Float>]) {
        self.init()
        self.columns = (columns[0], columns[1], columns[2], columns[3])
    }
}
