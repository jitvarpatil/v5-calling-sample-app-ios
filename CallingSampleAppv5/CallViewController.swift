//  CallViewController.swift
//  CallingSampleAppv5
//
//  Created by Suryansh on 13/06/25.
//

import UIKit
import CometChatCallsSDK

class CallViewController: UIViewController {
    var sessionId: String?
  
  let containerView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  
  override func viewDidLoad() {
    print("CallViewController loaded")
    super.viewDidLoad()
    
    self.view.backgroundColor = UIColor(red: 0x1B/255.0, green: 0x19/255.0, blue: 0x1B/255.0, alpha: 1.0)
    
    view.addSubview(containerView)
      NSLayoutConstraint.activate([
        containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
        containerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        containerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
        containerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
      ])
    
    CallSession.shared.sessionStatusListener = self
    CallSession.shared.buttonClickListener = self
    
  }
}

extension CallViewController :  SessionStatusListener {
    func onConnectionLost() {
        print("onConnectionLost Connection lost")
    }
    func onSessionJoined() {
        print("onSessionJoined called")
    }
}

extension CallViewController :  ButtonClickListener {
    func onLeaveSessionButtonClicked() {
        print("onLeaveSessionButtonClicked Button clicked")
        // Handle leave session button click
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                let mainTabController = MainTabBarController()
                window.rootViewController = mainTabController
                window.makeKeyAndVisible()
            }
    }
    
    func onShareInviteButtonClicked() {
        print("CommonListener ButtonClickListener: onShareInviteButtonClicked")
        guard let sessionId = self.sessionId else { return }
        let inviteLink = "https://cometchat.pages.dev/?sessionId=\(sessionId)"
        print("Invite link: \(inviteLink)")
        let activityVC = UIActivityViewController(activityItems: [inviteLink], applicationActivities: nil)
        present(activityVC, animated: true, completion: nil)
    }
            
}
