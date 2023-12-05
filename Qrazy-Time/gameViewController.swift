import UIKit

class GameViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var level: gameLevel!
    
    var runes: [Rune] = []
    
    override func viewDidDisappear(_ animated: Bool) {
        timer?.invalidate()
    }
    
    let cellIdentifier = "cell"
    let numberOfSections = 4
    let numberOfItemsInEachSection = 4
    
    var currentRune: Rune! {
        didSet {
            let attributedText = NSAttributedString(string: "\(currentRune.problem.problem)", attributes: [NSAttributedString.Key.foregroundColor: UIColor(ciColor: .yellow), NSAttributedString.Key.font: UIFont(name: "AmericanTypewriter-CondensedBold", size: 30)])
            currentRuneLabel.attributedText = attributedText
        }
    }
    
    var currentRuneImage: UIImageView!
    var currentRuneLabel: UILabel!
    
    var collectionView: UICollectionView!
    
    var timer: Timer?
    
    var secondsRemaining: Double = 60
    var squareViews: [UIView] = []
    var stackView: UIStackView!
    
    //MARK: - setupTimer
    func setupTimer() {
         stackView = UIStackView()
                stackView.axis = .horizontal
                stackView.spacing = 2
                stackView.distribution = .fillEqually
                stackView.translatesAutoresizingMaskIntoConstraints = false

                for i in 0..<60 {
                    let squareView = UIView()
                    squareView.clipsToBounds = true
                    squareView.layer.cornerRadius = 5
                    squareView.tag = i
                    squareView.backgroundColor = (i < Int(secondsRemaining)) ? UIColor(ciColor: .red) : UIColor(ciColor: .clear)
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
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    //MARK: - updateTimer
    @objc func updateTimer() {
        secondsRemaining -= 1
        for i in self.squareViews {
            i.backgroundColor = (i.tag < Int(secondsRemaining)) ? UIColor(ciColor: .red) : UIColor(ciColor: .clear)
        }
        if secondsRemaining <= 0 {
            timer?.invalidate()
            collectionView.isUserInteractionEnabled = false
            DispatchQueue.main.asyncAfter(deadline: .now()+1, execute: {
                UIView.animate(withDuration: 0.5, animations: {
                    self.collectionView.alpha = 0
                    self.currentRuneImage.alpha = 0
                    self.stackView.alpha = 0
                    self.currentRuneLabel.alpha = 0
                }) { _ in
                    let womanImageView = UIImageView()
                    womanImageView.image = UIImage(named: "lose")
                    womanImageView.contentMode = .scaleAspectFit
                    womanImageView.translatesAutoresizingMaskIntoConstraints = false
                    womanImageView.alpha = 0
                    let loseImageView = UIImageView()
                    loseImageView.image = UIImage(named: "lose1")
                    loseImageView.contentMode = .scaleAspectFit
                    loseImageView.alpha = 0
                    loseImageView.translatesAutoresizingMaskIntoConstraints = false
                    self.view.addSubview(loseImageView)
                    self.view.addSubview(womanImageView)
                    
                    let restartButton = UIButton(type: .custom)
                    restartButton.setImage(UIImage(named: "btn_restart"), for: .normal)
                    restartButton.imageView?.contentMode = .scaleAspectFit
                    restartButton.alpha = 0
                    restartButton.translatesAutoresizingMaskIntoConstraints = false
                    restartButton.addAction(UIAction(handler: {_ in
                        self.restart()
                        loseImageView.removeFromSuperview()
                        womanImageView.removeFromSuperview()
                        restartButton.removeFromSuperview()
                    }), for: .touchUpInside)
                    self.view.addSubview(restartButton)
                    
                    NSLayoutConstraint.activate([
                        restartButton.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 20),
                        restartButton.rightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor, constant: -20),
                        restartButton.heightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.2),
                        restartButton.widthAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.2),
                    ])
                    NSLayoutConstraint.activate([
                        womanImageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                        womanImageView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
                        womanImageView.widthAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.widthAnchor, multiplier: 1),
                        womanImageView.heightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.heightAnchor, multiplier: 1),
                        
                        loseImageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                        loseImageView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -30),
                        loseImageView.widthAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.widthAnchor, multiplier: 1),
                        loseImageView.heightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.1),
                    ])
                    UIView.animate(withDuration: 0.5, animations: {
                        womanImageView.alpha = 1
                        loseImageView.alpha = 1
                        restartButton.alpha = 1
                    })
                }
            })
        }
    }
    
    func loadImages() {
        for i in 1...16 {
            runes.append(Rune(problem: problems.randomElement()!, id: i))
        }
        runes.shuffle()
        currentRune = runes.randomElement()
    }
    
    func restart() {
        runes = []
        squareViews = []
        secondsRemaining = 25
        setupCollectionView()
        setupTimer()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
        setupCollectionView()
        setupTimer()
    }
    
    func setupBackground() {
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
    }
    
    func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: (view.frame.width*0.8 - 12 - 1) / 4, height: (view.frame.width*0.8 - 12 - 1) / 4)
        layout.minimumInteritemSpacing = 4
        
        currentRuneImage = UIImageView()
        currentRuneImage.translatesAutoresizingMaskIntoConstraints = false
        currentRuneImage.contentMode = .scaleAspectFit
        currentRuneImage.backgroundColor = .clear
        currentRuneImage.image = UIImage(named: "current")
        view.addSubview(currentRuneImage)
        
        currentRuneLabel = UILabel()
        currentRuneLabel.translatesAutoresizingMaskIntoConstraints = false
        currentRuneLabel.textAlignment = .center
        currentRuneLabel.numberOfLines = 0
        view.addSubview(currentRuneLabel)
        
        loadImages()
        
        NSLayoutConstraint.activate([
            currentRuneImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            currentRuneImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            currentRuneImage.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            currentRuneImage.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.2),
            
            currentRuneLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            currentRuneLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            currentRuneLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            currentRuneLabel.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.2)
        ])
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isUserInteractionEnabled = true
        collectionView.isScrollEnabled = false
        collectionView.backgroundColor = UIColor(cgColor: CGColor(red: 1, green: 0, blue: 0, alpha: 0.4))
        collectionView.clipsToBounds = true
        collectionView.layer.cornerRadius = 10
        collectionView.register(CustomCollectionViewCell.self, forCellWithReuseIdentifier: cellIdentifier)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            collectionView.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            collectionView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            collectionView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return numberOfSections
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfItemsInEachSection
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! CustomCollectionViewCell
        cell.setupRune(runes[indexPath.section * 4 + indexPath.row])
        cell.backgroundColor = .clear
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! CustomCollectionViewCell
        if cell.answer == currentRune.problem.answer {
            cell.id = 0
            if level == .easy {
                cell.layer.borderWidth = 0
            }
            for i in 0...runes.count-1 {
                if runes[i].problem.answer == currentRune.problem.answer {
                    runes.remove(at: i)
                    break
                }
            }
            if level == .easy {
                UIView.animate(withDuration: 0.2, animations: {
                    cell.imageView.image = UIImage(named: "crash")
                    cell.label.text = ""
                })
            }
        } else if level == .hard {
            secondsRemaining -= 3
            for i in self.squareViews {
                i.backgroundColor = (i.tag < Int(self.secondsRemaining)) ? .cyan : .gray
            }
        }
        if !runes.isEmpty {
            currentRune = runes.randomElement()
        } else {
            timer?.invalidate()
            RewardsManager.shared.addTreasures(1)
            collectionView.isUserInteractionEnabled = false
            DispatchQueue.main.asyncAfter(deadline: .now()+1, execute: {
                UIView.animate(withDuration: 0.5, animations: {
                    self.collectionView.alpha = 0
                    self.currentRuneImage.alpha = 0
                    self.stackView.alpha = 0
                    self.currentRuneLabel.alpha = 0
                }) { _ in
                    let womanImageView = UIImageView()
                    womanImageView.image = UIImage(named: "win")
                    womanImageView.contentMode = .scaleAspectFit
                    womanImageView.translatesAutoresizingMaskIntoConstraints = false
                    womanImageView.alpha = 0
                    self.view.addSubview(womanImageView)
                    let winImageView = UIImageView()
                    winImageView.image = UIImage(named: "win1")
                    winImageView.contentMode = .scaleAspectFit
                    winImageView.alpha = 0
                    winImageView.translatesAutoresizingMaskIntoConstraints = false
                    self.view.addSubview(winImageView)
                    
                    let restartButton = UIButton(type: .custom)
                    restartButton.setImage(UIImage(named: "btn_restart"), for: .normal)
                    restartButton.imageView?.contentMode = .scaleAspectFit
                    restartButton.alpha = 0
                    restartButton.translatesAutoresizingMaskIntoConstraints = false
                    restartButton.addAction(UIAction(handler: {_ in
                        self.restart()
                        winImageView.removeFromSuperview()
                        womanImageView.removeFromSuperview()
                        restartButton.removeFromSuperview()
                    }), for: .touchUpInside)
                    self.view.addSubview(restartButton)
                    
                    NSLayoutConstraint.activate([
                        restartButton.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 20),
                        restartButton.rightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor, constant: -20),
                        restartButton.heightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.2),
                        restartButton.widthAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.2),
                    ])
                    
                    NSLayoutConstraint.activate([
                        womanImageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                        womanImageView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
                        womanImageView.widthAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.widthAnchor, multiplier: 1),
                        womanImageView.heightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.heightAnchor, multiplier: 1),
                        
                        winImageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                        winImageView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -30),
                        winImageView.widthAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.widthAnchor, multiplier: 1),
                        winImageView.heightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.1),
                    ])
                    UIView.animate(withDuration: 0.5, animations: {
                        womanImageView.alpha = 1
                        winImageView.alpha = 1
                        restartButton.alpha = 1
                    })
                }
            })
        }
        animateCellSwap()
    }
  

    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if section == 0 {
            return UIEdgeInsets(top: 0, left: 0, bottom: 2, right: 0)
        } else if section == 3 {
            return UIEdgeInsets(top: 3, left: 0, bottom: 0, right: 0)
        } else {
            return UIEdgeInsets(top: 2, left: 0, bottom: 2, right: 0)
        }
    }
    
    func animateCellSwap() {
        for i in 0...3 {
            for j in 0...3 {
                let indexPath = IndexPath(row: j, section: i)
                let randomIndexPath = IndexPath(item: Int.random(in: 0..<numberOfItemsInEachSection), section: Int.random(in: 0..<numberOfSections))
                
                UIView.animate(withDuration: 0.5) {
                    self.collectionView.performBatchUpdates({
                        self.collectionView.moveItem(at: indexPath, to: randomIndexPath)
                        self.collectionView.moveItem(at: randomIndexPath, to: indexPath)
                    }, completion: { _ in
                    })
                }
            }
        }
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    let problems: [Problem] = [
        Problem(problem: "25 + 17", answer: 42),
        Problem(problem: "9 * 6", answer: 54),
        Problem(problem: "37 - 18", answer: 19),
        Problem(problem: "8 / 2", answer: 4),
        Problem(problem: "14 + 28", answer: 42),
        Problem(problem: "5 * 9", answer: 45),
        Problem(problem: "63 - 29", answer: 34),
        Problem(problem: "12 / 3", answer: 4),
        Problem(problem: "20 + 15", answer: 35),
        Problem(problem: "6 * 7", answer: 42),
        Problem(problem: "50 - 22", answer: 28),
        Problem(problem: "18 / 2", answer: 9),
        Problem(problem: "23 + 17", answer: 40),
        Problem(problem: "4 * 11", answer: 44),
        Problem(problem: "42 - 19", answer: 23),
        Problem(problem: "9 / 3", answer: 3),
        Problem(problem: "13 + 26", answer: 39),
        Problem(problem: "7 * 8", answer: 56),
        Problem(problem: "55 - 27", answer: 28),
        Problem(problem: "21 / 3", answer: 7),
        Problem(problem: "30 + 19", answer: 49),
        Problem(problem: "8 * 5", answer: 40),
        Problem(problem: "48 - 14", answer: 34),
        Problem(problem: "15 / 5", answer: 3),
        Problem(problem: "27 + 13", answer: 40),
        Problem(problem: "6 * 9", answer: 54),
        Problem(problem: "44 - 21", answer: 23),
        Problem(problem: "16 / 4", answer: 4),
        Problem(problem: "33 + 16", answer: 49),
        Problem(problem: "10 * 7", answer: 70),
        Problem(problem: "62 - 28", answer: 34),
        Problem(problem: "24 / 4", answer: 6),
        Problem(problem: "19 + 14", answer: 33),
        Problem(problem: "5 * 8", answer: 40),
        Problem(problem: "39 - 17", answer: 22),
        Problem(problem: "14 / 2", answer: 7),
        Problem(problem: "26 + 18", answer: 44),
        Problem(problem: "9 * 4", answer: 36),
        Problem(problem: "50 - 23", answer: 27),
        Problem(problem: "20 / 4", answer: 5),
        Problem(problem: "31 + 15", answer: 46),
        Problem(problem: "7 * 6", answer: 42),
        Problem(problem: "57 - 29", answer: 28),
        Problem(problem: "12 / 4", answer: 3),
        Problem(problem: "22 + 16", answer: 38),
        Problem(problem: "4 * 10", answer: 40),
        Problem(problem: "42 - 18", answer: 24),
        Problem(problem: "10 / 2", answer: 5)
    ]
    
    
}

final class Rune {
    
    var problem: Problem

    var id: Int
    
    init(problem: Problem, id: Int) {
        self.problem = problem
        self.id = id
    }
    
}

final class Problem {
    var problem: String
    var answer: Int
    
    init(problem: String, answer: Int) {
        self.problem = problem
        self.answer = answer
    }
}

class CustomCollectionViewCell: UICollectionViewCell {
    
    var imageView: UIImageView!
    var label: UILabel!
    var id: Int!
    var answer: Int!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupRune(_ rune: Rune){
        imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        // Label
        label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 16)
        addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        imageView.image = UIImage(named: "item_1")
        id = rune.id
        answer = rune.problem.answer
        let attributedText = NSAttributedString(string: "\(rune.problem.answer)", attributes: [NSAttributedString.Key.foregroundColor: UIColor(ciColor: .yellow), NSAttributedString.Key.font: UIFont(name: "AmericanTypewriter-CondensedBold", size: 20)])
        label.attributedText = attributedText
        
    }
    
}
