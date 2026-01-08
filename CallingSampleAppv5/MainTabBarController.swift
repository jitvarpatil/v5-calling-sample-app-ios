import UIKit
import CometChatCallsSDK
import FirebaseAuth


class MeetingViewController: UIViewController {

    private let avatarImageView = UIImageView()
    private let profileImage = UIImageView()
    private let menuView = UIView()
    private let nameLabel = UILabel()
    private let logoutIcon = UIImageView()
    private let logoutLabel = UILabel()
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
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboardAndMenu))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboardAndMenu() {
        view.endEditing(true)
        if isMenuVisible {
            isMenuVisible = false
            menuView.isHidden = true
        }
    }

    private func setupAvatar() {
        avatarImageView.image = UIImage(systemName: "person.circle.fill")
        avatarImageView.tintColor = .white
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.isUserInteractionEnabled = true
        avatarImageView.layer.cornerRadius = 22
        avatarImageView.layer.borderWidth = 2
        avatarImageView.layer.borderColor = UIColor(white: 0.3, alpha: 1).cgColor
        avatarImageView.clipsToBounds = true
        view.addSubview(avatarImageView)

        let tap = UITapGestureRecognizer(target: self, action: #selector(toggleMenu))
        avatarImageView.addGestureRecognizer(tap)

        NSLayoutConstraint.activate([
            avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            avatarImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            avatarImageView.widthAnchor.constraint(equalToConstant: 44),
            avatarImageView.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        loadUserAvatar(into: avatarImageView, size: 44)
    }
    
    private func loadUserAvatar(into imageView: UIImageView, size: CGFloat) {
        if let avatarURL = CometChatCalls.getLoggedInUser()?.avatar,
           !avatarURL.isEmpty,
           let url = URL(string: avatarURL) {
            URLSession.shared.dataTask(with: url) { data, _, _ in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        imageView.image = image
                    }
                }
            }.resume()
        } else {
            let tempView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: size, height: size)))
            imageView.image = AvatarUtils.setImageSnap(
                text: CometChatCalls.getLoggedInUser()?.name ?? "",
                color: CometChatTheme.primaryColor,
                textAttributes: [.font: CometChatTypography.Caption1.regular, .foregroundColor: CometChatTheme.white],
                view: tempView
            )
        }
    }
    
    @objc func logoutTapped() {
        CometChatCalls.logout { _ in
            print("CometChat logout successful")
        } onError: { error in
            print("CometChat logout error: \(error.errorDescription)")
        }
        do {
            try Auth.auth().signOut()
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
        menuView.layer.cornerRadius = 12
        menuView.layer.borderWidth = 1
        menuView.layer.borderColor = UIColor(white: 0.25, alpha: 1).cgColor
        menuView.translatesAutoresizingMaskIntoConstraints = false
        menuView.isHidden = true
        view.addSubview(menuView)

        profileImage.contentMode = .scaleAspectFill
        profileImage.layer.cornerRadius = 18
        profileImage.clipsToBounds = true
        profileImage.translatesAutoresizingMaskIntoConstraints = false
        loadUserAvatar(into: profileImage, size: 36)

        nameLabel.text = CometChatCalls.getLoggedInUser()?.name ?? "User"
        nameLabel.textColor = .white
        nameLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        logoutIcon.image = UIImage(systemName: "rectangle.portrait.and.arrow.right")
        logoutIcon.tintColor = .white
        logoutIcon.contentMode = .scaleAspectFit
        logoutIcon.translatesAutoresizingMaskIntoConstraints = false
        
        logoutLabel.text = "Logout"
        logoutLabel.textColor = .white
        logoutLabel.font = UIFont.systemFont(ofSize: 16)
        logoutLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let logoutTap = UITapGestureRecognizer(target: self, action: #selector(logoutTapped))
        
        let logoutRow = UIView()
        logoutRow.translatesAutoresizingMaskIntoConstraints = false
        logoutRow.isUserInteractionEnabled = true
        logoutRow.addGestureRecognizer(logoutTap)
        logoutRow.addSubview(logoutIcon)
        logoutRow.addSubview(logoutLabel)

        versionLabel.text = "V.5.0.1"
        versionLabel.textColor = UIColor(white: 0.5, alpha: 1)
        versionLabel.font = UIFont.systemFont(ofSize: 14)
        versionLabel.translatesAutoresizingMaskIntoConstraints = false

        menuView.addSubview(profileImage)
        menuView.addSubview(nameLabel)
        menuView.addSubview(logoutRow)
        menuView.addSubview(versionLabel)

        NSLayoutConstraint.activate([
            menuView.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 8),
            menuView.trailingAnchor.constraint(equalTo: avatarImageView.trailingAnchor),
            menuView.widthAnchor.constraint(equalToConstant: 180),

            profileImage.topAnchor.constraint(equalTo: menuView.topAnchor, constant: 16),
            profileImage.leadingAnchor.constraint(equalTo: menuView.leadingAnchor, constant: 16),
            profileImage.widthAnchor.constraint(equalToConstant: 36),
            profileImage.heightAnchor.constraint(equalToConstant: 36),

            nameLabel.centerYAnchor.constraint(equalTo: profileImage.centerYAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: profileImage.trailingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: menuView.trailingAnchor, constant: -16),

            logoutRow.topAnchor.constraint(equalTo: profileImage.bottomAnchor, constant: 16),
            logoutRow.leadingAnchor.constraint(equalTo: menuView.leadingAnchor, constant: 16),
            logoutRow.trailingAnchor.constraint(equalTo: menuView.trailingAnchor, constant: -16),
            logoutRow.heightAnchor.constraint(equalToConstant: 24),
            
            logoutIcon.leadingAnchor.constraint(equalTo: logoutRow.leadingAnchor),
            logoutIcon.centerYAnchor.constraint(equalTo: logoutRow.centerYAnchor),
            logoutIcon.widthAnchor.constraint(equalToConstant: 20),
            logoutIcon.heightAnchor.constraint(equalToConstant: 20),
            
            logoutLabel.leadingAnchor.constraint(equalTo: logoutIcon.trailingAnchor, constant: 12),
            logoutLabel.centerYAnchor.constraint(equalTo: logoutRow.centerYAnchor),

            versionLabel.topAnchor.constraint(equalTo: logoutRow.bottomAnchor, constant: 16),
            versionLabel.leadingAnchor.constraint(equalTo: menuView.leadingAnchor, constant: 16),
            versionLabel.bottomAnchor.constraint(equalTo: menuView.bottomAnchor, constant: -16)
        ])
    }

    @objc private func toggleMenu() {
        isMenuVisible.toggle()
        menuView.isHidden = !isMenuVisible
    }

    private func setupLogo() {
        logoImageView.image = UIImage(named: "logo")
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logoImageView)

        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 80),
            logoImageView.heightAnchor.constraint(equalToConstant: 40),
            logoImageView.widthAnchor.constraint(equalToConstant: 180)
        ])
    }

    private func setupMeetingForm() {
        let container = UIView()
        container.backgroundColor = UIColor(white: 0.08, alpha: 1)
        container.layer.cornerRadius = 16
        container.layer.borderWidth = 1
        container.layer.borderColor = UIColor(white: 0.2, alpha: 1).cgColor
        container.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(container)

        let sessionLabel = UILabel()
        sessionLabel.text = "Enter Session Id"
        sessionLabel.textColor = .white
        sessionLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        sessionLabel.translatesAutoresizingMaskIntoConstraints = false

        sessionTextField.attributedPlaceholder = NSAttributedString(
            string: "Session ID",
            attributes: [.foregroundColor: UIColor(white: 0.4, alpha: 1)]
        )
        sessionTextField.backgroundColor = .clear
        sessionTextField.textColor = .white
        sessionTextField.layer.cornerRadius = 8
        sessionTextField.layer.borderWidth = 1
        sessionTextField.layer.borderColor = UIColor(white: 0.3, alpha: 1).cgColor
        sessionTextField.font = UIFont.systemFont(ofSize: 16)
        sessionTextField.translatesAutoresizingMaskIntoConstraints = false
        sessionTextField.setLeftPaddingPoints(12)

        joinButton.setTitle("Join Meeting", for: .normal)
        joinButton.setTitleColor(.white, for: .normal)
        joinButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        joinButton.backgroundColor = .clear
        joinButton.layer.cornerRadius = 8
        joinButton.layer.borderWidth = 1
        joinButton.layer.borderColor = UIColor(white: 0.3, alpha: 1).cgColor
        joinButton.translatesAutoresizingMaskIntoConstraints = false
        joinButton.addTarget(self, action: #selector(joinMeetingTapped), for: .touchUpInside)

        orLabel.text = "Or"
        orLabel.textColor = UIColor(white: 0.5, alpha: 1)
        orLabel.font = UIFont.systemFont(ofSize: 14)
        orLabel.textAlignment = .center
        orLabel.translatesAutoresizingMaskIntoConstraints = false

        instantMeetingButton.setTitle("Start Instant Meeting", for: .normal)
        instantMeetingButton.setTitleColor(.white, for: .normal)
        instantMeetingButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        instantMeetingButton.backgroundColor = UIColor(red: 0.56, green: 0.47, blue: 0.98, alpha: 1)
        instantMeetingButton.layer.cornerRadius = 8
        instantMeetingButton.translatesAutoresizingMaskIntoConstraints = false
        instantMeetingButton.addTarget(self, action: #selector(startInstantMeeting), for: .touchUpInside)

        container.addSubview(sessionLabel)
        container.addSubview(sessionTextField)
        container.addSubview(joinButton)
        container.addSubview(orLabel)
        container.addSubview(instantMeetingButton)

        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 40),
            container.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            container.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            sessionLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 24),
            sessionLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),

            sessionTextField.topAnchor.constraint(equalTo: sessionLabel.bottomAnchor, constant: 12),
            sessionTextField.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            sessionTextField.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
            sessionTextField.heightAnchor.constraint(equalToConstant: 48),

            joinButton.topAnchor.constraint(equalTo: sessionTextField.bottomAnchor, constant: 20),
            joinButton.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            joinButton.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
            joinButton.heightAnchor.constraint(equalToConstant: 48),

            orLabel.topAnchor.constraint(equalTo: joinButton.bottomAnchor, constant: 16),
            orLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),

            instantMeetingButton.topAnchor.constraint(equalTo: orLabel.bottomAnchor, constant: 16),
            instantMeetingButton.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            instantMeetingButton.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
            instantMeetingButton.heightAnchor.constraint(equalToConstant: 48),
            instantMeetingButton.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -24)
        ])
    }
    
    @objc func startInstantMeeting() {
        let settingVC = SettingController()
        settingVC.sessionId = randomString(length: 4) + "-" + randomString(length: 4) + "-" + randomString(length: 4)
        let nav = UINavigationController(rootViewController: settingVC)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }
    
    @objc func joinMeetingTapped() {
        guard let sessionId = sessionTextField.text, !sessionId.isEmpty else { return }
        let settingVC = SettingController()
        settingVC.sessionId = sessionId
        let nav = UINavigationController(rootViewController: settingVC)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }
    
    func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyz"
        return String((0..<length).map { _ in letters.randomElement()! })
    }
}

// MARK: - Call Log Model
struct CallLog {
    let id: String
    let meetingName: String
    let sessionId: String
    let date: Date
}


// MARK: - Call Log Cell
class CallLogCell: UITableViewCell {
    static let identifier = "CallLogCell"
    
    var onJoinTapped: (() -> Void)?
    
    private let iconContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.56, green: 0.47, blue: 0.98, alpha: 1)
        view.layer.cornerRadius = 24
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.2.fill")
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let meetingNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let joinButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Join", for: .normal)
        button.setTitleColor(UIColor(red: 0.56, green: 0.47, blue: 0.98, alpha: 1), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(red: 0.56, green: 0.47, blue: 0.98, alpha: 1).cgColor
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(iconContainer)
        iconContainer.addSubview(iconImageView)
        contentView.addSubview(meetingNameLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(joinButton)
        
        joinButton.addTarget(self, action: #selector(joinTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            iconContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            iconContainer.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconContainer.widthAnchor.constraint(equalToConstant: 48),
            iconContainer.heightAnchor.constraint(equalToConstant: 48),
            
            iconImageView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),
            
            meetingNameLabel.topAnchor.constraint(equalTo: iconContainer.topAnchor, constant: 4),
            meetingNameLabel.leadingAnchor.constraint(equalTo: iconContainer.trailingAnchor, constant: 12),
            meetingNameLabel.trailingAnchor.constraint(lessThanOrEqualTo: joinButton.leadingAnchor, constant: -12),
            
            dateLabel.topAnchor.constraint(equalTo: meetingNameLabel.bottomAnchor, constant: 4),
            dateLabel.leadingAnchor.constraint(equalTo: meetingNameLabel.leadingAnchor),
            
            joinButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            joinButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            joinButton.widthAnchor.constraint(equalToConstant: 60),
            joinButton.heightAnchor.constraint(equalToConstant: 32)
        ])
    }
    
    @objc private func joinTapped() {
        onJoinTapped?()
    }
    
    func configure(with callLog: CallLog) {
        meetingNameLabel.text = callLog.meetingName
        
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM, h:mm a"
        dateLabel.text = formatter.string(from: callLog.date)
    }
}

// MARK: - History View Controller
class HistoryViewController: UIViewController {
    
    private var callLogs: [CallLog] = []
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "History"
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 28)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = .clear
        table.separatorStyle = .none
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    private let emptyStateView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupUI()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadCallLogs()
    }
    
    private func setupUI() {
        view.addSubview(titleLabel)
        view.addSubview(tableView)
        view.addSubview(emptyStateView)
        
        let emptyIcon = UIImageView(image: UIImage(systemName: "clock.badge.checkmark"))
        emptyIcon.tintColor = UIColor(red: 0.56, green: 0.47, blue: 0.98, alpha: 1)
        emptyIcon.contentMode = .scaleAspectFit
        emptyIcon.translatesAutoresizingMaskIntoConstraints = false
        
        let emptyLabel = UILabel()
        emptyLabel.text = "No call history yet"
        emptyLabel.textColor = .lightGray
        emptyLabel.font = UIFont.systemFont(ofSize: 16)
        emptyLabel.textAlignment = .center
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        
        emptyStateView.addSubview(emptyIcon)
        emptyStateView.addSubview(emptyLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            emptyIcon.topAnchor.constraint(equalTo: emptyStateView.topAnchor),
            emptyIcon.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            emptyIcon.widthAnchor.constraint(equalToConstant: 60),
            emptyIcon.heightAnchor.constraint(equalToConstant: 60),
            
            emptyLabel.topAnchor.constraint(equalTo: emptyIcon.bottomAnchor, constant: 16),
            emptyLabel.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            emptyLabel.bottomAnchor.constraint(equalTo: emptyStateView.bottomAnchor)
        ])
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CallLogCell.self, forCellReuseIdentifier: CallLogCell.identifier)
        tableView.rowHeight = 72
    }
    
    private func loadCallLogs() {
        if let data = UserDefaults.standard.data(forKey: "callLogs"),
           let logs = try? JSONDecoder().decode([[String: String]].self, from: data) {
            callLogs = logs.compactMap { dict in
                guard let id = dict["id"],
                      let name = dict["meetingName"],
                      let sessionId = dict["sessionId"],
                      let dateString = dict["date"],
                      let timestamp = Double(dateString) else { return nil }
                return CallLog(id: id, meetingName: name, sessionId: sessionId, date: Date(timeIntervalSince1970: timestamp))
            }.sorted { $0.date > $1.date }
        }
        
        tableView.reloadData()
        emptyStateView.isHidden = !callLogs.isEmpty
        tableView.isHidden = callLogs.isEmpty
    }
    
    static func saveCallLog(meetingName: String, sessionId: String) {
        var logs: [[String: String]] = []
        
        if let data = UserDefaults.standard.data(forKey: "callLogs"),
           let existing = try? JSONDecoder().decode([[String: String]].self, from: data) {
            logs = existing
        }
        
        if logs.contains(where: { $0["sessionId"] == sessionId }) {
            return
        }
        
        let newLog: [String: String] = [
            "id": UUID().uuidString,
            "meetingName": meetingName.isEmpty ? "Meeting" : meetingName,
            "sessionId": sessionId,
            "date": String(Date().timeIntervalSince1970)
        ]
        
        logs.insert(newLog, at: 0)
        
        if logs.count > 50 {
            logs = Array(logs.prefix(50))
        }
        
        if let data = try? JSONEncoder().encode(logs) {
            UserDefaults.standard.set(data, forKey: "callLogs")
        }
    }
}

extension HistoryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return callLogs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CallLogCell.identifier, for: indexPath) as? CallLogCell else {
            return UITableViewCell()
        }
        
        let log = callLogs[indexPath.row]
        cell.configure(with: log)
        cell.onJoinTapped = { [weak self] in
            self?.joinMeeting(log)
        }
        
        return cell
    }
    
    private func joinMeeting(_ log: CallLog) {
        let settingVC = SettingController()
        settingVC.sessionId = log.sessionId
        settingVC.meetingName = log.meetingName
        let nav = UINavigationController(rootViewController: settingVC)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }
}

class CallsAppTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let meetingVC = MeetingViewController()
        meetingVC.tabBarItem = UITabBarItem(
            title: "Meeting",
            image: UIImage(systemName: "rectangle.badge.plus"),
            selectedImage: UIImage(systemName: "rectangle.badge.plus.fill")
        )
        
        let historyVC = HistoryViewController()
        historyVC.tabBarItem = UITabBarItem(
            title: "History",
            image: UIImage(systemName: "clock.arrow.circlepath"),
            selectedImage: UIImage(systemName: "clock.arrow.circlepath")
        )
        
        viewControllers = [meetingVC, historyVC]
        tabBar.barTintColor = .black
        tabBar.backgroundColor = .black
        tabBar.tintColor = UIColor(red: 0.56, green: 0.47, blue: 0.98, alpha: 1)
        tabBar.unselectedItemTintColor = .lightGray
    }
}
