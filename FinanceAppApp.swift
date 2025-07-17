//
//  FinanceAppApp.swift
//  FinanceApp
//
//  Created by Muthukutti P on 15/07/25.
//

import SwiftUI

// TODO: Add back Firebase when properly configured
// import FirebaseCore
// 
// class AppDelegate: NSObject, UIApplicationDelegate {
//     
//   func application(_ application: UIApplication,
//                    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
//     FirebaseApp.configure()
//     return true
//   }
// }

@main
struct FinanceAppApp: App {
//   @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

  var body: some Scene {
    WindowGroup {
      NavigationView {
        ContentView()
      }
    }
  }
}
