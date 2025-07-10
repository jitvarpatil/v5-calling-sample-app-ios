import UIKit
import FirebaseCore
import GoogleSignIn

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        return true
    }

    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }

    // Handle Universal Links when app is killed
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        print("App Delegate continue userActivity: \(userActivity.activityType)")
//        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
//              let url = userActivity.webpageURL,
//              let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
//              let sessionId = components.queryItems?.first(where: { $0.name == "sessionId" })?.value else { return false }
//        
//        print("App Delegate Universal Link sessionId: \(sessionId)")
//        UserDefaults.standard.set("Temp-id", forKey: "pendingSessionId")
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // No-op
    }
}
