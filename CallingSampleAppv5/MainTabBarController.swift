import UIKit
import CometChatCallsSDK
import FirebaseAuth


class MeetingViewController: UIViewController {

    private let avatarImageView = UIImageView()
    private let profileImage =  UIImageView()
    private let menuView = UIView()
    private let nameLabel = UILabel()
    private let logoutButton = UIButton(type: .system)
    private let versionLabel = UILabel()
    private let sessionTextField = UITextField()
    private let joinButton = UIButton(type: .system)
    private let instantMeetingButton = UIButton(type: .system)
    private let orLabel = UILabel()
    private let logoImageView = UIImageView()

    private var isMenuVisible = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black

        setupAvatar()
        setupMenu()
        setupLogo()
        setupMeetingForm()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    private func setupAvatar() {
        avatarImageView.image =  UIImage(systemName: "person.circle.fill") // Replace with your asset
        avatarImageView.tintColor = .white
        avatarImageView.clipsToBounds = true
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.isUserInteractionEnabled = true
        avatarImageView.layer.cornerRadius = 20 // Half of width/height (40/2)
        avatarImageView.clipsToBounds = true
        view.addSubview(avatarImageView)

        let tap = UITapGestureRecognizer(target: self, action: #selector(toggleMenu))
        avatarImageView.addGestureRecognizer(tap)

        NSLayoutConstraint.activate([
            avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            avatarImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            avatarImageView.widthAnchor.constraint(equalToConstant: 40),
            avatarImageView.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        // Fetch CometChat logged-in user and set avatar
        if let imageURL = URL(string: "\(CometChatCalls.getLoggedInUser()?.avatar ?? "")") {
            URLSession.shared.dataTask(with: imageURL) { data, _, _ in
                        if let data = data, let image = UIImage(data: data) {
                            DispatchQueue.main.async {
                                self.avatarImageView.image = image
                            }
                        }
                    }.resume()
        } else {
            let image = UIImageView(frame: .init(origin: .zero, size: CGSize(width: 40, height: 40)))
            avatarImageView.image = AvatarUtils.setImageSnap(text: CometChatCalls.getLoggedInUser()?.name ?? "", color: CometChatTheme.primaryColor, textAttributes: [.font: CometChatTypography.Caption1.regular, .foregroundColor: CometChatTheme.white], view: image)
        }
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

    private func setupMenu() {
        menuView.backgroundColor = UIColor(white: 0.12, alpha: 1)
        menuView.layer.cornerRadius = 16
        menuView.layer.borderWidth = 1
        menuView.layer.borderColor = UIColor(white: 0.2, alpha: 1).cgColor
        menuView.translatesAutoresizingMaskIntoConstraints = false
        menuView.isHidden = true
        view.addSubview(menuView)

        profileImage.image =  UIImage(systemName: "person.circle.fill")
        profileImage.layer.cornerRadius = 20
        profileImage.clipsToBounds = true
        profileImage.translatesAutoresizingMaskIntoConstraints = false
        
        if let imageURL = URL(string: "\(CometChatCalls.getLoggedInUser()?.avatar ?? "")") {
            URLSession.shared.dataTask(with: imageURL) { data, _, _ in
                        if let data = data, let image = UIImage(data: data) {
                            DispatchQueue.main.async {
                                self.profileImage.image = image
                            }
                        }
                    }.resume()
        } else {
            let image = UIImageView(frame: .init(origin: .zero, size: CGSize(width: 40, height: 40)))
            profileImage.image = AvatarUtils.setImageSnap(text: CometChatCalls.getLoggedInUser()?.name ?? "", color: CometChatTheme.primaryColor, textAttributes: [.font: CometChatTypography.Caption1.regular, .foregroundColor: CometChatTheme.white], view: image)
        }
        

        nameLabel.text = CometChatCalls.getLoggedInUser()?.name ?? "User"
        nameLabel.textColor = .white
        nameLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let iconContainer = UIView()
        iconContainer.backgroundColor = CometChatTheme.primaryColor
        iconContainer.layer.cornerRadius = 20 // half of width/height for a circle
        iconContainer.translatesAutoresizingMaskIntoConstraints = false

        let icon = UIImageView(image: UIImage(systemName: "arrow.right.square"))
        icon.tintColor = .white
        icon.translatesAutoresizingMaskIntoConstraints = false
        iconContainer.addSubview(icon)

        logoutButton.setTitle("Logout", for: .normal)
        logoutButton.setTitleColor(.white, for: .normal)
        logoutButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        logoutButton.backgroundColor = .clear
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        logoutButton.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)

        versionLabel.text = "V.5.0.1"
        versionLabel.textColor = .lightGray
        versionLabel.font = UIFont.systemFont(ofSize: 16)
        versionLabel.translatesAutoresizingMaskIntoConstraints = false
        versionLabel.isHidden = true // Initially hidden

        menuView.addSubview(profileImage)
        menuView.addSubview(nameLabel)
        menuView.addSubview(iconContainer)
        menuView.addSubview(logoutButton)
        menuView.addSubview(versionLabel)

        NSLayoutConstraint.activate([
            menuView.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 8),
            menuView.trailingAnchor.constraint(equalTo: avatarImageView.trailingAnchor),
            menuView.widthAnchor.constraint(equalToConstant: 220),
            menuView.heightAnchor.constraint(equalToConstant: 120),

            profileImage.topAnchor.constraint(equalTo: menuView.topAnchor, constant: 12),
            profileImage.leadingAnchor.constraint(equalTo: menuView.leadingAnchor, constant: 12),
            profileImage.widthAnchor.constraint(equalToConstant: 40),
            profileImage.heightAnchor.constraint(equalToConstant: 40),

            nameLabel.centerYAnchor.constraint(equalTo: profileImage.centerYAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: profileImage.trailingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: menuView.trailingAnchor, constant: -12),

            iconContainer.topAnchor.constraint(equalTo: profileImage.bottomAnchor, constant: 12),
            iconContainer.leadingAnchor.constraint(equalTo: menuView.leadingAnchor, constant: 12),
            iconContainer.widthAnchor.constraint(equalToConstant: 40),
            iconContainer.heightAnchor.constraint(equalToConstant: 40),
            
            icon.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            icon.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: 18),
            icon.heightAnchor.constraint(equalToConstant: 18),

            logoutButton.centerYAnchor.constraint(equalTo: icon.centerYAnchor),
            logoutButton.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 20),

            versionLabel.bottomAnchor.constraint(equalTo: menuView.bottomAnchor, constant: -8),
            versionLabel.leadingAnchor.constraint(equalTo: menuView.leadingAnchor, constant: 16)
        ])
    }

    @objc private func toggleMenu() {
        isMenuVisible.toggle()
        menuView.isHidden = !isMenuVisible
    }

    private func setupLogo() {
        logoImageView.image = UIImage(named: "logo") // Replace with your asset
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logoImageView)

        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 180),
            logoImageView.heightAnchor.constraint(equalToConstant: 48)
        ])
    }

    private func setupMeetingForm() {
        let container = UIView()
        container.backgroundColor = UIColor(white: 0.12, alpha: 1)
        container.layer.cornerRadius = 24
        container.layer.borderWidth = 1
        container.layer.borderColor = UIColor(white: 0.2, alpha: 1).cgColor
        container.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(container)

        let sessionLabel = UILabel()
        sessionLabel.text = "Enter Session Id"
        sessionLabel.textColor = .white
        sessionLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        sessionLabel.translatesAutoresizingMaskIntoConstraints = false

        sessionTextField.placeholder = "Session ID"
        sessionTextField.backgroundColor = UIColor(white: 0.18, alpha: 1)
        sessionTextField.textColor = .white
        sessionTextField.layer.cornerRadius = 8
        sessionTextField.layer.borderWidth = 1
        sessionTextField.layer.borderColor = UIColor(white: 0.3, alpha: 1).cgColor
        sessionTextField.font = UIFont.systemFont(ofSize: 18)
        sessionTextField.translatesAutoresizingMaskIntoConstraints = false
        sessionTextField.setLeftPaddingPoints(12)

        joinButton.setTitle("Join Meeting", for: .normal)
        joinButton.setTitleColor(.white, for: .normal)
        joinButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        joinButton.backgroundColor = UIColor(white: 0.18, alpha: 1)
        joinButton.layer.cornerRadius = 8
        joinButton.translatesAutoresizingMaskIntoConstraints = false
        joinButton.addTarget(self, action: #selector(joinMeetingTapped), for: .touchUpInside)

        orLabel.text = "Or"
        orLabel.textColor = .lightGray
        orLabel.textAlignment = .center
        orLabel.translatesAutoresizingMaskIntoConstraints = false

        instantMeetingButton.setTitle("Start Instant Meeting", for: .normal)
        instantMeetingButton.setTitleColor(.white, for: .normal)
        instantMeetingButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        instantMeetingButton.backgroundColor = UIColor(red: 0.56, green: 0.47, blue: 0.98, alpha: 1)
        instantMeetingButton.layer.cornerRadius = 12
        instantMeetingButton.translatesAutoresizingMaskIntoConstraints = false
        instantMeetingButton.addTarget(self, action: #selector(startInstantMeeting), for: .touchUpInside)

        container.addSubview(sessionLabel)
        container.addSubview(sessionTextField)
        container.addSubview(joinButton)
        container.addSubview(orLabel)
        container.addSubview(instantMeetingButton)

        NSLayoutConstraint.activate([
            container.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            container.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 32),
            container.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.92),
            container.heightAnchor.constraint(equalToConstant: 320),

            sessionLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 24),
            sessionLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),

            sessionTextField.topAnchor.constraint(equalTo: sessionLabel.bottomAnchor, constant: 8),
            sessionTextField.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            sessionTextField.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            sessionTextField.heightAnchor.constraint(equalToConstant: 48),

            joinButton.topAnchor.constraint(equalTo: sessionTextField.bottomAnchor, constant: 24),
            joinButton.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            joinButton.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            joinButton.heightAnchor.constraint(equalToConstant: 48),

            orLabel.topAnchor.constraint(equalTo: joinButton.bottomAnchor, constant: 16),
            orLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),

            instantMeetingButton.topAnchor.constraint(equalTo: orLabel.bottomAnchor, constant: 16),
            instantMeetingButton.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            instantMeetingButton.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            instantMeetingButton.heightAnchor.constraint(equalToConstant: 56)
            
        ])
    }
    
    @objc func startInstantMeeting() {
        let settingVC = SettingController()
        settingVC.sessionId = randomString(length:4) + "-" + randomString(length:4) + "-" + randomString(length:4)
        let nav = UINavigationController(rootViewController: settingVC)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: nil)
    }
    
    @objc func joinMeetingTapped() {
        guard let meetingName = sessionTextField.text, !meetingName.isEmpty else { return }
        let settingVC = SettingController()
        settingVC.sessionId = meetingName
        let nav = UINavigationController(rootViewController: settingVC)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: nil)
    }
    
    func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyz"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
}

class HistoryViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        // Add your History UI here
    }
}

class MainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let meetingVC = MeetingViewController()
        meetingVC.tabBarItem = UITabBarItem(
            title: "Meeting",
            image: UIImage(systemName: "video.badge.plus"),
            selectedImage: UIImage(systemName: "video.badge.plus")
        )
        
        let historyVC = HistoryViewController()
        historyVC.tabBarItem = UITabBarItem(
            title: "History",
            image: UIImage(systemName: "phone.badge.clock.fill"),
            selectedImage: UIImage(systemName: "phone.badge.clock.fill")
        )
        
        viewControllers = [meetingVC, historyVC]
        tabBar.barTintColor = .black
        tabBar.tintColor = UIColor(red: 0.56, green: 0.47, blue: 0.98, alpha: 1) // purple
        tabBar.unselectedItemTintColor = .lightGray
    }
}
