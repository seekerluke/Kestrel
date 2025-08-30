import MetalKit

public struct Renderable {
    let vertices: [Vertex]
    let indices: [UInt16]
    
    let modelMatrix: float4x4
    
    let texture: MTLTexture?
    let uvOffset: SIMD2<Float>
    let uvSize: SIMD2<Float>
    
    init(vertices: [Vertex], indices: [UInt16], texture: MTLTexture? = nil, uvOffset: SIMD2<Float> = [0,0], uvSize: SIMD2<Float> = [1,1], modelMatrix: float4x4) {
        self.vertices = vertices
        self.indices = indices
        self.texture = texture
        self.uvOffset = uvOffset
        self.uvSize = uvSize
        self.modelMatrix = modelMatrix
    }
}
