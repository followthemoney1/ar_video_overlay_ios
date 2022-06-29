//
//  PlayerView.swift
//  ARConcept
//
//  Created by Dmitry Dyachenko on 1/19/21.
//

import SwiftUI
import AVKit

enum PlayerGravity {
    case aspectFill
    case resize
}

class PlayerView: UIView {
    
    var player: AVPlayer? {
        get {
            return playerLayer.player
        }
        set {
            playerLayer.player = newValue
        }
    }
    
    let gravity: PlayerGravity
    
    init(player: AVPlayer, gravity: PlayerGravity) {
        self.gravity = gravity
        super.init(frame: .zero)
        self.player = player
        self.backgroundColor = .black
        setupLayer()
    }
    
    func setupLayer() {
        switch gravity {
    
        case .aspectFill:
            playerLayer.contentsGravity = .resizeAspectFill
            playerLayer.videoGravity = .resizeAspectFill
            
        case .resize:
            playerLayer.contentsGravity = .resize
            playerLayer.videoGravity = .resize
            
        }
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }
    
    // Override UIView property
    override static var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
}

//struct PlayerView_Previews: PreviewProvider {
//    static var previews: some View {
//        PlayerView(player: AVPlayer(url: URL(string: "")!), gravity: .aspectFill)
//    }
//}

final class PlayerContainerView: UIViewRepresentable {
    typealias UIViewType = PlayerView
    
    let player: AVPlayer
    let gravity: PlayerGravity
    
    init(player: AVPlayer, gravity: PlayerGravity) {
        self.player = player
        self.gravity = gravity
    }
    
    func makeUIView(context: Context) -> PlayerView {
        return PlayerView(player: player, gravity: gravity)
    }
    
    func updateUIView(_ uiView: PlayerView, context: Context) {
        
    }
}

struct PlayerContainerView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerContainerView(player: AVPlayer(url: URL(string: "")!), gravity: .aspectFill)
    }
}
