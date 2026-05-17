//
//  quanlykhohangApp.swift
//  quanlykhohang
//
//  Created by  User on 11.05.2026.
//

//import SwiftUI
//
//@main
//struct quanlykhohangApp: App {
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//        }
//    }
//}
import SwiftUI
import FirebaseCore // Thêm dòng này

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure() // Dòng này phải nằm trong hàm này
        return true
    }
}

@main
struct quanlykhohangApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
