public protocol KestrelGame {
    func update(deltaTime: Float)
    func render(ctx: RenderContext)
    func input()
}
