
import UIKit
import CometChatCallsSDK

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var currentScene: UIScene?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        currentScene = scene
        guard let _ = (scene as? UIWindowScene) else { return }
        
        if let userActivity = connectionOptions.userActivities.first(where: { $0.activityType == NSUserActivityTypeBrowsingWeb }),
               let url = userActivity.webpageURL,
               let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
               let sessionId = components.queryItems?.first(where: { $0.name == "sessionId" })?.value {
                print("Cold launch Universal Link sessionId: \(sessionId)")
                UserDefaults.standard.set(sessionId, forKey: "pendingSessionId")
            }

        initialisationCometChatCalls(completion: {
            if CometChatCalls.getLoggedInUser() == nil {
                self.setRootViewController(UINavigationController(rootViewController: LoginWithGoogleVC()))
            } else {
                let homeVC = MainTabBarController()
                // Check for pending sessionId from Universal Link
                if let sessionId = UserDefaults.standard.string(forKey: "pendingSessionId") {
 //                   homeVC.sessionTextFiled.text = sessionId
//                    UserDefaults.standard.removeObject(forKey: "pendingSessionId")
                }
                self.setRootViewController(homeVC)
            }
        })
    }

    // Universal Link handler (foreground/background)
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
              let url = userActivity.webpageURL,
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let sessionId = components.queryItems?.first(where: { $0.name == "sessionId" })?.value else { return }
        UserDefaults.standard.set(sessionId, forKey: "pendingSessionId")
        print("Universal Link sessionId: \(sessionId)")
        // Try to get HomeViewController and set sessionId
        if let nav = window?.rootViewController as? UINavigationController,
           let homeVC = nav.viewControllers.first(where: { $0 is HomeViewController }) as? HomeViewController {
            homeVC.sessionTextFiled.text = sessionId
        } else if let homeVC = window?.rootViewController as? HomeViewController {
            homeVC.sessionTextFiled.text = sessionId
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) { }
    func sceneDidBecomeActive(_ scene: UIScene) { }
    func sceneWillResignActive(_ scene: UIScene) { }
    func sceneWillEnterForeground(_ scene: UIScene) { }
    func sceneDidEnterBackground(_ scene: UIScene) { }

    func initialisationCometChatCalls(completion: @escaping () -> ()) {
        if AppConstants.APP_ID.isEmpty || AppConstants.AUTH_KEY.isEmpty || AppConstants.REGION.isEmpty {
            print("Incorrect App Constants")
            completion()
        } else {
            let callSettings = CallAppSettingsBuilder()
                .set(appID: AppConstants.APP_ID)
                .set(region: AppConstants.REGION)
                .set(authKey: AppConstants.AUTH_KEY)
                .build()

            CometChatCalls.init(callsAppSettings: callSettings) { successMessage in
                print("CometChatCalls Init success with message: \(successMessage)")
                completion()
            } onError: { error in
                print("CometChatCalls Init failed with error: \(error?.errorDescription ?? "")")
                completion()
            }
        }
    }

    func setRootViewController(_ viewController: UIViewController){
        guard let scene = (currentScene as? UIWindowScene) else { return }
        UIView.animate(withDuration: 0.2) {  [weak self] in
            guard let self else { return }
            window = UIWindow(frame: scene.coordinateSpace.bounds)
            window?.tintColor = CometChatTheme.primaryColor
            window?.windowScene = scene

            // Fade transition
            let transition = CATransition()
            transition.type = .fade
            transition.duration = 0.3
            window?.layer.add(transition, forKey: kCATransition)

            window?.rootViewController = viewController
            window?.makeKeyAndVisible()
        }
    }
}
