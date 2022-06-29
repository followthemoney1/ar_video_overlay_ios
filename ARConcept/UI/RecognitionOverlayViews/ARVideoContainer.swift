//
//  ARVideoContainer.swift
//  ARConcept
//
//  Created by Dmitry Dyachenko on 2/1/21.
//

import SwiftUI
import AVKit
import SceneKit
import ARKit
import SpriteKit


struct ARVideoContainer: View {
    let arData:ARData
    var hostingController: (UIHostingController<ARVideoContainer>)? = nil
    var player:AVPlayer?
    
    var body: some View {
        GeometryReader{ geometry in
            VStack {
                Spacer().frame(maxHeight: .infinity)
                let aspectRation: CGFloat = geometry.size.height > 700 ? 0.10 : 0.16
                Image(uiImage: UIImage(named: "unfill_detector_image")!)
                    .resizable()
                    .frame(width: geometry.size.height * aspectRation, height: geometry.size.height * aspectRation, alignment: .center)
                    .aspectRatio(contentMode: .fit)
                    .padding()
                
                Text("Full Screen")
                    .foregroundColor(.white)
                    .padding()
                
            }
            .padding()
            .frame(maxHeight: .infinity)
            
        }
        .disabled(false)
        .allowsHitTesting(true)
        .hideNavigationBar()
    }
    
    private func setVideoInfinitive(){
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player!.currentItem, queue: nil) { (notification) in
            player!.seek(to: CMTime.zero)
            player!.play()
        }
    }
    
    func play(){
        if (player!.status == .readyToPlay) {
            player!.play()
        }
    }
    
    func pause(){
        player!.pause()
    }
    
    func empty(){
        DispatchQueue.main.async {
            player?.cancelPendingPrerolls()
            player?.replaceCurrentItem(with: nil)
            //            scene = SKScene()
            if let hostingController = hostingController{
                //MARK: is kind of bug when scene view didn't remove at all
                let frame = hostingController.view.frame
                UIApplication.shared.windows.forEach {
                    if $0.frame.width == frame.width && $0.frame.height == frame.height {
                        print($0)
                        $0.isHidden = true
                    }
                }
                hostingController.didMove(toParent: nil)
                hostingController.rootView.onDisappear(perform: {
                    
                })
                hostingController.dismiss(animated: false, completion: nil)
            }
        }
    }
    
}

struct ARVideoContainer_Previews: PreviewProvider {
    static var previews: some View {
        ARVideoContainer(arData: ARData(img: "df", directYoutubeUrl: "fe", name: "fewf", downloadVideoUrl: URL(string: "fef"), keyName: "fewf", created_at: 12, facebook: "wfew", group: "", instagram: "", labelName: "", phone: "", role: "", website: ""))
    }
}
