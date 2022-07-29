//
//  FrFinderApp.swift
//  FrFinder
//
//  Created by David Jones on 22/07/2022.
//

import SwiftUI
import Firebase

@main
struct FrFinderApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
            let viewModel = AppViewModel()
            ContentView()
                .environmentObject(viewModel)
        }
    }
}

// Initialise firebase
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        FirebaseApp.configure()
        
        return true
    }
}


