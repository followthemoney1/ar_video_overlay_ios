//
//  RecognitionOverlay.swift
//  ARConcept
//
//  Created by Dmitry Dyachenko on 12/18/20.
//

import Foundation

import SwiftUI

struct RecognitionOverlay: View {
    var body: some View {
        GeometryReader { geometry in
            
            ZStack(alignment: .center, content: {
                
                Image("detect_top_corner")
                    .aspectRatio(1,contentMode: .fit)
                    .padding(.all,4)
                    .shadow(radius: 2)
                    .frame(width: geometry.size.width, height: geometry.size.height, alignment: .topTrailing)
                
                Image("detect_bottom_corner")        .aspectRatio(1,contentMode: .fit)
                    .padding(.all,4)
                    .shadow(radius: 2)
                    .frame(width: geometry.size.width, height: geometry.size.height, alignment: .bottomLeading)
                
            })
        }
    }
}

struct RecognitionOverlay_Previews: PreviewProvider {
    static var previews: some View {
        RecognitionOverlay()
    }
}

struct RecognitionOverlayView: UIViewRepresentable {
    @Binding var text: String
    
    func makeUIView(context: Context) -> UITextView {
        return UITextView()
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
    }
}
