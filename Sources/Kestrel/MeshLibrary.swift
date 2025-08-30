import MetalKit

public struct Mesh {
    let vertices: [Vertex]
    let indices: [UInt16]
}

public enum MeshType {
    case cube
    case quad
}

public final class MeshLibrary {
    // TODO: how do i tell this to be synchronous all the time
    nonisolated(unsafe) public static let shared = MeshLibrary()
    
    private let device: MTLDevice
    private var meshes: [MeshType: Mesh] = [:]
    
    private init() {
        guard let dev = MTLCreateSystemDefaultDevice() else {
            fatalError("Metal device not available")
        }
        device = dev
        
        // init common meshes
        meshes[.quad] = makeUnitQuad()
        // TODO: add cube
    }
    
    public subscript(meshType: MeshType) -> Mesh {
        guard let mesh = meshes[meshType] else {
            fatalError("Mesh not found: \(meshType)")
        }
        return mesh
    }
    
    private func makeUnitQuad() -> Mesh {
        let vertices: [Vertex] = [
            Vertex(position: [0, 0, 0], uv: [0, 0]),
            Vertex(position: [1, 0, 0], uv: [1, 0]),
            Vertex(position: [1, 1, 0], uv: [1, 1]),
            Vertex(position: [0, 1, 0], uv: [0, 1])
        ]
        let indices: [UInt16] = [0, 1, 2, 2, 3, 0]
        
        return Mesh(vertices: vertices, indices: indices)
    }
}
