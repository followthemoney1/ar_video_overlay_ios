//
//  TabDetailsView.swift
//  ARConcept
//
//  Created by Dmytro Dryl on 12.03.2021.
//

import SwiftUI

struct TabDetailsView: View {
    @State private var isAnimated = true
    @EnvironmentObject var onboardingModel:OnboardingViewModel
    
    let index: Int
    let currentIndex : Int
    
    var body: some View {
        ZStack {
            VStack{
                if isAnimated{
                    Image(onboardingTabs[index].image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(8)
                        .padding(.top, .random(in: 0..<50))
                        
                        .transition(.slide)
                        .animation(.easeIn(duration: 0.8))
                        
                        .rotationEffect(.degrees(.random(in: -30..<30)))
                        .brightness(.random(in: -0.6..<0))
                        
                        .offset(x: .random(in: -30..<0))
                        .animation(.spring(response: 1, dampingFraction: 2, blendDuration: 0.2))
                        
                        
                        .frame(height: .random(in: 200..<400))
                    //                        .clipped(antialiased: false)
                    Spacer()
                    Image(onboardingTabs[index].image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(8)
                        .padding(.bottom, .random(in: 10..<50))
                        
                        //MARK: - transition animation with duration
                        .transition(.slide)
                        .animation(.easeInOut(duration: 0.8))
                        
                        .rotationEffect(.degrees(.random(in: -30..<30)))
                        .brightness(.random(in: -0.6..<0))
                        
                        //MARK: - offset animation with dump
                        .offset(x: .random(in: 0..<30))
                        .animation(.spring(response: 1, dampingFraction: 3, blendDuration: 1))
                        
                        .frame(height: .random(in: 200..<400))
                }
            }.frame(minHeight: 0, maxHeight: .infinity)
            VStack{
                Spacer()
                
                Text(onboardingTabs[index].title)
                    .font(.custom("Futura", size: 34)).fontWeight(.heavy)
                
                Text(onboardingTabs[index].text)
                    .font(.custom("Gotham Pro", size: 18))
                    .multilineTextAlignment(.center)
                    .padding()
                    .frame(maxWidth: .infinity)
                
                Spacer()
                
                if index==2{
                    
                    Button(action: {
                        //MARK: - do some stuff for hiding this view
                        self.isAnimated.toggle()
                        onboardingModel.hideOnboarding = 1
                        onboardingModel.isWalkThroughtViewShowing = false
                        UserDefaults.standard.set(true, forKey: "didLaunchBefore")
                    }){
                        Text("Get started now".uppercased())
                            .fontWeight(.bold)
                            .padding()
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .background(LinearGradient(gradient: Gradient(colors: [Color(UIColor(hex: 0xFFF9536B)), Color(UIColor(hex: 0xFFC162AE)),Color(UIColor(hex: 0xFF7F6CF7))]), startPoint: .topLeading, endPoint: .bottomTrailing))
                            .cornerRadius(8)
                    }
                    .frame(height: 56)
                    .padding(.leading, 50)
                    .padding(.trailing, 50)
                }
                Spacer()
            }
        }
        .foregroundColor(.white)
        .onAppear{
            if currentIndex == index{
                withAnimation{
                    self.isAnimated = false
                }
            }
        }
        .onDisappear{
            if currentIndex == index{
                withAnimation{
                    self.isAnimated = true
                }
            }
        }
    }
}


struct TabDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        TabDetailsView(index: 0, currentIndex: 0)
    }
}
