//
//  WalkThroughtView.swift
//  ARConcept
//
//  Created by Dmytro Dryl on 12.03.2021.
//

import SwiftUI

struct WalkThroughtView: View {
    @State private var selection = 0
    @State private var imageName = 1
    
    var body: some View {
        ZStack(alignment: .top){
            
            Image("onboarding_background\(imageName)")
                .resizable()
                .brightness(-0.4)
            ScrollView([], showsIndicators: false){
            VStack{
                PageTabView(selection: $selection)
                    .onChange(of: selection, perform: { value in
                        self.imageName = selection + 1
                    })
            }
            }.onAppear{
                UIScrollView.appearance().bounces = false
            }
            
            Image("Logo")
                .padding(.top, 60)
            
        }
        .transition(.move(edge: .bottom))
        .ignoresSafeArea()
    }
}

struct WalkThroughtView_Previews: PreviewProvider {
    static var previews: some View {
        WalkThroughtView()
    }
}
