import UIKit
import FirebaseCore
import GoogleSignIn
import FirebaseAuth
import CryptoKit
import CometChatCallsSDK
import CometChatUIKitSwift

class LoginWithGoogleVC: UIViewController {

    // MARK: - UI Elements

    let containerView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(white: 0.1, alpha: 1)
        v.layer.cornerRadius = 32
        v.layer.borderColor = UIColor(white: 0.2, alpha: 1).cgColor
        v.layer.borderWidth = 1
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    let logoImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "logo"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Your Name"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let nameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Enter your name"
        tf.backgroundColor = UIColor(white: 0.15, alpha: 1)
        tf.textColor = .white
        tf.layer.cornerRadius = 10
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.setLeftPaddingPoints1(12)
        return tf
    }()

    let continueButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Continue", for: .normal)
        button.backgroundColor = UIColor(red: 0.56, green: 0.47, blue: 0.98, alpha: 1)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    let orStack = UIStackView()

    let googleButton: UIButton = {
        let button = UIButton(type: .system)
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = UIColor(white: 0.07, alpha: 1)
        config.baseForegroundColor = .white
        config.title = "Google"
        config.image = UIImage(named: "google_icon")
        config.imagePadding = 12
        config.imagePlacement = .leading
        config.cornerStyle = .medium
        button.configuration = config
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    var spinner = UIActivityIndicatorView()

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        buildUI()
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    // MARK: - UI Setup

    func buildUI() {
        view.backgroundColor = UIColor.black

        
        view.addSubview(logoImageView)
        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100),
            logoImageView.widthAnchor.constraint(equalToConstant: 150),
            logoImageView.heightAnchor.constraint(equalToConstant: 60)
        ])

        // Container
        view.addSubview(containerView)
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 32),
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.widthAnchor.constraint(equalToConstant: 350),
            containerView.heightAnchor.constraint(equalToConstant: 350)
        ])

        // Name label and text field
        containerView.addSubview(nameLabel)
        containerView.addSubview(nameTextField)
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 32),
            nameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),

            nameTextField.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            nameTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            nameTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            nameTextField.heightAnchor.constraint(equalToConstant: 48)
        ])

        // Continue button
        containerView.addSubview(continueButton)
        NSLayoutConstraint.activate([
            continueButton.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 24),
            continueButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            continueButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            continueButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        continueButton.addTarget(self, action: #selector(continueAnonymously), for: .touchUpInside)

        // Or stack
        let leftLine = UIView()
        leftLine.backgroundColor = UIColor(white: 0.3, alpha: 1)
        leftLine.heightAnchor.constraint(equalToConstant: 1).isActive = true
        leftLine.translatesAutoresizingMaskIntoConstraints = false

        let orLabel = UILabel()
        orLabel.text = "   Or"
        orLabel.textColor = UIColor(white: 0.7, alpha: 1)
        orLabel.font = UIFont.systemFont(ofSize: 16)
        orLabel.translatesAutoresizingMaskIntoConstraints = false

        let rightLine = UIView()
        rightLine.backgroundColor = UIColor(white: 0.3, alpha: 1)
        rightLine.heightAnchor.constraint(equalToConstant: 1).isActive = true
        rightLine.translatesAutoresizingMaskIntoConstraints = false

        orStack.axis = .horizontal
        orStack.alignment = .center
        orStack.spacing = 8
        orStack.translatesAutoresizingMaskIntoConstraints = false
        orStack.addArrangedSubview(leftLine)
        orStack.addArrangedSubview(orLabel)
        orStack.addArrangedSubview(rightLine)
        containerView.addSubview(orStack)

        NSLayoutConstraint.activate([
            orStack.topAnchor.constraint(equalTo: continueButton.bottomAnchor, constant: 24),
            orStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            orStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),

            leftLine.widthAnchor.constraint(equalTo: orStack.widthAnchor, multiplier: 0.4),
            rightLine.widthAnchor.constraint(equalTo: orStack.widthAnchor, multiplier: 0.4)
        ])

        // Google button
        containerView.addSubview(googleButton)
        NSLayoutConstraint.activate([
            googleButton.topAnchor.constraint(equalTo: orStack.bottomAnchor, constant: 24),
            googleButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            googleButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            googleButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        googleButton.addTarget(self, action: #selector(googleLogInWithGoogle), for: .touchUpInside)
    }

    // MARK: - Spinner

    func addSpinner() {
        spinner = UIActivityIndicatorView()
        spinner.startAnimating()
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.tintColor = .white
        view.addSubview(spinner)
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    func removeSpinner() {
        spinner.removeFromSuperview()
    }

    // MARK: - Actions

    @objc func googleLogInWithGoogle() {
        print("Google button clicked")
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            print("Firebase Client ID not found.")
            return
        }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [unowned self] result, error in
            if let error = error {
                print("Google Sign-In failed with error: \(error.localizedDescription)")
                return
            }
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString,
                  let _ = user.profile?.email else {
                print("Error retrieving user, ID token, or email.")
                return
            }
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
            Auth.auth().signIn(with: credential) { authResult, error in
                self.addSpinner()
                if let error = error {
                    DispatchQueue.main.async {
                        self.removeSpinner()
                    }
                    print("Firebase sign-in failed: \(error.localizedDescription)")
                } else {
                    let newUser = CometChatCallsSDK.CallsSDKUser(uid: authResult?.user.uid ?? "", name: authResult?.user.displayName ?? "")
                    self.loginOnCometChat(with: newUser)
                }
            }
        }
    }

    @objc func continueAnonymously() {
        print("Continue button clicked")
        self.addSpinner()
        let name = nameTextField.text?.isEmpty == false ? nameTextField.text! : "Anonymous"
        print("Continuing anonymously with name: \(name)")
        Auth.auth().signInAnonymously { [weak self] authResult, error in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.removeSpinner()
            }
            if let error = error {
                print("Anonymous sign-in failed: \(error.localizedDescription)")
                return
            }
            guard let user = authResult?.user else {
                print("No user returned from anonymous sign-in.")
                return
            }
            let newUser = CometChatCallsSDK.CallsSDKUser(uid: user.uid, name: name)
            self.loginOnCometChat(with: newUser)
        }
    }

    // MARK: - CometChat Logic (unchanged)

    func loginOnCometChat(with user: CometChatCallsSDK.CallsSDKUser) {
        let uid = user.uid ?? ""
        let name = user.name ?? ""
        print("Logging in to CometChat with UID: \(uid) and Name: \(name)")
        CometChatCalls.login(UID: uid, authKey: AppConstants.AUTH_KEY) { user in
            DispatchQueue.main.async {
                self.removeSpinner()
                self.navigateAfterLogin()
            }
        } onError: { error in
            print(error.errorDescription)
            self.createCometChatUser(
                uid: uid,
                name: name,
                avatarUrl: nil
            ) { result in
                switch result {
                case .success(let user):
                    print("User created successfully: \(user.uid ?? "")")
                    print("User created successfully: \(user.name ?? "")")
                    self.loginOnCometChat(with: user)
                case .failure(let error):
                    print("Error: \(error)")
                }
            }
        }
        
        CometChatUIKit.login(uid: uid) { loginResult in
            switch loginResult {
            case .success:
                debugPrint("CometChat UI Kit login succeeded")
            case .onError(let error):
                debugPrint("CometChat UI Kit login failed with error: \(error.description)")
            @unknown default:
                break
            }
        }
    }
    
    private func navigateAfterLogin() {
        guard let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate else { return }
        
        // Check if there's a pending deep link
        if let pendingSessionId = UserDefaults.standard.string(forKey: "pendingSessionId") {
            let pendingMeetingName = UserDefaults.standard.string(forKey: "pendingMeetingName")
            
            // Set root to tab bar first
            let tabBarController = CallsAppTabBarController()
            sceneDelegate.setRootViewController(tabBarController)
            
            // Then present SettingController with deep link data
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                let settingController = SettingController()
                settingController.sessionId = pendingSessionId
                settingController.meetingName = pendingMeetingName
                
                let nav = UINavigationController(rootViewController: settingController)
                nav.modalPresentationStyle = .fullScreen
                tabBarController.present(nav, animated: true)
                
                // Clean up
                UserDefaults.standard.removeObject(forKey: "pendingSessionId")
                UserDefaults.standard.removeObject(forKey: "pendingMeetingName")
            }
        } else {
            // No deep link, just go to home
            sceneDelegate.setRootViewController(CallsAppTabBarController())
        }
    }

    func createCometChatUser(
        uid: String,
        name: String,
        avatarUrl: String?,
        completion: @escaping (Result<CometChatCallsSDK.CallsSDKUser, Error>) -> Void
    ) {
        let urlString = "https://\(AppConstants.APP_ID).api-\(AppConstants.REGION).cometchat.io/v3/users"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0)))
            return
        }

        var json: [String: Any] = [
            "uid": uid,
            "name": name
        ]
        if let avatarUrl = avatarUrl {
            json["avatar"] = avatarUrl
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "accept")
        request.setValue("application/json", forHTTPHeaderField: "content-type")
        request.setValue(AppConstants.API_KEY, forHTTPHeaderField: "apikey")
        request.httpBody = try? JSONSerialization.data(withJSONObject: json)

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data {
                print("User created: \(String(data: data, encoding: .utf8) ?? "")")
                if let user = self.userFromData(data) {
                    completion(.success(user))
                } else {
                    completion(.failure(NSError(domain: "DecodingError", code: 0)))
                }
            }
        }
        task.resume()
    }

    func userFromData(_ data: Data) -> CometChatCallsSDK.CallsSDKUser? {
        struct APIUser: Codable {
            let uid: String?
            let name: String?
            let avatar: String?
        }
        struct APIResponse: Codable {
            let data: APIUser
        }
        let decoder = JSONDecoder()
        do {
            let response = try decoder.decode(APIResponse.self, from: data)
            let apiUser = response.data
            let user = CometChatCallsSDK.CallsSDKUser(uid: apiUser.uid ?? "", name: apiUser.name ?? "")
            user.avatar = apiUser.avatar
            return user
        } catch {
            print("Failed to decode User: \(error)")
            return nil
        }
    }

    func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        return hashedData.compactMap { String(format: "%02x", $0) }.joined()
    }
}

// Helper for text field padding
extension UITextField {
    func setLeftPaddingPoints1(_ amount: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
}
