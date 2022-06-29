//
//  OnboardingData.swift
//  ARConcept
//
//  Created by Dmytro Dryl on 12.03.2021.
//

let onboardingTabs = [
    OnboardingPage(image: "onboarding1", title: "Welcome", text: ""),
    OnboardingPage(image: "onboarding2", title: "Create", text: "artwork with simple yet constructive functionality"),
    OnboardingPage(image: "onboarding3", title: "Share", text: "your creativity with your friends")
]

struct OnboardingPage{
    let image:String
    let title: String
    let text: String
}
