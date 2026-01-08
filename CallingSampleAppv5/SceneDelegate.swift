import UIKit
import CometChatCallsSDK
import CometChatUIKitSwift

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var currentScene: UIScene?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        currentScene = scene
        guard let _ = (scene as? UIWindowScene) else { return }
        
        // Handle deep link on cold launch
        if let userActivity = connectionOptions.userActivities.first(where: { $0.activityType == NSUserActivityTypeBrowsingWeb }),
           let url = userActivity.webpageURL {
            handleDeepLink(url: url)
        }

        initialisationCometChatCalls(completion: {
            if CometChatCalls.getLoggedInUser() == nil {
                self.setRootViewController(UINavigationController(rootViewController: LoginWithGoogleVC()))
            } else {
                let homeVC = CallsAppTabBarController()
                self.setRootViewController(homeVC)
                
                // Handle pending deep link after setting root
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.handlePendingDeepLink()
                }
            }
        })
    }

    // Universal Link handler (foreground/background)
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
              let url = userActivity.webpageURL else { return }

        handleDeepLink(url: url)
        handlePendingDeepLink()
    }

    private func handleDeepLink(url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return }

        let sessionId = components.queryItems?.first(where: { $0.name == "sessionId" })?.value
        let meetingName = components.queryItems?.first(where: { $0.name == "meetingName" })?.value

        if let sessionId = sessionId {
            print("Deep link sessionId: \(sessionId)")
            UserDefaults.standard.set(sessionId, forKey: "pendingSessionId")
        }

        if let meetingName = meetingName {
            let decodedMeetingName = meetingName.replacingOccurrences(of: "+", with: " ")
            print("Deep link meetingName: \(decodedMeetingName)")
            UserDefaults.standard.set(decodedMeetingName, forKey: "pendingMeetingName")
        }
    }

    private func handlePendingDeepLink() {
        print("Handling pending deep link...")
        guard let sessionId = UserDefaults.standard.string(forKey: "pendingSessionId") else { return }
        let meetingName = UserDefaults.standard.string(forKey: "pendingMeetingName")
        print("Handling pending deep link sessionID = \(sessionId) meetingName = \(meetingName ?? "nil")")
        
        // Check if user is logged in
        guard CometChatCalls.getLoggedInUser() != nil else {
            print("User not logged in, deep link will be handled after login")
            // Keep the pending deep link data in UserDefaults
            // It will be processed after login
            return
        }
        
        // Navigate directly to SettingController
        if let tabBarController = window?.rootViewController as? CallsAppTabBarController {
            let settingController = SettingController()
            settingController.sessionId = sessionId
            settingController.meetingName = meetingName
            
            let nav = UINavigationController(rootViewController: settingController)
            nav.modalPresentationStyle = .fullScreen
            
            // Present the SettingController
            if let presentedVC = tabBarController.presentedViewController {
                presentedVC.dismiss(animated: false) {
                    tabBarController.present(nav, animated: true)
                }
            } else {
                tabBarController.present(nav, animated: true)
            }
            
            // Clean up stored values only after successful navigation
            UserDefaults.standard.removeObject(forKey: "pendingSessionId")
            UserDefaults.standard.removeObject(forKey: "pendingMeetingName")
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
            
            let uikitSettings = UIKitSettings()
                        .set(appID: AppConstants.APP_ID)
                        .set(region: AppConstants.REGION)
                        .set(authKey: AppConstants.AUTH_KEY)
                        .subscribePresenceForAllUsers()
                        .build()
            CometChatUIKit.init(uiKitSettings: uikitSettings) { result in
                        switch result {
                        case .success:
                            debugPrint("CometChat UI Kit initialization succeeded")
                            
                        case .failure(let error):
                            debugPrint("CometChat UI Kit initialization failed with error: \(error.localizedDescription)")
                        }
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
