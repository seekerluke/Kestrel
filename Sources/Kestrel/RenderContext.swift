import MetalKit
import simd

public class RenderContext {
    public let projection: float4x4
    
    private let encoder: MTLRenderCommandEncoder
    private var renderQueue: RenderQueue
    private var modelStack: [float4x4] = [matrix_identity_float4x4]
    
    public init(_ encoder: MTLRenderCommandEncoder, _ renderQueue: RenderQueue, _ projection: float4x4) {
        self.encoder = encoder
        self.renderQueue = renderQueue
        self.projection = projection
    }
    
    public func pushMatrix() {
        modelStack.append(modelStack.last!)
    }
    
    public func popMatrix() {
        if modelStack.count > 1 {
            modelStack.removeLast()
        }
    }
    
    public func translate(x: Float = 0, y: Float = 0, z: Float = 0) {
        modelStack[modelStack.count - 1] = modelStack.last! * float4x4.translation(x: x, y: y, z: z)
    }
    
    public func rotateX(_ angle: Float) {
        modelStack[modelStack.count - 1] = modelStack.last! * float4x4.rotationX(angle)
    }
    
    public func rotateY(_ angle: Float) {
        modelStack[modelStack.count - 1] = modelStack.last! * float4x4.rotationY(angle)
    }
    
    public func rotateZ(_ angle: Float) {
        modelStack[modelStack.count - 1] = modelStack.last! * float4x4.rotationZ(angle)
    }
    
    public func scale(x: Float = 1, y: Float = 1, z: Float = 1) {
        modelStack[modelStack.count - 1] = modelStack.last! * float4x4.scale(x: x, y: y, z: z)
    }
    
    public func drawGeometry(vertices: [Vertex], indices: [UInt16], texture: MTLTexture? = nil, uvOffset: SIMD2<Float> = [0,0], uvSize: SIMD2<Float> = [1,1]) {
        let modelMatrix = modelStack.last!
        let renderable = Renderable(vertices: vertices, indices: indices, texture: texture, uvOffset: uvOffset, uvSize: uvSize, modelMatrix: modelMatrix)
        renderQueue.items.append(renderable)
    }
    
    public func drawQuad(position: SIMD3<Float> = [0,0,0], texture: MTLTexture? = nil, sourceRect: CGRect? = nil) {
        let quadWidth = Float(texture?.width ?? 100)
        let quadHeight = Float(texture?.height ?? 100)
        
        var modelMatrix = float4x4.translation(x: position.x, y: position.y, z: position.z)
        modelMatrix *= float4x4.scale(x: quadWidth, y: quadHeight, z: 1)

        var uvOffset: SIMD2<Float> = [0,0]
        var uvSize: SIMD2<Float> = [1,1]
        if let rect = sourceRect {
            uvOffset = [Float(rect.origin.x) / quadWidth, Float(rect.origin.y) / quadHeight]
            uvSize = [Float(rect.size.width) / quadWidth, Float(rect.size.height) / quadHeight]
        }

        let renderable = Renderable(mesh: .quad, texture: texture, uvOffset: uvOffset, uvSize: uvSize, modelMatrix: modelMatrix)
        renderQueue.items.append(renderable)
    }

}
