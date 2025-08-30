import SwiftUI
import Kestrel

struct ContentView: View {
    private let game = MyGame()
    
    var body: some View {
        KestrelView(game: game)
            .ignoresSafeArea()
    }
}
