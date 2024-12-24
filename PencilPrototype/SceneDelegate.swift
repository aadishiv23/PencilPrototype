////
////  SceneDelegate.swift
////  PencilPrototype
////
////  Created by Aadi Shiv Malhotra on 12/2/24.
////
//
//import UIKit
//
//class SceneDelegate: UIResponder, UIWindowSceneDelegate {
//
//    var window: UIWindow?
//
//    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
//        guard let windowScene = (scene as? UIWindowScene) else { return }
//        let window = UIWindow(windowScene: windowScene)
//        window.rootViewController = ViewController()
//        self.window = window
//        window.makeKeyAndVisible()
//    }
//
//    func sceneDidDisconnect(_ scene: UIScene) {}
//    func sceneDidBecomeActive(_ scene: UIScene) {}
//    func sceneWillResignActive(_ scene: UIScene) {}
//    func sceneWillEnterForeground(_ scene: UIScene) {}
//    func sceneDidEnterBackground(_ scene: UIScene) {}
//}
//
//  SceneDelegate.swift
//  PencilPrototype
//
//  Created by Aadi Shiv Malhotra on 12/2/24.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)

        let homeVC = HomeViewController()
        let navController = UINavigationController(rootViewController: homeVC)
        window.rootViewController = navController

        self.window = window
        window.makeKeyAndVisible()
    }
}
