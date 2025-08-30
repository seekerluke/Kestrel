import SwiftUI
import MetalKit

public struct KestrelView: UIViewRepresentable {
    private let game: KestrelGame
    private let renderer: Renderer
    
    public init(game: KestrelGame) {
        self.game = game
        self.renderer = Renderer(game: game)
    }
    
    public func makeUIView(context: Context) -> MTKView {
        return renderer.makeUIView()
    }
    
    public func updateUIView(_ uiView: UIViewType, context: Context) {
        // TODO: required for conformance, find a reason to use this
    }
}
