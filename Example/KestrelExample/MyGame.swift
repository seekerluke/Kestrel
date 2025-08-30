import Kestrel
import MetalKit

class MyGame: KestrelGame {
    private var userTexture: MTLTexture?
    private var longBoi: MTLTexture?
    
    private var rotation: Float = 0
    
    func create() {
        userTexture = Assets.shared.loadTexture(name: "user_texture")
        longBoi = Assets.shared.loadTexture(name: "long_boi")
    }
    
    func update(deltaTime: Float) {
        rotation += 0.1
    }
    
    func render(ctx: RenderContext) {
        let aspect = Float(ctx.size.width / ctx.size.height)
        ctx.projection = float4x4.perspective(fovY: 60 * .pi / 180, aspect: aspect, nearZ: 0.1, farZ: 1000)
        
        ctx.pushMatrix()
        ctx.translate(y: -20, z: 150)
        ctx.rotateY(rotation)
        ctx.drawQuad(texture: userTexture)
        ctx.popMatrix()
        
        ctx.pushMatrix()
        ctx.translate(x: 10, y: -50, z: 100)
        ctx.rotateY(rotation)
        ctx.drawQuad(texture: longBoi)
        ctx.popMatrix()
    }
    
    func input() {
        // input events
    }
}
