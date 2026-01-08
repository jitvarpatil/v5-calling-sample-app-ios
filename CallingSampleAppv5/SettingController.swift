import UIKit
import AVFoundation
import CometChatCallsSDK

class SettingController: UIViewController {

    var sessionId: String?
    var meetingName: String?

    private let containerView = UIView()
    private let logoImageView = UIImageView()
    private let meetingNameLabel = UILabel()
    private let meetingNameField = UITextField()
    private let joinButton = UIButton(type: .system)

    // Video/Audio UI
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var captureSession: AVCaptureSession?

    // Avatar image view for preview
    lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.circle.fill")
        imageView.tintColor = .white
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 35
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 70),
            imageView.heightAnchor.constraint(equalToConstant: 70)
        ])
        return imageView
    }()

    lazy var videoLayer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    lazy var videoButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(onCameraButtonTapped), for: .primaryActionTriggered)
        button.heightAnchor.constraint(equalToConstant: 40).isActive = true
        button.widthAnchor.constraint(equalToConstant: 40).isActive = true
        button.setImage(UIImage(systemName: "video.slash.fill"), for: .normal)
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
        button.setImage(UIImage(systemName: "mic.slash.fill"), for: .normal)
        button.tintColor = .white
        button.layer.cornerRadius = 20
        button.layer.masksToBounds = true
        button.backgroundColor = .gray.withAlphaComponent(0.4)
        return button
    }()
    lazy var previewView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.15, alpha: 1)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(videoLayer)
        view.addSubview(videoButton)
        view.addSubview(audioButton)
        videoLayer.addSubview(avatarImageView)
        NSLayoutConstraint.activate([
            videoLayer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            videoLayer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            videoLayer.topAnchor.constraint(equalTo: view.topAnchor),
            videoLayer.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            avatarImageView.centerXAnchor.constraint(equalTo: videoLayer.centerXAnchor),
            avatarImageView.centerYAnchor.constraint(equalTo: videoLayer.centerYAnchor),
            videoButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            videoButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),
            audioButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            audioButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20)
        ])
        view.layer.cornerRadius = 15
        view.layer.masksToBounds = true
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black
        initialisationCometChatCalls()
        setupBackButton()
        setupUI()
        setUserAvatar()
        
        if let meetingName = meetingName {
                meetingNameField.text = meetingName
                meetingNameField.isEnabled = false
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc private func keyboardWillShow(notification: Notification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            let keyboardHeight = keyboardFrame.height
            let bottomSpace = view.frame.height - (containerView.frame.origin.y + containerView.frame.height)
            let offset = keyboardHeight - bottomSpace + 20
            if offset > 0 {
                self.view.frame.origin.y = -offset
            }
        }
    }

    @objc private func keyboardWillHide(notification: Notification) {
        self.view.frame.origin.y = 0
    }

    private func setUserAvatar() {
        if let user = CometChatCalls.getLoggedInUser(), let avatarURL = user.avatar, let url = URL(string: avatarURL) {
            URLSession.shared.dataTask(with: url) { data, _, _ in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.avatarImageView.image = image
                    }
                }
            }.resume()
        } else {
            // Set default avatar with uppercase initials if user has no avatar
            let image = UIImageView(frame: .init(origin: .zero, size: CGSize(width: 40, height: 40)))
            let name = CometChatCalls.getLoggedInUser()?.name ?? ""
            self.avatarImageView.image = AvatarUtils.setImageSnap(
                text: name.uppercased(),
                color: CometChatTheme.primaryColor,
                textAttributes: [.font: CometChatTypography.Caption1.regular, .foregroundColor: CometChatTheme.white],
                view: image
            )
        }
    }

    private func setupBackButton() {
        let backButton = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backTapped)
        )
        navigationItem.leftBarButtonItem = backButton
    }

    @objc private func backTapped() {
        self.dismiss(animated: true, completion: nil)
    }

    private func setupUI() {
        // App Logo
        logoImageView.image = UIImage(named: "logo")
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logoImageView)

        // Container
        containerView.backgroundColor = UIColor(white: 0.1, alpha: 1)
        containerView.layer.cornerRadius = 24
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)

        // Add previewView above meetingNameLabel
        containerView.addSubview(previewView)

        // Meeting Name Label
        meetingNameLabel.text = "Meeting Name (Optional)"
        meetingNameLabel.font = UIFont.systemFont(ofSize: 16)
        meetingNameLabel.textColor = .white
        meetingNameLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(meetingNameLabel)

        // Meeting Name Field
        meetingNameField.placeholder = "enter meeting name"
        meetingNameField.backgroundColor = UIColor(white: 0.2, alpha: 1)
        meetingNameField.textColor = .white
        meetingNameField.layer.cornerRadius = 8
        meetingNameField.setLeftPaddingPoints(12)
        meetingNameField.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(meetingNameField)

        // Join Button
        joinButton.setTitle("Join Meeting", for: .normal)
        joinButton.backgroundColor = UIColor(red: 0.5, green: 0.4, blue: 1, alpha: 1)
        joinButton.setTitleColor(.white, for: .normal)
        joinButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        joinButton.layer.cornerRadius = 12
        joinButton.translatesAutoresizingMaskIntoConstraints = false
        joinButton.addTarget(self, action: #selector(joinMeeting), for: .touchUpInside)
        containerView.addSubview(joinButton)

        // Layout
        NSLayoutConstraint.activate([
            logoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            containerView.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 24),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),

            previewView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 24),
            previewView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            previewView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            previewView.heightAnchor.constraint(equalToConstant: 360),

            meetingNameLabel.topAnchor.constraint(equalTo: previewView.bottomAnchor, constant: 32),
            meetingNameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),

            meetingNameField.topAnchor.constraint(equalTo: meetingNameLabel.bottomAnchor, constant: 8),
            meetingNameField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            meetingNameField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            meetingNameField.heightAnchor.constraint(equalToConstant: 48),

            joinButton.topAnchor.constraint(equalTo: meetingNameField.bottomAnchor, constant: 32),
            joinButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            joinButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            joinButton.heightAnchor.constraint(equalToConstant: 56),
            joinButton.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -24)
        ])
    }
    
    func initialisationCometChatCalls() {
            let callSettings = CallAppSettingsBuilder()
                .set(appID: AppConstants.APP_ID)
                .set(region: AppConstants.REGION)
                .set(authKey: AppConstants.AUTH_KEY)
                .build()

            CometChatCalls.init(callsAppSettings: callSettings) { successMessage in
                print("CometChatCalls Init success with message: \(successMessage)")
            } onError: { error in
                print("CometChatCalls Init failed with error: \(error?.errorDescription ?? "")")
            }
    }

    // MARK: - Video/Audio Logic

    @objc func onAudioButtonTapped() {
        if audioButton.tag == 0 {
            audioButton.setImage(UIImage(systemName: "mic.fill"), for: .normal)
            audioButton.tag = 1
        } else {
            audioButton.tag = 0
            audioButton.setImage(UIImage(systemName: "mic.slash.fill"), for: .normal)
        }
    }

    @objc func onCameraButtonTapped() {
        if videoButton.tag == 0 {
            videoButton.tag = 1
            avatarImageView.isHidden = true
            videoButton.setImage(UIImage(systemName: "video.fill"), for: .normal)
            startCamera()
        } else {
            avatarImageView.isHidden = false
            videoButton.tag = 0
            videoButton.setImage(UIImage(systemName: "video.slash.fill"), for: .normal)
            stopCamera()
        }
    }

    func stopCamera() {
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
        }
    }

    func startCamera() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            startCameraSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { response in
                if response {
                    DispatchQueue.main.async { self.startCameraSession() }
                } else {
                    DispatchQueue.main.async { self.showAlert(message: "Camera access is required.") }
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
                DispatchQueue.main.async {
                    self.videoPreviewLayer?.frame = self.previewView.bounds
                    self.videoPreviewLayer?.videoGravity = .resizeAspectFill
                    if let connection = self.videoPreviewLayer?.connection, connection.isVideoMirroringSupported {
                        connection.automaticallyAdjustsVideoMirroring = false
                        connection.isVideoMirrored = true
                    }
                    self.previewView.layer.insertSublayer(self.videoPreviewLayer!, below: self.videoLayer.layer)
                    self.previewView.layoutIfNeeded()
                    self.videoPreviewLayer?.frame = self.previewView.bounds
                }
                DispatchQueue.global().async {
                    self.captureSession!.startRunning()
                }
            } catch {
                DispatchQueue.main.async { self.showAlert(message: "Error setting up camera.") }
            }
        }
    }
    
    
    @objc func joinMeeting() {
        CometChatCalls.generateToken(sessionID: sessionId ?? "") { token in
            print("generateToken success")
            print(token as Any)
            DispatchQueue.main.async {
                let callVC = CallViewController()
                callVC.sessionId = self.sessionId
                
                
                callVC.modalPresentationStyle = .fullScreen

                // Get title from meetingNameField or fallback
                let title = (self.meetingNameField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
                let callTitle = title.isEmpty ? "CometChat Meeting" : title
                callVC.meetingName = callTitle
                
                print("SettingController Setting sessionId: \(self.sessionId ?? "") and meetingName: \(self.meetingName ?? "")")
                print("Setting " + (self.videoButton.tag == 0 ? "Video is OFF" : "Video is ON"))
                print("Setting " + (self.audioButton.tag == 0 ? "Audio is OFF" : "Audio is ON"))

                self.present(callVC, animated: true) {
                    self.stopCamera()
                    
                    // Save to call history
                    HistoryViewController.saveCallLog(meetingName: callTitle, sessionId: self.sessionId ?? "")
                    
                    let sessionSettings = CometChatCalls.sessionSettingsBuilder
                        .setTitle(callTitle)
                        .hideShareInviteButton(false)
                        .startVideoPaused(self.videoButton.tag == 0)
                        .startAudioMuted(self.audioButton.tag == 0)
                        .hideChatButton(false)
                        .build()
                    CometChatCalls.joinSession(callToken: token ?? "", callSetting: sessionSettings, container: callVC.containerView) { success in
                        print("CometChatCalls JoinSession Success with message: \(success)")
                    } onError: { error in
                        print("CometChatCalls failed with message: " + (error?.errorDescription ?? ""))
                    }
                }
            }
        } onError: { error in
            print("generateToken error \(String(describing: error?.errorDescription))")
        }
    }
}
