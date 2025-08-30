public protocol KestrelGame {
    func create()
    func update(deltaTime: Float)
    func render(ctx: RenderContext)
    func input()
}
