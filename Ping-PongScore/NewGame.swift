//
//  NewGame.swift
//  Ping-PongScore
//
//  Created by 김은지 on 1/4/24.
//

import SwiftUI
import Combine
import AVFoundation

struct Background<Content: View>: View {
    private var content: Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content()
    }

    var body: some View {
        Color.white
        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        .overlay(content)
    }
}

class PlayViewModel {
    private var audioPlayer: AVAudioPlayer!
    func playPingPong() {
        let sound = Bundle.main.path(forResource: "pingpong", ofType: "mp3")
        self.audioPlayer = try! AVAudioPlayer(contentsOf: URL(fileURLWithPath: sound!))
        self.audioPlayer.play()
    }
    func playWinSound() {
        let sound = Bundle.main.path(forResource: "winSound", ofType: "mp3")
        self.audioPlayer = try! AVAudioPlayer(contentsOf: URL(fileURLWithPath: sound!))
        self.audioPlayer.play()
    }
    
    func playDueceSound() {
        let sound = Bundle.main.path(forResource: "duece", ofType: "mp3")
        self.audioPlayer = try! AVAudioPlayer(contentsOf: URL(fileURLWithPath: sound!))
        self.audioPlayer.play()
    }
    
   
}


struct StrokeText: View {
    let text: String
    let width: CGFloat
    let color: Color

    var body: some View {
        ZStack{
            ZStack{
                Text(text).offset(x:  width, y:  width)
                Text(text).offset(x: -width, y: -width)
                Text(text).offset(x: -width, y:  width)
                Text(text).offset(x:  width, y: -width)
            }
            .foregroundStyle(color)
            Text(text)
        }
    }
}

struct NewGame: View {
    
    let vm = PlayViewModel()
    
    @State private var showWarningText = false
    @State private var moveToScoreBoard = false
    @State private var keyboardHeight: CGFloat = 0
    @State private var showYellowOutline = true

    // 서비스 버튼의 위치(왼쪽 서브)
    @State private var offsetX: CGFloat = -0.2
    @State private var offsetY: CGFloat = 0.25

    // 원래 위치
    let originalX: CGFloat = -0.2
    let originalY: CGFloat = 0.25

    // 새로운 위치(오른쪽 서브)
    let newX: CGFloat = 0.21
    let newY: CGFloat = 0.25
    
    @State var playerOneName: String = ""
    @State var playerTwoName: String = ""
    @State var playerOnenameCount: Int = 0
    @State var playerTwonameCount: Int = 0
    @State var serviceRight: Bool = true
    @State private var moveToHome = false
    
    @State private var defaultLoadLastGame: Bool = false

    
    
    var body: some View {
        

        NavigationStack {
            ZStack(alignment: .top) {
                
                
                
                
                
                // 탁구대
                Rectangle()
                    .clipShape(
                        .rect(
                            topLeadingRadius: 10,
                            bottomLeadingRadius: 10,
                            bottomTrailingRadius: 10,
                            topTrailingRadius: 10
                        )
                    )
                    .edgesIgnoringSafeArea(.all)
                    .frame(width: UIScreen.main.bounds.width * 0.86)
                    .padding(.bottom, 1)
                    .padding(.top, 20)
                    .foregroundStyle(Color(red: 72/255, green: 127/255, blue: 233/255))
                
                // New Match
                StrokeText(text: "New Match", width: 1, color: Color(red: 79/255, green: 79/255, blue: 79/255))
                    .foregroundStyle(Color(red: 255/255, green: 199/255, blue: 0/255))
                    .font(.custom("DungGeunMo", size: 40))
                    .offset(y: UIScreen.main.bounds.height * 0.10)
                
                // 서브권 버튼
                Button(action: {
                    serviceRight.toggle()
                    
                    showYellowOutline.toggle()
                    if offsetX == originalX && offsetY == originalY {
                        // 서브를 오른쪽으로 옮긴다.
                        offsetX = newX
                        offsetY = newY
                    } else {
                        // 다시 제자리(왼쪽)으로 옮긴다.
                        offsetX = originalX
                        offsetY = originalY
                    }
                }, label: {
                    Image("service")
                }).offset(x: UIScreen.main.bounds.width * offsetX, y: UIScreen.main.bounds.height * offsetY)
                
                
                
                
                
                
                // 흰 사각형 (왼)
                Rectangle()
                    .clipShape(
                        .rect(
                            topLeadingRadius: 5,
                            bottomLeadingRadius: 5,
                            bottomTrailingRadius: 5,
                            topTrailingRadius: 5
                        )
                    )
                    .edgesIgnoringSafeArea(.all)
                
                    .background(
                        
                        // 검은색 외곽선
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.black, lineWidth: 1.5)
                    )
                
                    .background(
                        // 노란색 외곽선
                        showYellowOutline ? RoundedRectangle(cornerRadius: 5)
                            .stroke(Color(red: 255/255, green: 199/255, blue: 0/255), lineWidth: 4)
                            .padding(-1) : nil
                        
                    )
                
                    .frame(width: UIScreen.main.bounds.width * 0.3,
                           height: UIScreen.main.bounds.height * 0.13)
                    .offset(x: UIScreen.main.bounds.width * -0.2, y: UIScreen.main.bounds.height * 0.42)
                    .foregroundStyle(.white)
//                    .padding(.bottom, keyboardHeight) // 키보드 높이만큼 패딩 적용.
//                    .animation(.default, value: keyboardHeight)
                    .onAppear{
                        // 노티 : 키보드가 나타날 때 키보드 높이 값을 전송하여 패딩을 적용함
                        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
                            guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
                            self.keyboardHeight = keyboardFrame.height
                        }
                        // 노티 : 키보드가 숨겨질 때 키보드 높이를 0으로 전송하여 원상복귀
                        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
                            self.keyboardHeight = 0
                        }
                        
                    }
                
                // 텍스트필드
                TextField("Enter Player1 Name", text: $playerOneName){
                    UIApplication.shared.endEditing() // 입력을 마치면 키보드가 내려감
                    
                }
                .onReceive(Just(playerOneName), perform: { _ in
                    limitText()
                    playerOnenameCount = playerOneName.count
                })
                .foregroundStyle(.black)
                .bold()
                .background(Color(uiColor: .systemBackground))
                .frame(width: UIScreen.main.bounds.width * 0.23,
                       height: UIScreen.main.bounds.height * 0.13)
                .offset(x: UIScreen.main.bounds.width * -0.21, y: UIScreen.main.bounds.height * 0.42)
                
                // 글자 수 표시
                Label{
                    Text("\(playerOnenameCount)/8")
                        .foregroundStyle(Color.white)
                } icon: {
                    
                }
                .frame(width: UIScreen.main.bounds.width * 0.23,
                       height: UIScreen.main.bounds.height * 0.13)
                .offset(x: UIScreen.main.bounds.width * -0.07, y: UIScreen.main.bounds.height * 0.52)
                
                
                // 체인지 버튼
                Button(action: {
                    // name 위치 바꾸기.
                    (playerOneName, playerTwoName) = (playerTwoName, playerOneName)
                    
                }, label: {
                    Image("change")
                })
                .offset(x: UIScreen.main.bounds.width * 0, y: UIScreen.main.bounds.height * 0.42)
                
                // 흰 사각형(오)
                Rectangle()
                    .clipShape(
                        .rect(
                            topLeadingRadius: 5,
                            bottomLeadingRadius: 5,
                            bottomTrailingRadius: 5,
                            topTrailingRadius: 5
                        )
                    )
                    .edgesIgnoringSafeArea(.all)
                
                    .background(
                        
                        // 검은색 외곽선
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.black, lineWidth: 1.5)
                    )
                
                    .background(
                        // 노란색 외곽선
                        showYellowOutline ? nil : RoundedRectangle(cornerRadius: 5)
                            .stroke(Color(red: 255/255, green: 199/255, blue: 0/255), lineWidth: 4)
                            .padding(-1)
                        
                    )
                    .frame(width: UIScreen.main.bounds.width * 0.3,
                           height: UIScreen.main.bounds.height * 0.13)
                    .offset(x: UIScreen.main.bounds.width * 0.2, y: UIScreen.main.bounds.height * 0.42)
                    .foregroundStyle(.white)
                
                     // 키보드 높이만큼 패딩 적용.
//                    .animation(.default, value: keyboardHeight)
                    .onAppear{
                        // 노티 : 키보드가 나타날 때 키보드 높이 값을 전송하여 패딩을 적용함
                        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
                            guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
                            self.keyboardHeight = keyboardFrame.height
                        }
                        // 노티 : 키보드가 숨겨질 때 키보드 높이를 0으로 전송하여 원상복귀
                        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
                            self.keyboardHeight = 0
                        }
                        
                    }
                
                // 텍스트필드
                TextField("Enter Player2 Name", text: $playerTwoName){
                    UIApplication.shared.endEditing() // 입력을 마치면 키보드가 내려감
                    
                }
                .onReceive(Just(playerTwoName), perform: { _ in
                    limitText()
                    playerTwonameCount = playerTwoName.count
                })
                .foregroundStyle(.black)
                .bold()
                .background(Color(uiColor: .systemBackground))
                .frame(width: UIScreen.main.bounds.width * 0.23,
                       height: UIScreen.main.bounds.height * 0.13)
                .offset(x: UIScreen.main.bounds.width * 0.2, y: UIScreen.main.bounds.height * 0.42)
                
                // 글자 수 표시
                Label{
                    Text("\(playerTwonameCount)8")
                        .foregroundStyle(Color.white)
                } icon: {
                    
                }
                .frame(width: UIScreen.main.bounds.width * 0.23,
                       height: UIScreen.main.bounds.height * 0.13)
                .offset(x: UIScreen.main.bounds.width * 0.33, y: UIScreen.main.bounds.height * 0.52)
                
                // 홈버튼
                Button(action: {
                    moveToHome = true
                }, label: {
                    Image("home-white")
                        .resizable()
                        .scaledToFit()
                })
                .frame(width: 50, height: 100)
                .offset(x: UIScreen.main.bounds.width * -0.39, y: UIScreen.main.bounds.height * 0)
                .navigationDestination(isPresented: $moveToHome, destination: {
                    OpeningView(loadLastGame: defaultLoadLastGame)
                }).navigationBarBackButtonHidden(
                
                )
                
                // 글자를 입력해주세요.
                Text("Enter your name!").foregroundStyle(showWarningText ? .white : .clear)
                    .font(.custom("DungGeunMo", size: 30))
                    .offset(x: UIScreen.main.bounds.width * 0.0, y: UIScreen.main.bounds.height * 0.26)
                    
                
                // play 버튼
                Button(action: {
                    
                
                    if playerOneName.isEmpty || playerTwoName.isEmpty {
                        blinkWarningText()
                    } else {
                        updatePlayerOneName()
                        updatePlayerTwoName()
                        
                        self.vm.playPingPong()
                        moveToScoreBoard = true
                    }
                    
                    

                    
                }, label: {
                    Text("Play Game")
                        .font(.custom("DungGeunMo", size: 40))
                        .foregroundStyle(.white)
                    

                })
                    .background(
                        RoundedRectangle(cornerRadius: 30)
                            .shadow(color: Color(red: 0/255, green: 0/255, blue: 0.25/255).opacity(0.2), radius: 0.3, x: 2, y: 2)
                            .foregroundStyle(Color(red: 250/255, green: 54/255, blue: 42/255))
                            .frame(width: UIScreen.main.bounds.width * 0.34,
                                   height: UIScreen.main.bounds.height * 0.17)
                    )
                    .frame(width: UIScreen.main.bounds.width * 0.23,
                           height: UIScreen.main.bounds.height * 0.13)
                    .offset(x: UIScreen.main.bounds.width * 0.0, y: UIScreen.main.bounds.height * 0.73)
                    .padding(.bottom, keyboardHeight) // 키보드 높이만큼 패딩 적용.
                    .animation(.default, value: keyboardHeight)
                    .navigationDestination(isPresented: $moveToScoreBoard, destination: {
                        ScoreBoard(playerOneName: $playerOneName,
                                   playerTwoName: $playerTwoName, serviceRight: $serviceRight, loadLastGame: $defaultLoadLastGame, isUserOneServing: serviceRight)
                    })
                    
            }.onTapGesture {
                self.endEditing()
            }
        }
    }
    private func endEditing() {
           UIApplication.shared.endEditing()
       }
    
    private func limitText() {
        if playerOneName.count > 8 {
            playerOneName = String(playerOneName.prefix(10))
        }
    }
    
   private func blinkWarningText() {
        guard playerOneName.isEmpty || playerTwoName.isEmpty else { return }

        withAnimation(.easeInOut(duration: 0)) {
            showWarningText = true
        }

       DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeInOut(duration: 0)) {
                showWarningText = false
            }
        }

       DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.easeInOut(duration: 0)) {
                showWarningText = true
            }
        }

       DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            withAnimation(.easeInOut(duration: 0)) {
                showWarningText = false
            }
        }
       
       DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
            withAnimation(.easeInOut(duration: 0)) {
                showWarningText = true
            }
        }
    }

    fileprivate func updatePlayerOneName() {
        let currentLength = playerOneName.count
        let spacesToAdd = 8 - currentLength

        if spacesToAdd > 0 {
            playerOneName += String(repeating: " ", count: spacesToAdd)
        }
    }

    fileprivate func updatePlayerTwoName() {
        let currentLength = playerTwoName.count
        let spacesToAdd = 8 - currentLength

        if spacesToAdd > 0 {
            playerTwoName += String(repeating: " ", count: spacesToAdd)
        }
    }
    
}

#Preview {
    NewGame()
}
