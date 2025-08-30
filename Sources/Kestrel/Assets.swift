import MetalKit

public final class Assets {
    // TODO: asynchronous loading, need to understand concurrency better before attempting that
    nonisolated(unsafe) public static let shared = Assets()
    
    private var device: MTLDevice!
    private var textureLoader: MTKTextureLoader!
    private var textures: [String: MTLTexture] = [:]
    
    private init() {}
    
    public func initialize(device: MTLDevice) {
        self.device = device
        self.textureLoader = MTKTextureLoader(device: device)
    }
    
    public func loadTexture(name: String, fileExtension: String = "png", bundle: Bundle = .main) -> MTLTexture {
        guard let textureLoader = textureLoader else {
            fatalError("Must call Assets.shared.initialize() before loading anything.")
        }
    
        if let cached = textures[name] {
            return cached
        }
        
        guard let url = bundle.url(forResource: name, withExtension: fileExtension) else {
            fatalError("Texture \(name).\(fileExtension) not found in bundle")
        }
        
        do {
            let texture = try textureLoader.newTexture(URL: url)
            textures[name] = texture
            return texture
        } catch {
            fatalError("Failed to load texture \(name): \(error)")
        }
    }
    
    public func texture(named name: String) -> MTLTexture? {
        return textures[name]
    }
}
