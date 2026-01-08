import UIKit
import AVFoundation
import CometChatCallsSDK
import FirebaseAuth

class HomeViewController: UIViewController {
    
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var captureSession: AVCaptureSession?
    
    lazy var avatarView = buildAvatar()
    lazy var videoLayer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var previewView: UIView = {
        let view = UIView()
        view.backgroundColor = CometChatTheme.backgroundColor03
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(videoLayer)
        view.addSubview(videoButton)
        view.addSubview(audioButton)
        
        videoLayer.addSubview(avatarView)
        
        NSLayoutConstraint.activate([
            videoLayer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            videoLayer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            videoLayer.topAnchor.constraint(equalTo: view.topAnchor),
            videoLayer.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            avatarView.centerXAnchor.constraint(equalTo: videoLayer.centerXAnchor),
            avatarView.centerYAnchor.constraint(equalTo: videoLayer.centerYAnchor),
        ])
        
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: 300),
            view.widthAnchor.constraint(equalToConstant: 200),
            videoButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            videoButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),
            audioButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            audioButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20)
        ])
        
        view.layer.cornerRadius = 15
        view.layer.masksToBounds = true

        return view
    }()
    
    lazy var videoButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(onCameraButtonTapped), for: .primaryActionTriggered)
        button.heightAnchor.constraint(equalToConstant: 40).isActive = true
        button.widthAnchor.constraint(equalToConstant: 40).isActive = true
        button.setImage(IconConstants.pausedVideoIcon, for: .normal)
        button.layer.cornerRadius = 20
        button.tintColor = .white
        button.layer.masksToBounds = true
        button.backgroundColor = .gray.withAlphaComponent(0.4)
        return button
    }()
    
    lazy var audioButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(onAudioButtonTapped), for: .primaryActionTriggered)
        button.heightAnchor.constraint(equalToConstant: 40).isActive = true
        button.widthAnchor.constraint(equalToConstant: 40).isActive = true
        button.setImage(IconConstants.mutedAudioIcon, for: .normal)
        button.tintColor = .white
        button.layer.cornerRadius = 20
        button.layer.masksToBounds = true
        button.backgroundColor = .gray.withAlphaComponent(0.4)
        return button
    }()
    
    lazy var sessionTextFiled: UITextField = {
        let textFiled = UITextField()
        textFiled.translatesAutoresizingMaskIntoConstraints = false
        textFiled.placeholder = "Enter Session ID here"
        textFiled.heightAnchor.constraint(equalToConstant: 40).isActive = true
        textFiled.layer.cornerRadius = 5
        textFiled.layer.borderWidth = 0.5
        textFiled.setLeftPaddingPoints(10)
        textFiled.setRightPaddingPoints(10)
        textFiled.layer.borderColor = CometChatTheme.borderColorDefault.cgColor
        return textFiled
    }()

    lazy var startMeetingButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 40).isActive = true
        button.setTitle("Start Meeting", for: .normal)
        button.layer.cornerRadius = 15
        button.layer.masksToBounds = true
        button.backgroundColor = CometChatTheme.primaryColor
        button.addTarget(self, action: #selector(startCall), for: .primaryActionTriggered)
        return button
    }()
    
    lazy var startInstanceMettingButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 40).isActive = true
        button.setTitle("Start Instant Meeting", for: .normal)
        button.layer.borderWidth = 2
        button.layer.borderColor = CometChatTheme.primaryColor.cgColor
        button.layer.cornerRadius = 15
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(startCall), for: .primaryActionTriggered)
        return button
    }()
    
    // Keep a reference to containerView for keyboard handling
    var containerView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 27/255.0, green: 25/255.0, blue: 27/255.0, alpha: 1.0)
        setupUI()
        // Add logout button to navigation bar
        addCustomLogoutButton()
        
        navigationItem.rightBarButtonItem?.tintColor = .white
        // Keyboard observers
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func logoutTapped() {
        // Logout from CometChat
        CometChatCalls.logout { _ in
            print("CometChat logout successful")
        } onError: { error in
            print("CometChat logout error: \(error.errorDescription)")
        }
        // Logout from Firebase
        do {
            try Auth.auth().signOut()
            // Return to login screen
            if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                let loginVC = LoginWithGoogleVC()
                let nav = UINavigationController(rootViewController: loginVC)
                sceneDelegate.setRootViewController(nav)
            }
        } catch {
            print("Firebase sign out error: \(error.localizedDescription)")
        }
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func addCustomLogoutButton() {
        let logoutButton = UIButton(type: .system)
        logoutButton.setTitle("Logout", for: .normal)
        logoutButton.setTitleColor(.white, for: .normal)
        logoutButton.backgroundColor = .systemRed
        logoutButton.layer.cornerRadius = 8
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        logoutButton.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)
        view.addSubview(logoutButton)
        NSLayoutConstraint.activate([
            logoutButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            logoutButton.widthAnchor.constraint(equalToConstant: 80),
            logoutButton.heightAnchor.constraint(equalToConstant: 36)
        ])
    }
    
    func setupUI() {
        view.addSubview(previewView)
        NSLayoutConstraint.activate([
            previewView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            previewView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        let sessionIDLabel = UILabel()
        sessionIDLabel.translatesAutoresizingMaskIntoConstraints = false
        sessionIDLabel.text = "Session ID"
        
        // Setting up container view
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = CometChatTheme.backgroundColor01
        containerView.layer.cornerRadius = 15
        containerView.layer.masksToBounds = true
        containerView.addSubview(sessionIDLabel)
        NSLayoutConstraint.activate([
            sessionIDLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 30),
            sessionIDLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
        ])
        
        containerView.addSubview(sessionTextFiled)
        NSLayoutConstraint.activate([
            sessionTextFiled.topAnchor.constraint(equalTo: sessionIDLabel.bottomAnchor, constant: 5),
            sessionTextFiled.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            sessionTextFiled.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
        ])
        
        containerView.addSubview(startMeetingButton)
        NSLayoutConstraint.activate([
            startMeetingButton.topAnchor.constraint(equalTo: sessionTextFiled.bottomAnchor, constant: 15),
            startMeetingButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            startMeetingButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
        ])
        
        containerView.addSubview(startInstanceMettingButton)
        NSLayoutConstraint.activate([
            startInstanceMettingButton.topAnchor.constraint(equalTo: startMeetingButton.bottomAnchor, constant: 15),
            startInstanceMettingButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            startInstanceMettingButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            startInstanceMettingButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20)
        ])
        
        view.addSubview(containerView)
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: previewView.bottomAnchor, constant: 30),
            containerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            containerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
        ])
        self.containerView = containerView
    }
    
    // Keyboard handling to keep sessionTextFiled visible
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let containerView = self.containerView else { return }
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            let bottomSpace = self.view.frame.height - (sessionTextFiled.superview?.convert(sessionTextFiled.frame, to: self.view).maxY ?? 0)
            let overlap = keyboardFrame.height - bottomSpace + 20 // 20 for padding
            if overlap > 0 {
                self.view.frame.origin.y = -overlap
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        self.view.frame.origin.y = 0
    }
    
    @objc func onAudioButtonTapped() {
        if audioButton.tag == 0 {
            audioButton.setImage(IconConstants.audioIcon, for: .normal)
            audioButton.tag = 1
        } else {
            audioButton.tag = 0
            audioButton.setImage(IconConstants.mutedAudioIcon, for: .normal)
        }
    }
    
    @objc func onCameraButtonTapped() {
        if videoButton.tag == 0 {
            videoButton.tag = 1
            avatarView.isHidden = true
            videoButton.setImage(IconConstants.videoIcon, for: .normal)
            startCamera()
        } else {
            avatarView.isHidden = false
            videoButton.tag = 0
            videoButton.setImage(IconConstants.pausedVideoIcon, for: .normal)
            stopCamera()
        }
    }
    
    func stopCamera() {
        if let captureSession = captureSession {
            DispatchQueue.global().async {
                captureSession.stopRunning()
                self.captureSession = nil
                
                // Remove the videoPreviewLayer from the view
                DispatchQueue.main.async {
                    self.videoPreviewLayer?.removeFromSuperlayer()
                    self.videoPreviewLayer?.contents = nil
                    self.videoPreviewLayer = nil
                }
            }
        }
    }
    
    func startCamera() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            startCameraSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { response in
                if response {
                    self.startCameraSession()
                } else {
                    self.showAlert(message: "Camera access is required.")
                }
            }
        case .denied, .restricted:
            showAlert(message: "Camera access denied. Please enable it in settings.")
        @unknown default:
            break
        }
    }
    
    func showAlert(message: String) {
        let alertController = UIAlertController(title: "Camera Access", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    func startCameraSession() {
        if let captureSession = captureSession {
            DispatchQueue.global().async {
                captureSession.stopRunning()
                self.captureSession = nil
                
                DispatchQueue.main.async {
                    self.videoPreviewLayer?.removeFromSuperlayer()
                    self.videoPreviewLayer?.contents = nil
                    self.videoPreviewLayer = nil
                }
            }
        } else {
            captureSession = AVCaptureSession()
            let discoverySession = AVCaptureDevice.DiscoverySession(
                deviceTypes: [.builtInWideAngleCamera],
                mediaType: .video,
                position: .front
            )
            guard let videoDevice = discoverySession.devices.first else {
                print("Front camera not available.")
                return
            }
            do {
                let videoInput = try AVCaptureDeviceInput(device: videoDevice)
                if captureSession!.canAddInput(videoInput) {
                    captureSession!.addInput(videoInput)
                }
                videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
                videoPreviewLayer?.frame = self.previewView.bounds
                videoPreviewLayer?.videoGravity = .resizeAspectFill
                if let connection = videoPreviewLayer?.connection, connection.isVideoMirroringSupported {
                    connection.automaticallyAdjustsVideoMirroring = false
                    connection.isVideoMirrored = true
                }
                self.previewView.layer.insertSublayer(videoPreviewLayer!, below: self.videoLayer.layer)
                self.previewView.layoutIfNeeded()
                videoPreviewLayer?.frame = self.previewView.bounds
                DispatchQueue.global().async {
                    self.captureSession!.startRunning()
                }
            } catch {
                showAlert(message: "Error setting up camera.")
            }
        }
    }
    
    @objc func startCall() {
        if let sessionID = sessionTextFiled.text, sessionID.isEmpty {
            getRandomSessionID()
        }
        CometChatCalls.generateToken(sessionID: sessionTextFiled.text ?? "") { token in
            print("generateToken success")
            print(token as Any)
            DispatchQueue.main.async(execute: {
                let callVC = CallViewController()
                callVC.sessionId = self.sessionTextFiled.text
                callVC.modalPresentationStyle = .fullScreen
                self.present(callVC, animated: true) {
                    // Save to call history
                    HistoryViewController.saveCallLog(meetingName: "CometChat Meeting", sessionId: self.sessionTextFiled.text ?? "")
                    
                    let sessionSettings = CometChatCalls.sessionSettingsBuilder
                        .setTitle("CometChat Meeting")
                        .hideShareInviteButton(false)
                        .startVideoPaused(self.videoButton.tag == 0 ? true : false)
                        .startAudioMuted(self.audioButton.tag == 0 ? true : false)
                        .build()
                    CometChatCalls.joinSession(callToken: token ?? "", callSetting: sessionSettings, container: callVC.containerView) { success in
                        print("CometChatCalls JoinSession Success with message: \(success)")
                    } onError: { error in
                        print("CometChatCalls failed with message: " + (error?.errorDescription ?? ""))
                    }
                }
            })
        } onError: { errorr in
            print("generateToken error \(String(describing: errorr?.errorDescription))")
        }
    }
    
    func getRandomSessionID() {
        sessionTextFiled.text = randomString(length:4) + "-" + randomString(length:4) + "-" + randomString(length:4)
    }
    
    func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyz"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }

    func buildAvatar() -> UIView {
        let customButton = UIButton(type: .custom)
        customButton.translatesAutoresizingMaskIntoConstraints = false
        let widthAnchor = customButton.widthAnchor.constraint(equalToConstant: 70)
        widthAnchor.priority = .required
        widthAnchor.isActive = true
        let heightAnchor = customButton.heightAnchor.constraint(equalToConstant: 70)
        heightAnchor.priority = .required
        heightAnchor.isActive = true
        if let imageURL = URL(string: "\(CometChatCalls.getLoggedInUser()?.avatar ?? "")") {
            UIImageView.downloaded(from: imageURL) { image in
                if image == nil {
                    let image = UIImageView(frame: .init(origin: .zero, size: CGSize(width: 70, height: 70)))
                    customButton.setImage(AvatarUtils.setImageSnap(text: CometChatCalls.getLoggedInUser()?.name ?? "", color: CometChatTheme.primaryColor, textAttributes: [.font: CometChatTypography.Caption1.medium, .foregroundColor: CometChatTheme.white], view: image), for: .normal)
                } else {
                    customButton.setImage(image, for: .normal)
                    customButton.imageView?.contentMode = .scaleAspectFill
                }
            }
        } else {
            let image = UIImageView(frame: .init(origin: .zero, size: CGSize(width: 70, height: 70)))
            customButton.setImage(AvatarUtils.setImageSnap(text: CometChatCalls.getLoggedInUser()?.name ?? "", color: CometChatTheme.primaryColor, textAttributes: [.font: CometChatTypography.Caption1.medium, .foregroundColor: CometChatTheme.white], view: image), for: .normal)
        }
        customButton.imageView?.layer.cornerRadius = 35
        customButton.imageView?.clipsToBounds = true
        return customButton
    }
}

extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}
