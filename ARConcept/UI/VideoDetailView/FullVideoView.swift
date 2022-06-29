//
//  FullVideoView.swift
//  ARConcept
//
//  Created by Dmitry Dyachenko on 1/19/21.
//

import SwiftUI
import AVKit

struct FullVideoView: View {
    
    @ObservedObject private var model:FullViewViewModel = FullViewViewModel()
    private var videoPlayer: AVPlayer
    let arData:ARData
    let startTime:CMTime
    
    init(arData:ARData,startTime:CMTime) {
        self.arData = arData
        self.startTime = startTime
        self.videoPlayer = AVPlayer(url: arData.downloadVideoUrl!)
       
    }
    var body: some View {
        ZStack{
            Color.black
                //.ignoresSafeArea()
            
            MyAVPlayer(videoPlayer: videoPlayer)
                .onAppear{
                    videoPlayer.seek(to: startTime)
                    videoPlayer.play()
                }
                .onDisappear{
                    videoPlayer.pause()
                }
                .padding(.top,60)
//            VideoPlayer(player: videoPlayer)
//                .onAppear{
//                    videoPlayer.seek(to: startTime)
//                    videoPlayer.play()
//                }
//                .onDisappear{
//                    videoPlayer.pause()
//                }
//                .padding(.top,60)
               
            
            TopSheetContent(name: arData.name, link: arData.website!, phone: arData.phone!,instagramLink: arData.instagram!,facebookLink: arData.facebook!,youtubeLink: arData.directYoutubeUrl!)
            
        }
        .hideNavigationBar()
        .edgesIgnoringSafeArea(.all)
    }
}

struct FullVideoView_Previews: PreviewProvider {
    static var previews: some View {
        FullVideoView(arData: ARData(img: "", directYoutubeUrl: "", name: "", downloadVideoUrl: URL(string: ""), keyName: "", created_at: 1, facebook: "", group: "", instagram: "", labelName: "", phone: "", role: "", website: ""), startTime: .zero)
    }
}


struct MyAVPlayer : UIViewControllerRepresentable {
    let videoPlayer: AVPlayer
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<MyAVPlayer>) -> AVPlayerViewController {
        let y = Ty()
        let avPlayerViewController = AVPlayerViewController()
        
        avPlayerViewController.player = videoPlayer
        avPlayerViewController.disableGestureRecognition()
        
//        let swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(y.gestureRecognizer(_:)))
//
//        avPlayerViewController.view.addGestureRecognizer(swipeGestureRecognizer)
        return avPlayerViewController
    }
    
    
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: UIViewControllerRepresentableContext<MyAVPlayer>) {
        
    }
}

class Ty{
    
    @objc func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}
