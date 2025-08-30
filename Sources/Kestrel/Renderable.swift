import MetalKit

public enum MeshType {
    case cube
    case quad
}

public struct Renderable {
    let vertices: [Vertex]?
    let indices: [UInt16]?
    let meshType: MeshType?
    
    let modelMatrix: float4x4
    
    let texture: MTLTexture?
    let uvOffset: SIMD2<Float>
    let uvSize: SIMD2<Float>
    
    // use this initialiser for helpers, eg. drawQuad
    init(mesh: MeshType, texture: MTLTexture? = nil, uvOffset: SIMD2<Float> = [0,0], uvSize: SIMD2<Float> = [1,1], modelMatrix: float4x4) {
        self.meshType = mesh
        self.vertices = nil
        self.indices = nil
        self.texture = texture
        self.uvOffset = uvOffset
        self.uvSize = uvSize
        self.modelMatrix = modelMatrix
    }
    
    // use this initialiser for arbitrary geometry, eg. drawGeometry
    init(vertices: [Vertex], indices: [UInt16], texture: MTLTexture? = nil, uvOffset: SIMD2<Float> = [0,0], uvSize: SIMD2<Float> = [1,1], modelMatrix: float4x4) {
        self.vertices = vertices
        self.indices = indices
        self.meshType = nil
        self.texture = texture
        self.uvOffset = uvOffset
        self.uvSize = uvSize
        self.modelMatrix = modelMatrix
    }
}
