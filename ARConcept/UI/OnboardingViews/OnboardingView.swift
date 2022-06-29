//
//  OnboardingView.swift
//  ARConcept
//
//  Created by Dmytro Dryl on 12.03.2021.
//

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var onboardingModel:OnboardingViewModel
    @EnvironmentObject var splashModel: SplashViewModel
    @State var section:Int? = 0

    var body: some View {
        let screen:WhichMainScreen = loadScreen()
        switch screen {
        case WhichMainScreen.main:
            ARView()
        case WhichMainScreen.splash:
            SplashView()
        case WhichMainScreen.onboard:
            NavigationView{
                    VStack{
                        NavigationLink(
                            destination: ARView(),
                            tag: 1,
                            selection: $section){

                        }
                        WalkThroughtView()
                            .onReceive(onboardingModel.$hideOnboarding, perform: { _ in
                                self.section = onboardingModel.hideOnboarding
                            })

                    }
                }
        default:
            SplashView()
        }
        
       
    }
    
    func loadScreen() -> WhichMainScreen{
        if(splashModel.downloadStatus == .donwload && !onboardingModel.isWalkThroughtViewShowing){
            return .main
        }else if (splashModel.downloadStatus != .donwload && !onboardingModel.isWalkThroughtViewShowing){
            return .splash
        }else if(onboardingModel.isWalkThroughtViewShowing){
            return .onboard
        }else{
            return .splash
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}

enum WhichMainScreen{
    case splash
    case onboard
    case main
}
