//
//  SplashView.swift
//  ARConcept
//
//  Created by Dmitry Dyachenko on 5/12/21.
//

import SwiftUI

struct SplashView: View {
    @EnvironmentObject var viewModel: SplashViewModel
    
    @State var status: String = ""
    @State var isAnimating = false
    @State var progressValue: Float = 0.0
    
    var body: some View {
        ZStack{
            Image(uiImage: UIImage(named: "onboarding_background3")!)
                .resizable()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .blur(radius:  15)
            
            VStack{
                ZStack(alignment: .center){
                    ZStack{
                        Image(uiImage: UIImage(named: "logo_name_white")!)
                        Image(uiImage: UIImage(named: "logo_circle_white")!)
                            .rotationEffect(Angle(degrees: self.isAnimating ? 360 : 0.0))
                            .animation(Animation.linear(duration: 20).repeatForever(autoreverses: false), value: isAnimating)
                        
                    }
                    .scaleEffect(self.isAnimating ? 0.7: 0.4)
                    .animation(Animation.easeInOut(duration: 4)
                                .repeatForever())
                  
                    
                }
                .frame(maxHeight: .infinity)
                .padding(10)
                
                VStack{
                    Text(status)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(height: 30.0,alignment: .bottom)
                    ProgressView(value: progressValue)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                .padding(80)
                .progressViewStyle(DarkBlueShadowProgressViewStyle())
            }
        }
        .ignoresSafeArea()
        .onAppear{
            self.isAnimating = true
            self.startProgressBar()
            self.loadModel()
        }
        .onDisappear{
            self.isAnimating = false
        }
        .hideNavigationBar()
        
    }
    
    func startProgressBar() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.04) {
            if(progressValue<1){
                self.progressValue += 0.001
                if(isAnimating){
                    startProgressBar()
                }
            }
        }
    }
    
    func loadModel(){
        viewModel.downloadAIModel(onStatus: { status in
            self.status = status
        })
    }
    
}

struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView()
            .previewDevice("iPhone 12 Pro Max")
    }
}

struct DarkBlueShadowProgressViewStyle: ProgressViewStyle {
    func makeBody(configuration: Configuration) -> some View {
        ProgressView(configuration)
            .accentColor(.pink)
    }
}
