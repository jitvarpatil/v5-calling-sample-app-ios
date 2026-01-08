//  CallViewController.swift
//  CallingSampleAppv5
//
//  Created by Suryansh on 13/06/25.
//

import UIKit
import CometChatCallsSDK
import FirebaseCrashlytics
import CometChatSDK
import CometChatUIKitSwift

class CallViewController: UIViewController {
    var sessionId: String?
    var meetingName: String?
    var group: CometChatSDK.Group?
    
    // Unread message count
    private var unreadMessageCount = 0
    private let messageListenerId = "CallSessionMessageListener"
  
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
        setupListeners()
        addMessageListener()
    }
    
    deinit {
        removeMessageListener()
    }
    
    private func setupListeners() {
        CallSession.shared.addSessionStatusListener(self)
        CallSession.shared.addButtonClickListener(self)
    }
    
    // MARK: - Message Listener
    
    private func addMessageListener() {
        CometChat.addMessageListener(messageListenerId, self)
        print("Message listener added for unread count")
    }
    
    private func removeMessageListener() {
        CometChat.removeMessageListener(messageListenerId)
        print("Message listener removed")
    }
}

extension CallViewController: SessionStatusListener {
    func onConnectionLost() {
        print("Callview controller " + "onConnectionLost Connection lost")
        Crashlytics.crashlytics().log("Connection lost in call session")
    }
    
    func onSessionJoined() {
        print("Callview controller "+"onSessionJoined called")
        setGroup(guid: sessionId ?? "", meetingName: meetingName ?? "Group Chat")
        Crashlytics.crashlytics().log("Session joined successfully")
    }
    
    func onSessionLeft() {
        print("Callview controller "+"onSessionLeft Button clicked")
        Crashlytics.crashlytics().log("Session left")
    }
    
    func onConnectionClosed() {
        print("Callview controller "+"onConnectionClosed Connection closed")
        Crashlytics.crashlytics().log("Connection closed")
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            let mainTabController = CallsAppTabBarController()
            window.rootViewController = mainTabController
            window.makeKeyAndVisible()
        }
    }
}

extension CallViewController: ButtonClickListener {
    
    func onLeaveSessionButtonClicked() {
        print("Callview controller "+"onLeaveSessionButtonClicked Button clicked")
        Crashlytics.crashlytics().log("Leave session button clicked")
    }
    
    func onShareInviteButtonClicked() {
        print("Callview controller "+"CommonListener ButtonClickListener: onShareInviteButtonClicked")
        
        guard let sessionId = self.sessionId else {
            Crashlytics.crashlytics().log("Share invite clicked but sessionId is nil")
            return
        }
        
        print("Callview controller "+"Session ID: \(sessionId)")
        print("Callview controller "+"Meeting Name: \(String(describing: self.meetingName))")
        
        var inviteLink = "https://calls.cometchat.io/?sessionId=\(sessionId)"
        
        // Add meeting name if available
        if let meetingName = self.meetingName,
           let encodedName = meetingName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            inviteLink += "&meetingName=\(encodedName)"
        }
        
        print("Callview controller Invite link: \(inviteLink)")
        
        Crashlytics.crashlytics().log("Share invite link generated: \(inviteLink)")
        
        let activityVC = UIActivityViewController(activityItems: [inviteLink], applicationActivities: nil)
        present(activityVC, animated: true, completion: nil)
    }
    
    func onChatButtonClicked() {
        print(" Callview controller "+"CommonListener ButtonClickListener: onChatButtonClicked")
        Crashlytics.crashlytics().log("Chat button clicked")
        
        // Reset unread count when chat is opened
        unreadMessageCount = 0
        CallSession.shared.setChatButtonUnreadCount(unreadMessageCount)
        
        guard let meetingName = self.meetingName,
              let sessionId = self.sessionId else {
            print("Meeting name or session ID is nil, cannot open chat")
            Crashlytics.crashlytics().log("Chat button clicked but meetingName or sessionId is nil")
            return
        }
        
        let chatController = ChatController()
        print("Callview controller group \(self.group?.name ?? "No group")")
        chatController.group = self.group
        let navController = UINavigationController(rootViewController: chatController)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true)
    }
    
    
    func setGroup(guid: String, meetingName: String) {
        guard !guid.isEmpty else { return }

        // Show loading state if you have a progress indicator
        print("Fetching group with GUID: \(guid)")
        CometChat.getGroup(GUID: guid) { [weak self] group in
            guard let self = self else { return }

            if !group.hasJoined {
                CometChat.joinGroup(GUID: guid, groupType: group.groupType, password: nil) { joinedGroup in
                    self.group = group
                } onError: { error in
                    print("Group joining failed with exception: \(error?.errorDescription ?? "Unknown error")")
                }
            } else {
                self.group = group
            }

        } onError: { [weak self] error in
            guard let self = self else { return }

            if error?.errorCode == "ERR_GUID_NOT_FOUND" {
                let newGroup = CometChatSDK.Group(guid: guid, name: meetingName, groupType: .public, password: nil)

                CometChat.createGroup(group: newGroup) { createdGroup in
                    self.group = createdGroup
                } onError: { error in
                    // Hide loading state
                    print("Group creation failed: \(error?.errorDescription ?? "Unknown error")")
                }
            } else {
                // Hide loading state
                print("Get group failed: \(error?.errorDescription ?? "Unknown error")")
            }
        }
    }
}


// MARK: - CometChatMessageDelegate
extension CallViewController: CometChatMessageDelegate {
    
    func onTextMessageReceived(textMessage: TextMessage) {
        handleIncomingMessage(textMessage)
    }
    
    func onMediaMessageReceived(mediaMessage: MediaMessage) {
        handleIncomingMessage(mediaMessage)
    }
    
    func onCustomMessageReceived(customMessage: CustomMessage) {
        handleIncomingMessage(customMessage)
    }
    
    private func handleIncomingMessage(_ message: BaseMessage) {
        // Check if message is for current session's group
        guard let group = message.receiver as? CometChatSDK.Group,
              group.guid == sessionId else {
            return
        }
        
        // Don't count own messages
        guard message.sender?.uid != CometChat.getLoggedInUser()?.uid else {
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.unreadMessageCount += 1
            CallSession.shared.setChatButtonUnreadCount(self.unreadMessageCount)
            print("Unread message count updated: \(self.unreadMessageCount)")
        }
    }
}
