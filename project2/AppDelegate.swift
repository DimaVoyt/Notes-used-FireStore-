//
//  AppDelegate.swift
//  project2
//
//  Created by Дмитрий Войтович on 14.04.2022.
//

import UIKit
import Firebase

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    let navigationController: MainNavigationController = {
        let c = MainNavigationController()
        return c
    }()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        window?.backgroundColor = UIColor.black
        window?.rootViewController = navigationController
        
        return true
    }
}

class MainNavigationController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if Auth.auth().currentUser != nil {
            switchToMain()
        } else {
            switchToLogin()
        }
        if #available(iOS 15, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .systemMint
            navigationBar.isTranslucent = false
            
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        }
    }
    
    func switchToLogin() {
        let loginController = LoginController()
        setViewControllers([loginController], animated: false)
    }
    
    func switchToMain() {
        let viewController = NotesListViewController()
        setViewControllers([viewController], animated: false)
    }
}

var navigation: MainNavigationController {
    return (UIApplication.shared.delegate as! AppDelegate).navigationController
}

infix operator |: AdditionPrecedence
public extension UIColor {
    static func | (lightMode: UIColor, darkMode: UIColor) -> UIColor {
        guard #available(iOS 13.0, *) else { return lightMode }
        return UIColor { (traitCollection) -> UIColor in
            return traitCollection.userInterfaceStyle == .light ? lightMode : darkMode
        }
    }
}
