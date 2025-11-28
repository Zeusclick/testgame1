import SwiftUI
import SpriteKit

struct GameView: View {
    @ObservedObject var viewModel: GameViewModel

    var body: some View {
        GeometryReader { geometry in
            SpriteView(scene: viewModel.scene, options: [.allowsTransparency])
                .background(Color.black)
                .onAppear {
                    viewModel.updateViewport(size: geometry.size)
                }
                .onChange(of: geometry.size) { newSize in
                    viewModel.updateViewport(size: newSize)
                }
        }
    }
}

#Preview {
    GameView(viewModel: GameViewModel())
}
