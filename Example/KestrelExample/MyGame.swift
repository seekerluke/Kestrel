import Kestrel
import MetalKit

class MyGame: KestrelGame {
    private var texture: MTLTexture?
    
    func create() {
        texture = Assets.shared.loadTexture(name: "user_texture")
    }
    
    func update(deltaTime: Float) {
        print("Updating")
    }
    
    func render(ctx: RenderContext) {
        ctx.drawQuad(position: [100, 100, 0], texture: texture)
    }
    
    func input() {
        // input events
    }
}
