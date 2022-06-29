//
//  ARView.swift
//  ARConcept
//
//  Created by Dmitry Dyachenko on 3/12/21.
//

import SwiftUI
import AVKit

struct ARView: View {
    @State var destinationData:ARData = ARData()
    @State var destinationStartSite:CMTime = .zero
    
    @State private var isActive = false
    
    var body: some View {
        NavigationView{
            VStack{
                if(isActive){
                    NavigationLink(
                        destination: FullVideoView(arData: destinationData, startTime: destinationStartSite), isActive: $isActive){
                        EmptyView()
                    }
                }
                ARViewControllerWrapper(onNodeClick: { player, arData in
                    self.destinationData = arData
                    self.destinationStartSite = player.currentItem!.currentTime()
                    self.isActive = true
                    print("navigation changed")
                })
                .allowsHitTesting(true)
            }.onAppear{
                self.isActive = false
                UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
                           AppDelegate.orientationLock = .portrait
            }.onDisappear{
                AppDelegate.orientationLock = .all 
            }
            .ignoresSafeArea()
            .hideNavigationBar()
        }
    }
}


struct ARView_Previews: PreviewProvider {
    static var previews: some View {
        ARView()
    }
}
