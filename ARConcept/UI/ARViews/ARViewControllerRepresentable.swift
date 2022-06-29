//
//  ARViewControllerRepresentable.swift
//  ARConcept
//
//  Created by Dmitry Dyachenko on 3/12/21.
//

import Foundation
import SwiftUI
import AVKit

struct ARViewControllerWrapper: UIViewControllerRepresentable {
    typealias UIViewControllerType = ARController
    let onNodeClick:((AVPlayer,ARData)->Void)
    
    class Coordinator: NSObject,UINavigationControllerDelegate {
        
        var parent: ARViewControllerWrapper

        init(_ parent: ARViewControllerWrapper) {
            self.parent = parent
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ARViewControllerWrapper>) -> ARController {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
          guard let arViewController =  storyboard.instantiateViewController(
            identifier: "ARController") as? ARController else {
              fatalError("Cannot load from storyboard")
          }
        arViewController.modalPresentationStyle = .fullScreen
        arViewController.view.isUserInteractionEnabled = true

        arViewController.onNodeClick = self.onNodeClick
        
        return arViewController
    }
    

    func updateUIViewController(_ uiViewController: ARController, context: UIViewControllerRepresentableContext<ARViewControllerWrapper>) {
    }
}
