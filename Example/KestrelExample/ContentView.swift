import SwiftUI
import Kestrel

struct ContentView: View {
    private let core = KestrelCore()
    
    var body: some View {
        KestrelView(core: core)
            .ignoresSafeArea()
    }
}
