import SwiftUI
import FortuneWheel

struct FortuneSwiftUI: View {
    
    var delegate: BonusViewController
    
    var lastIndex: Int
    
     var players = ["10", "0", "1", "5", "0", "5", "0", "1", "0"]
    
    let colours: [Color] = [
        Color("color1"),
        Color("color2"),
        Color("color3"),
        Color("color4"),
        Color("color5"),
        Color("color6"),
    ]
    
    @State private var isInteractionDisabled = false
    @State private var isShowingTemporaryView = true
    @State private var isShowingAlert = false
    @State private var alertMessage = "You have got no wins"
        
 
    var body: some View {
        ZStack {
            Image("background")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
            
            if isShowingTemporaryView {
                TemporaryView()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            isShowingTemporaryView = false
                        }
                    }
            } else {
                
                VStack {
                    HStack {
                        Spacer(minLength: 10)
                        Button(action: {
                            delegate.dismiss(animated: true)
                        }) {
                            Image("btn_back")
                                .resizable()
                                .frame(width: 50, height: 50)
                        }
                        Spacer()
                    }
                    HStack {
                        Spacer().frame(width: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/)
                        Image("qrazy-wheel")
                            .resizable()
                            .scaledToFit()
                        Spacer().frame(width: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/)
                    }
                    ZStack {
                        Image("btn_back")
                            .resizable()
                            .frame(width: 350, height: 350)
                        FortuneWheel(
                            titles: players,
                            size: 320,
                            onSpinEnd: onSpinEnd,
                            colors: colours,
                            pointerColor: Color(cgColor: CGColor(red: 255/255, green: 217/255, blue: 61/255, alpha: 1)),
                            strokeColor: Color(cgColor: CGColor(red: 123/255, green: 22/255, blue: 14/255, alpha: 1)),
                            getWheelItemIndex: getWheelItemIndex
                        ).font(.custom("GillSans-UltraBold", size: 26)).tint(.black)
                            .disabled(isInteractionDisabled)
                    }
                    HStack {
                        Image("swipe")
                            .resizable()
                            .scaledToFit()
                    }
                    Spacer()
                }
            }
        }.alert(isPresented: $isShowingAlert) {
            Alert(
                title: Text("Result"),
                message: Text(alertMessage),
                dismissButton: .default(
                    Text("OK"),
                    action: {
                        delegate.dismiss(animated: true)
                    }
                )
            )
        }
    }

struct TemporaryView: View {
    var body: some View {
        Image("help")
            .resizable()
            .scaledToFill()
            .edgesIgnoringSafeArea(.all)
    }
}

        private func onSpinEnd(index: Int) {
            isInteractionDisabled = true
            let manager = RewardsManager.shared
            switch lastIndex {
            case 0:
                manager.addTreasures(10)
                alertMessage = "You have got 10 jokers"
            case 2:
                manager.addTreasures(1)
                alertMessage = "You have got 1 joker"
            case 3:
                manager.addTreasures(5)
                alertMessage = "You have got 5 jokers"
            case 5:
                manager.addTreasures(5)
                alertMessage = "You have got 5 jokers"
            case 7:
                manager.addTreasures(1)
                alertMessage = "You have got 1 joker"
            default:
                break
            }
            isShowingAlert = true
        }

        private func getWheelItemIndex() -> Int {
            return lastIndex
        }
}
import UIKit

class BonusViewController: UIViewController {
    
    override func viewDidLoad() {
            super.viewDidLoad()
            
            showGame()
            
            func showGame() {
                // Створення SwiftUI View
                let mainView = FortuneSwiftUI(delegate: self, lastIndex: Int.random(in: 0...5))
                // Створення UIHostingController для вашого SwiftUI View
                let hostingController = UIHostingController(rootView: mainView)
                
                // Додавання UIHostingController до вашого UIKit інтерфейсу
                addChild(hostingController)
                view.addSubview(hostingController.view)
                hostingController.didMove(toParent: self)
                
                // Налаштування розміщення і розміру SwiftUI View
                hostingController.view.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
                    hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                    hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                    hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
                ])
            }
        }

}
