//
//  OnboardingViewModel.swift
//  ARConcept
//
//  Created by Dmitry Dyachenko on 3/17/21.
//

import Foundation


class OnboardingViewModel: ObservableObject {
    @Published var hideOnboarding:Int? = 0
    @Published var isWalkThroughtViewShowing = false
    @Published var dontShowOnBoarding = UserDefaults.standard.bool(forKey: "didLaunchBefore")
    
    init() {
            isWalkThroughtViewShowing = !dontShowOnBoarding
    }
}
