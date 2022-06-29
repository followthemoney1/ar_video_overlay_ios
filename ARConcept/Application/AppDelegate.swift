//
//  AppDelegate.swift
//  ARConcept
//
//  Created by Dmitry Dyachenko on 10/25/20.
//

import UIKit
import Firebase
import SwiftUI

@main
struct ARConceptApp: App {
  @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate

  var body: some Scene {
    WindowGroup {
        OnboardingView()
            .environmentObject(SplashViewModel())
            .environmentObject(OnboardingViewModel())
    }
  }
}

//@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    static var orientationLock = UIInterfaceOrientationMask.all

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        UIApplication.shared.endIgnoringInteractionEvents()
        UIApplication.shared.isIdleTimerDisabled = true
        UIScreen.main.brightness = CGFloat(1.0)
        
        return true
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return AppDelegate.orientationLock
    }

}

