//
//  ContentView.swift
//  Ping-PongScore
//
//  Created by 김은지 on 12/29/23.
//

import SwiftUI
import AVFoundation
import Foundation
import NaturalLanguage

// 가로 방향

class LandscapeOnlyViewController: UIViewController {
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }
}

struct LandscapeOnlyViewControllerWrapper: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> LandscapeOnlyViewController {
        LandscapeOnlyViewController()
    }
    
    func updateUIViewController(_ uiViewController: LandscapeOnlyViewController, context: Context) {
        uiViewController.navigationController?.setNeedsUpdateOfSupportedInterfaceOrientations()
    }
}

import Combine

class ScoreBoardVM : ObservableObject {
    
    @Published var userOneText : Int = 0
    
    
    
    
    var subscriptions : Set<AnyCancellable> = Set()
    
    var synthesizer: AVSpeechSynthesizer = AVSpeechSynthesizer()
    
    init(){
        
        $userOneText
            .sink(receiveValue: { score in
                
            }).store(in: &subscriptions)
    }
    
    func sayScore(score: Int){
        //        var utterance = AVSpeechUtterance(string: "\(score)")
        //        utterance.voice = AVSpeechSynthesisVoice(language: "en-GB")
        //        utterance.rate = 0.1
        //
        
        //
        let audioSession = AVAudioSession.sharedInstance()  //2
        do {
            try audioSession.setCategory(AVAudioSession.Category.soloAmbient)
            try audioSession.setMode(AVAudioSession.Mode.spokenAudio)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        //        var utterance = AVSpeechUtterance(string: "\(score)")
        //        utterance.rate = 0.3
        //        let synthesizer = AVSpeechSynthesizer()
        //        synthesizer.speak(utterance)
        
        speakText("\(score)")
    }
    func speakText(_ text: String) {
        synthesizer.stopSpeaking(at: .immediate)
        
        let utterance = AVSpeechUtterance(string: text)
        
        if let language = self.detectLanguageOf(text: text) {
            utterance.voice = AVSpeechSynthesisVoice(language: language.rawValue)
        }
        
        synthesizer.speak(utterance)
    }
    
    private func detectLanguageOf(text: String) -> NLLanguage? {
        let recognizer = NLLanguageRecognizer()
        recognizer.processString(text)
        
        guard let language = recognizer.dominantLanguage else {
            return nil
        }
        
        return language
    }}

struct ScoreBoard: View {
    
    @StateObject var viewModel : ScoreBoardVM = ScoreBoardVM()
    
    @State private var moveToHome = false
    
    @Binding var playerOneName: String
    @Binding var playerTwoName: String
    @Binding var serviceRight: Int
    
    @State private var playerOneScore = 0 {
        didSet {
            winScore()
        }
    }
    
    
    
    @State private var playerTwoScore = 0 {
        didSet {
            winScore()
        }
    }
    @State private var flipDegreesUserOne = 0.0
    @State private var flipDegreesUserTwo = 0.0
    @State private var flipPersDegreesUserOne = 0.0
    @State private var flipPersDegreesUserTwo = 0.0
    @State private var allScore = 0 {
        didSet {
            print("총 점수: \(allScore)")
            updateServing()
            viewModel.sayScore(score: allScore)
        }
    }
    
    // 플레이어 원이 서브권을 가질 때
    @State private var isUserOneServing = false {
        didSet {
            print("userOneServing: \(isUserOneServing)")
        }
    }
    
    
    @State private var playOneSetScore = 0
    @State private var playTwoSetScore = 0
    @State private var deuce = false
    @State private var gameOver = false
    
    
    var body: some View {
        NavigationStack {
            VStack {
                
                
                ZStack {
                    // 홈 버튼
                    
                    Button(action: {
                        
                        moveToHome = true
                        
                        // 점수 위치 바꾸기
                    }, label: {
                        Image("home")
                            .resizable()
                            .scaledToFit()
                    })
                    .frame(width: 50, height: 100)
                    .offset(x: UIScreen.main.bounds.width * -0.43, y: UIScreen.main.bounds.height * 0.12)
                    .navigationDestination(isPresented: $moveToHome, destination: {
                        OpeningView()
                    }).navigationBarBackButtonHidden()
                    
                    // 첫번째 유저 큰 점수판
                    Text(playerOneName)
                        .foregroundStyle(.black)
                        .bold()
                        .font(.system(size: 35, weight:.bold, design: .default))
                        .offset(x: UIScreen.main.bounds.width * -0.3, y: UIScreen.main.bounds.height * 0.12)
                    
                    Rectangle()
                        .clipShape(
                            .rect(
                                topLeadingRadius: 10,
                                bottomLeadingRadius: 10,
                                bottomTrailingRadius: 10,
                                topTrailingRadius: 10
                            )
                        )
                        .frame(width: UIScreen.main.bounds.width * 0.23, height: UIScreen.main.bounds.height * 0.72)
                        .foregroundColor(.black)
                        .offset(x: UIScreen.main.bounds.width * -0.3, y: UIScreen.main.bounds.height * 0.55)
                        .rotation3DEffect(Angle(degrees: flipDegreesUserOne), axis: (x: 1, y: 0, z: 0), perspective: flipPersDegreesUserOne) // 뒤로 넘어가는 효과
                        .onTapGesture {
                            addUserOneScore()
                        }
                        .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)
                            .onEnded({ value in
                                if abs(value.translation.width) > abs(value.translation.height) {
                                    // 수평 이동이 더 클 경우
                                    if value.translation.width < 0 {
                                        // 왼쪽으로 드래그
                                        subtractUserOneScore()
                                    } else {
                                        // 오른쪽으로 드래그
                                        addUserOneScore()
                                    }
                                } else {
                                    // 수직 이동이 더 클 경우
                                    if value.translation.height < 0 {
                                        // 위로 드래그
                                        addUserOneScore()
                                    } else {
                                        // 아래로 드래그
                                        subtractUserOneScore()
                                    }
                                }
                            }))
                    
                    let color: Color = (playerOneScore % 5 == 0 && playerOneScore != 0) ? Color(red: 240/255, green: 54/255, blue: 42/255) : .white
                    
                    Text("\(playerOneScore)")
                        .foregroundStyle(color)
                        .bold()
                        .font(.system(size: 150, weight:.bold, design: .default))
                        .offset(x: UIScreen.main.bounds.width * -0.3, y: UIScreen.main.bounds.height * 0.55)
                    // 서브권
                    Text(isUserOneServing ? "Serve" : "")
                        .foregroundStyle(.white)
                        .font(.system(size: 40, weight:.bold, design: .default))
                        .offset(x: UIScreen.main.bounds.width * -0.3, y: UIScreen.main.bounds.height * 0.83)
                    
                    // 세트 스코어
                    Rectangle()
                        .clipShape(
                            .rect(
                                topLeadingRadius: 10,
                                bottomLeadingRadius: 10,
                                bottomTrailingRadius: 10,
                                topTrailingRadius: 10
                            )
                        )
                        .frame(width: UIScreen.main.bounds.width * 0.11, height: UIScreen.main.bounds.height * 0.35)
                        .foregroundColor(.black)
                        .offset(x: UIScreen.main.bounds.width * -0.12, y: UIScreen.main.bounds.height * 0.735)
                    Text("\(playOneSetScore)")
                        .foregroundStyle(.white)
                        .bold()
                        .font(.system(size: 110, weight:.bold, design: .default))
                        .offset(x: UIScreen.main.bounds.width * -0.12, y: UIScreen.main.bounds.height * 0.735)
                    
                    
                    // 체인지 버튼
                    // 이름, 점수, 세트 점수, 서브권
                    Button(action: {
                        
                        (playerOneName, playerTwoName) = (playerTwoName, playerOneName)
                        
                        (playerOneScore, playerTwoScore) = (playerTwoScore, playerOneScore)
                        
                        (playOneSetScore, playTwoSetScore) = (playTwoSetScore, playOneSetScore)
                        
                        isUserOneServing.toggle()
                        
                        // 점수 위치 바꾸기
                    }, label: {
                        Image("change")
                            .resizable()
                            .scaledToFit()
                    })
                    .frame(width: 60, height: 60)
                    .offset(x: UIScreen.main.bounds.width * 0, y: UIScreen.main.bounds.height * 0.42)
                    
                    
                    
                    // 두번째 유저 큰 점수판
                    Text(playerTwoName)
                        .foregroundStyle(.black)
                        .bold()
                        .font(.system(size: 35, weight:.bold, design: .default))
                        .offset(x: UIScreen.main.bounds.width * 0.3, y: UIScreen.main.bounds.height * 0.12)
                    
                    Rectangle()
                        .clipShape(
                            .rect(
                                topLeadingRadius: 10,
                                bottomLeadingRadius: 10,
                                bottomTrailingRadius: 10,
                                topTrailingRadius: 10
                            )
                        )
                        .frame(width: UIScreen.main.bounds.width * 0.23, height: UIScreen.main.bounds.height * 0.72)
                        .foregroundColor(.black)
                        .offset(x: UIScreen.main.bounds.width * 0.3, y: UIScreen.main.bounds.height * 0.55)
                        .rotation3DEffect(Angle(degrees: flipDegreesUserTwo), axis: (x: 1, y: 0, z: 0), perspective: flipPersDegreesUserTwo) // 뒤로 넘어가는 효과
                        .onTapGesture {
                            addUserTwoScore()
                            //                        viewModel.sayScore(score: 10)
                        }
                        .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)
                            .onEnded({ value in
                                if abs(value.translation.width) > abs(value.translation.height) {
                                    // 수평 이동이 더 클 경우
                                    if value.translation.width < 0 {
                                        // 왼쪽으로 드래그
                                        subtractUserTwoScore()
                                    } else {
                                        // 오른쪽으로 드래그
                                        addUserTwoScore()
                                    }
                                } else {
                                    // 수직 이동이 더 클 경우
                                    if value.translation.height < 0 {
                                        // 위로 드래그
                                        addUserTwoScore()
                                    } else {
                                        // 아래로 드래그
                                        subtractUserTwoScore()
                                    }
                                }
                            }))
                    // 서브권
                    Text(isUserOneServing ? "" : "Serve")
                        .foregroundStyle(.white)
                        .font(.system(size: 40, weight:.bold, design: .default))
                        .offset(x: UIScreen.main.bounds.width * 0.301, y: UIScreen.main.bounds.height * 0.83)
                    
                    let playerTwoColor: Color = (playerTwoScore % 5 == 0 && playerTwoScore != 0) ? Color(red: 240/255, green: 54/255, blue: 42/255) : .white
                    
                    Text("\(playerTwoScore)")
                        .foregroundStyle(playerTwoColor)
                        .bold()
                        .font(.system(size: 130, weight:.bold, design: .default))
                        .offset(x: UIScreen.main.bounds.width * 0.3, y: UIScreen.main.bounds.height * 0.55)
                }
                
                // 세트 스코어
                Rectangle()
                    .clipShape(
                        .rect(
                            topLeadingRadius: 10,
                            bottomLeadingRadius: 10,
                            bottomTrailingRadius: 10,
                            topTrailingRadius: 10
                        )
                    )
                    .frame(width: UIScreen.main.bounds.width * 0.11, height: UIScreen.main.bounds.height * 0.35)
                    .foregroundColor(.black)
                    .offset(x: UIScreen.main.bounds.width * 0.12, y: UIScreen.main.bounds.height * -0.03)
                Text("\(playTwoSetScore)")
                //                .foregroundStyle()
                    .foregroundStyle(.white)
                    .bold()
                    .font(.system(size: 110, weight:.bold, design: .default))
                    .offset(x: UIScreen.main.bounds.width * 0.12, y: UIScreen.main.bounds.height * -0.48)
                
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(red: 72/255, green: 127/255, blue: 233/255))
            .background(LandscapeOnlyViewControllerWrapper())
            
            
            // 앱 화면이 안 꺼지게 하기
            .onAppear {
                UIApplication.shared.isIdleTimerDisabled = true
            }
            .onDisappear {
                UIApplication.shared.isIdleTimerDisabled = false
            }
            
        }
    }
    
    fileprivate func addUserOneScore() {
        allScore += 1
        playerOneScore += 1
        
        withAnimation(.easeInOut(duration: 0.25)) {
            // Rotate halfway
            flipDegreesUserOne += 180
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.easeInOut(duration: 0.1)) {
                // Complete the flip
                flipDegreesUserOne += 180
                
                // Reset to 0 (equivalent to 360) for next flip
                if flipDegreesUserOne >= 360 {
                    flipDegreesUserOne = 0
                }
            }
        }
    }
    
    
    fileprivate func addUserTwoScore() {
        allScore += 1
        playerTwoScore += 1
        
        withAnimation(.easeInOut(duration: 0.25)) {
            // Rotate halfway
            flipDegreesUserTwo += 180
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.easeInOut(duration: 0.1)) {
                // Complete the flip
                flipDegreesUserTwo += 180
                
                // Reset to 0 (equivalent to 360) for next flip
                if flipDegreesUserTwo >= 360 {
                    flipDegreesUserTwo = 0
                }
            }
        }
    }
    
    fileprivate func subtractUserOneScore() {
        print(#fileID, #function, #line, "- <# 주석 #>")
        
        if playerOneScore <= 0 {
            return
        }
        
        allScore -= 1
        playerOneScore -= 1
        
        withAnimation(.easeInOut(duration: 0.25)) {
            // Rotate halfway in the reverse direction
            flipDegreesUserOne -= 180
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.easeInOut(duration: 0.1)) {
                // Complete the reverse flip
                flipDegreesUserOne -= 180
                
                // Reset to 0 (equivalent to -360) for next flip
                if flipDegreesUserOne <= -360 {
                    flipDegreesUserOne = 0
                }
            }
        }
    }
    
    fileprivate func subtractUserTwoScore() {
        print(#fileID, #function, #line, "- <# 주석 #>")
        
        if playerTwoScore <= 0 {
            return
        }
        
        allScore -= 1
        playerTwoScore -= 1
        
        withAnimation(.easeInOut(duration: 0.25)) {
            // Rotate halfway in the reverse direction
            flipDegreesUserTwo -= 180
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.easeInOut(duration: 0.1)) {
                // Complete the reverse flip
                flipDegreesUserTwo -= 180
                
                // Reset to 0 (equivalent to -360) for next flip
                if flipDegreesUserTwo <= -360 {
                    flipDegreesUserTwo = 0
                }
            }
        }
    }
    
    fileprivate func updateServing() {
        if allScore % 2 == 0 {
            isUserOneServing.toggle()
        }
    }
    
    fileprivate func winScore() {
        
        if gameOver { return }
        
        
        // 듀스게임
        if deuce {
            // abs는 절대값 함수
            if abs(playerOneScore - playerTwoScore) == 2 {
                gameOver = true
                // Deuce resolution
                if playerOneScore > playerTwoScore {
                    playOneSetScore += 1
                    print(#fileID, #function, #line, "- 듀스에서 userOne이 이겼습니다.")
                } else {
                    playTwoSetScore += 1
                    print(#fileID, #function, #line, "- 듀스에서 userTwo가 이겼습니다.")
                }
                resetGame()
            }
        } else {
            // Normal play
            if (playerOneScore >= 11 || playerTwoScore >= 11) && abs(playerOneScore - playerTwoScore) >= 2 {
                gameOver = true
                if playerOneScore > playerTwoScore {
                    playOneSetScore += 1
                    print(#fileID, #function, #line, "- userOne이 이겼습니다!")
                } else {
                    playTwoSetScore += 1
                    print(#fileID, #function, #line, "- userTwo가 이겼습니다.")
                }
                resetGame()
            } else if playerOneScore == 10 && playerTwoScore == 10 {
                // 듀스입니다!
                deuce = true
                print(#fileID, #function, #line, "- 듀스입니다.")
            }
        }
    }
    
    fileprivate func resetGame() {
        playerOneScore = 0
        playerTwoScore = 0
        allScore = 0
        deuce = false
        gameOver = false
    }
    
    
    
}




#Preview {
    ScoreBoard(playerOneName: .constant("Player 1"), playerTwoName: .constant("Player 2"), serviceRight: .constant(0))
}


