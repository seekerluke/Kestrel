import Kestrel

class MyGame: KestrelGame {
    func update(deltaTime: Float) {
        print("Updating")
    }
    
    func render(ctx: RenderContext) {
        ctx.drawQuad(position: [100, 100, 0])
    }
    
    func input() {
        // input events
    }
}
