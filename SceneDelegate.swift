//
//  SceneDelegate.swift
//  ChatAppWithFirebase
//
//  Created by 吉田　知代 on 2020/08/13.
//  Copyright © 2020 吉田　知代. All rights reserved.
//

import UIKit
import FirebaseAuth

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


     func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
          
        if Auth.auth().currentUser?.uid != nil {

                // ログインしている場合
                let window = UIWindow(windowScene: scene as! UIWindowScene)
                self.window = window
                window.makeKeyAndVisible()

            let storyboard = UIStoryboard(name: "Home", bundle: nil)
             let HomeTableViewController = storyboard.instantiateViewController(identifier: "HomeTableViewController")
             let nav = UINavigationController(rootViewController: HomeTableViewController)

            
            
            
            
            window.rootViewController = nav
            guard let _ = (scene as? UIWindowScene) else { return }

            } else {

                // ログインしてない場合
                let window = UIWindow(windowScene: scene as! UIWindowScene)
                self.window = window
                window.makeKeyAndVisible()

                let storyboard = UIStoryboard(name: "TermsOfUse", bundle: nil)
                 let TermsOfUseViewController = storyboard.instantiateViewController(identifier: "TermsOfUseViewController")
                 let nav = UINavigationController(rootViewController: TermsOfUseViewController)
                
                window.rootViewController = nav
                guard let _ = (scene as? UIWindowScene) else { return }
            }

            guard let _ = (scene as? UIWindowScene) else { return }
          

        
        



     
        

          
         
      }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

