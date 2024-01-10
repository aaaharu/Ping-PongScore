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


struct PlayerScore: Codable, Identifiable {
    var id = UUID()  // UUID를 사용하여 각 인스턴스가 고유하게 식별되도록 함.
    var winnerName: String
    var player: String
    var winnerScore: Int
    var playerScore: Int
    var date: Date
}

// GameOver Alert View
struct GameOverView: View {
    @Binding var shouldResetScore: Bool
    @State var moveToNewGame: Bool = false
    var dismissAction: () -> Void
    var navToNewPlayerView: (() -> Void)?
    
    
    var body: some View {
        ZStack {
            
            
            VStack {
                StrokeText(text: "End of Game", width: 1, color: Color(red: 0/255, green: 0/255, blue: 0/255))
                    .foregroundStyle(Color(red: 255/255, green: 255/255, blue: 255/255))
                    .font(.custom("DungGeunMo", size: 30))
                
                Divider()
                    .background(Color.white)
                    .padding(.horizontal, 30)
                
                Spacer()
                
                Button(action: {
                    shouldResetScore = true
                    dismissAction()
                }) {
                    StrokeText(text: "Play with Same Player", width: 1, color: Color(red: 0/255, green: 0/255, blue: 0/255))
                        .foregroundStyle(Color(red: 255/255, green: 255/255, blue: 255/255))
                        .font(.custom("DungGeunMo", size: 25))
                }
                .frame(width: 320, height: 60)
                .background(Color.blue)
                .cornerRadius(10)
                .padding(.bottom, 5)
                
                Button(action: {
                
              
                    moveToNewGame = true
                    
                }) {
                    StrokeText(text: "Play with New Player", width: 1, color: Color(red: 0/255, green: 0/255, blue: 0/255))
                        .foregroundStyle(Color(red: 255/255, green: 255/255, blue: 255/255))
                        .font(.custom("DungGeunMo", size: 25))
                }
                
                
                .frame(width: 320, height: 60)
                .background(Color.red)
                .cornerRadius(10)
                .navigationDestination(isPresented: $moveToNewGame, destination: {
                    NewGame()
                }).navigationBarBackButtonHidden()
                .padding(.bottom, 20)
            }
            .padding()
            .background(Color(red: 255/255, green: 199/255, blue: 0/255))
            .cornerRadius(20)
            .overlay( /// apply a rounded border
                RoundedRectangle(cornerRadius: 20)
                    .stroke(.white, lineWidth: 5)
            )
            
        }
            .frame(width: UIScreen.main.bounds.width * 0.5, height: UIScreen.main.bounds.height * 0.55)
            .offset(x: UIScreen.main.bounds.width * 0, y: UIScreen.main.bounds.height * 0.35)

            .zIndex(1)
            
    }
}


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
    @Published var scores: [PlayerScore] = []
    
    var subscriptions : Set<AnyCancellable> = Set()
    
    var synthesizer: AVSpeechSynthesizer = AVSpeechSynthesizer()
    
    init(){
        
        $userOneText
            .sink(receiveValue: { score in
                
            }).store(in: &subscriptions)
        
        loadScores()
        
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
    }
    
    func saveScore(_ score: PlayerScore) {
        print(#fileID, #function, #line, "- <# 주석 #>")
        scores.append(score)
        if let encoded = try? JSONEncoder().encode(scores) {
            UserDefaults.standard.set(encoded, forKey: "SavedScores")
        }
    }
    
    func loadScores() {
        if let savedScores = UserDefaults.standard.object(forKey: "SavedScores") as? Data {
            if let decodedScores = try? JSONDecoder().decode([PlayerScore].self, from: savedScores) {
                self.scores = decodedScores
            }
        }
    }
        
  
    
    
}

struct ScoreBoard: View {
    
    struct GameScores: Codable {
        var playerOneName: String
        var playerTwoName: String
        var playerOneScore: Int
        var playerTwoScore: Int
        var playerOneSetScore: Int
        var playerTwoSetScore: Int
        var totalScore: Int
        var servingPlayerOne: Bool
    }
    
    @State private var shouldResetScore = false
    @State private var isGameOver = false

    @State private var canSave: Bool = true
    
    
    @StateObject var viewModel : ScoreBoardVM = ScoreBoardVM()
    let soundVM = PlayViewModel()
    
    @State private var moveToHome = false
    
    @Binding var playerOneName: String {
        didSet {
                print(#fileID, #function, #line, "- playerOne의 이름이 바뀌었습니다. \(playerOneName)")
        }
    }
    @Binding var playerTwoName: String
    @Binding var serviceRight: Bool
    
    @Binding var loadLastGame: Bool {
        didSet {
                print(#fileID, #function, #line, "- <# 주석 #>")
//            if loadLastGame == true {
//                reloadLastGame()
//            }
        }
    }
    
    @State private var playerOneScore = 0 {
        didSet {
                print(#fileID, #function, #line, "- playerOneScore: \(playerOneScore)")
            winScore()
            
        }
    }
    
    
    
    @State private var playerTwoScore = 0 {
        didSet {
            winScore()
            
        }
    }
    @State private var flipDegreesUserOne = 0.0
    @State private var flipDegreesUserOneSet = 0.0
    @State private var flipDegreesUserTwo = 0.0
    @State private var flipDegreesUserTwoSet = 0.0
    @State private var allScore = 0 {
        didSet {
            print("총 점수: \(allScore)")
            updateServing()
            saveLastGame() // 지난 게임 저장하기
//            viewModel.sayScore(score: allScore)
        }
    }
    
    // 플레이어 원이 서브권을 가질 때
    @State var isUserOneServing: Bool {
        didSet {
            print("userOneServing: \(isUserOneServing)")
        }
    }
    
    
    @State private var playerOneSetScore = 0 {
        didSet {
            saveLastGame()
            if playerOneSetScore == 3 {
                self.soundVM.playWinSound()
                winSetScore()
            }
        }
    }
    @State private var playerTwoSetScore = 0 {
        didSet {
            saveLastGame()
            if playerTwoSetScore == 3 {
                self.soundVM.playWinSound()
                winSetScore()
            }
        }
    }
    @State private var deuce = false
    @State private var gameOver = false
    
    @State private var winPlayerOne = false
    @State private var winPlayerTwo = false {
        didSet {
            print(#fileID, #function, #line, "- winplayerTwo: \(winPlayerTwo)")
        }
    }
    @State private var takenCrownWinner: CGFloat = 0.0
    
    
    var body: some View {
        
        NavigationStack {
            VStack {
            
                
                ZStack {
                    
                    // 게임 끝난 후 Alert View
                    if isGameOver {
                      GameOverView(shouldResetScore: $shouldResetScore,
                                   dismissAction: {
                          isGameOver = false
                      },
                                   navToNewPlayerView: {
                         
                      })
                    }
                    

                    // 홈 버튼
                    Button(action: {
                        moveToHome = true
                    }, label: {
                        Image("home")
                            .resizable()
                            .scaledToFit()
                    })
                    .frame(width: 50, height: 100)
                    .offset(x: UIScreen.main.bounds.width * -0.43, y: UIScreen.main.bounds.height * -0.07)
                    .navigationDestination(isPresented: $moveToHome, destination: {
                        OpeningView(loadLastGame: loadLastGame)
                    }).navigationBarBackButtonHidden()
                    
                    // 첫번째 유저 큰 점수판
                    Text(playerOneName)
                        .foregroundStyle(.black)
                        .bold()
                        .font(.system(size: 35, weight:.bold, design: .default))
                        .offset(x: UIScreen.main.bounds.width * -0.3, y: UIScreen.main.bounds.height * -0.07)
                    
                    ZStack {  Rectangle()
                            .clipShape(
                                .rect(
                                    topLeadingRadius: 10,
                                    bottomLeadingRadius: 10,
                                    bottomTrailingRadius: 10,
                                    topTrailingRadius: 10
                                )
                            )
                            .frame(width: UIScreen.main.bounds.width * 0.23, height: UIScreen.main.bounds.height * 0.72)
                            .foregroundStyle(.black)
                            .offset(x: UIScreen.main.bounds.width * -0.3, y: UIScreen.main.bounds.height * 0.35)
                        
                        
                        let color: Color = (playerOneScore % 5 == 0 && playerOneScore != 0) ? Color(red: 255/255, green: 199/255, blue: 0/255) : .white
                        
                        Text("\(playerOneScore)")
                            .foregroundStyle(color)
                            .bold()
                            .font(.system(size: 150, weight:.bold, design: .default))
                            .offset(x: UIScreen.main.bounds.width * -0.3, y: UIScreen.main.bounds.height * 0.35)
                    }.onTapGesture {
                        addUserOneScore()
                    }.rotation3DEffect(Angle(degrees: flipDegreesUserOne), axis: (x: 1, y: 0, z: 0), perspective: 0) // 뒤로 넘어가는 효과
                    
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
                    
                    
                    // 서브권
                    Text(isUserOneServing ? "Serve" : "")
                        .foregroundStyle(.white)
                        .font(.system(size: 40, weight:.bold, design: .default))
                        .offset(x: UIScreen.main.bounds.width * -0.3, y: UIScreen.main.bounds.height * 0.62)
                    
                    ZStack {
                        // 플레이어1 세트 스코어
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
                            .foregroundStyle(.black)
                            .offset(x: UIScreen.main.bounds.width * -0.12, y: UIScreen.main.bounds.height * 0.54)
                        
                        let playerOneSetColor: Color = (playerOneSetScore % 2 == 0 && playerOneSetScore != 0) ? Color(red: 255/255, green: 199/255, blue: 0/255) : .white
                        
                        Text("\(playerOneSetScore)")
                            .foregroundStyle(playerOneSetColor)
                            .bold()
                            .font(.system(size: 110, weight:.bold, design: .default))
                            .offset(x: UIScreen.main.bounds.width * -0.12, y: UIScreen.main.bounds.height * 0.54)
                    }.onTapGesture {
                        addUserOneSetScore()
                    }
                    .rotation3DEffect(Angle(degrees: flipDegreesUserOneSet), axis: (x: 1, y: 0, z: 0), perspective: 0) // 뒤로 넘어가는 효과
                    .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)
                        .onEnded({ value in
                            if abs(value.translation.width) > abs(value.translation.height) {
                                // 수평 이동이 더 클 경우
                                if value.translation.width < 0 {
                                    // 왼쪽으로 드래그
                                    subtractUserOneSetScore()
                                } else {
                                    // 오른쪽으로 드래그
                                    addUserOneSetScore()
                                }
                            } else {
                                // 수직 이동이 더 클 경우
                                if value.translation.height < 0 {
                                    // 위로 드래그
                                    addUserOneSetScore()
                                } else {
                                    // 아래로 드래그
                                    subtractUserOneSetScore()
                                }
                            }
                        }))
                    
                    if winPlayerOne || winPlayerTwo {
                        Image("win")
                            .offset(
                                x: UIScreen.main.bounds.width * takenCrownWinner,
                                y: UIScreen.main.bounds.height * 0.32
                            )
                    }
                    
                    
                    
                    
                    // 체인지 버튼
                    // 이름, 점수, 세트 점수, 서브권
                    Button(action: {
                        
                        (playerOneName, playerTwoName) = (playerTwoName, playerOneName)
                        
                        (playerOneScore, playerTwoScore) = (playerTwoScore, playerOneScore)
                        
                        (playerOneSetScore, playerTwoSetScore) = (playerTwoSetScore, playerOneSetScore)
                        
                        isUserOneServing.toggle()
                        
                        // 점수 위치 바꾸기
                    }, label: {
                        Image("change")
                            .resizable()
                            .scaledToFit()
                    })
                    .frame(width: 60, height: 60)
                    .offset(x: UIScreen.main.bounds.width * 0, y: UIScreen.main.bounds.height * 0.32)
                    
                    
                    
                    // 두번째 유저 큰 점수판
                    Text(playerTwoName)
                        .foregroundStyle(.black)
                        .bold()
                        .font(.system(size: 35, weight:.bold, design: .default))
                        .offset(x: UIScreen.main.bounds.width * 0.3, y: UIScreen.main.bounds.height * -0.07)
                    ZStack {
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
                            .foregroundStyle(.black)
                            .offset(x: UIScreen.main.bounds.width * 0.3, y: UIScreen.main.bounds.height * 0.35)
                            .rotation3DEffect(Angle(degrees: flipDegreesUserTwo), axis: (x: 1, y: 0, z: 0), perspective: 0) // 뒤로 넘어가는 효과
                        
                        // 서브권
                        Text(isUserOneServing ? "" : "Serve")
                            .foregroundStyle(.white)
                            .font(.system(size: 40, weight:.bold, design: .default))
                            .offset(x: UIScreen.main.bounds.width * 0.301, y: UIScreen.main.bounds.height * 0.6)
                        
                        let playerTwoColor: Color = (playerTwoScore % 5 == 0 && playerTwoScore != 0) ? Color(red: 255/255, green: 199/255, blue: 0/255) : .white
                        
                        Text("\(playerTwoScore)")
                            .foregroundStyle(playerTwoColor)
                            .bold()
                            .font(.system(size: 130, weight:.bold, design: .default))
                            .offset(x: UIScreen.main.bounds.width * 0.3, y: UIScreen.main.bounds.height * 0.35)
                    }
                    
                    
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
                    
                    // 플레이어2 세트 스코어
                    ZStack {
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
                            .foregroundStyle(.black)
                            .offset(x: UIScreen.main.bounds.width * 0.12, y: UIScreen.main.bounds.height * 0.54)
                        
                        
                        
                        let playerTwoSetColor: Color = (playerTwoSetScore % 2 == 0 && playerTwoSetScore != 0) ? Color(red: 255/255, green: 199/255, blue: 0/255) : .white
                        
                        Text("\(playerTwoSetScore)")
                            .foregroundStyle(playerTwoSetColor)
                            .bold()
                            .font(.system(size: 110, weight:.bold, design: .default))
                            .offset(x: UIScreen.main.bounds.width * 0.12, y: UIScreen.main.bounds.height * 0.54)
                    }.onTapGesture {
                        addUserTwoSetScore()
                        //                        viewModel.sayScore(score: 10)
                    }
                        .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)
                            .onEnded({ value in
                                if abs(value.translation.width) > abs(value.translation.height) {
                                    // 수평 이동이 더 클 경우
                                    if value.translation.width < 0 {
                                        // 왼쪽으로 드래그
                                        subtractUserTwoSetScore()
                                    } else {
                                        // 오른쪽으로 드래그
                                        addUserTwoSetScore()
                                    }
                                } else {
                                    // 수직 이동이 더 클 경우
                                    if value.translation.height < 0 {
                                        // 위로 드래그
                                        addUserTwoSetScore()
                                    } else {
                                        // 아래로 드래그
                                        subtractUserTwoSetScore()
                                    }
                                }
                            }))
                    
                }.offset(x: UIScreen.main.bounds.width * 0.01, y: UIScreen.main.bounds.height * -0.3)
                    .onAppear{
                        if loadLastGame == true {
                            reloadLastGame()
                        }
                    }
                    .onChange(of: shouldResetScore) { newValue in
                        if newValue {
                            resetGame()
                        }
                    
                    }
            }
            
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(red: 72/255, green: 127/255, blue: 233/255))
            .background(LandscapeOnlyViewControllerWrapper())
            
            
            // 앱 화면이 안 꺼지게 하기
            .onAppear { // 뷰가 나타날 때 (viewDidLoad 역할)
                UIApplication.shared.isIdleTimerDisabled = true
                
               
            }
            
            
        }
    }
    
    fileprivate func addUserOneScore() {
        
        playerOneScore += 1
        allScore += 1
        
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
    
    fileprivate func addUserOneSetScore() {
        
        playerOneSetScore += 1
        
        withAnimation(.easeInOut(duration: 0.25)) {
            // Rotate halfway
            flipDegreesUserOneSet += 180
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.easeInOut(duration: 0.1)) {
                // Complete the flip
                flipDegreesUserOneSet += 180
                
                // Reset to 0 (equivalent to 360) for next flip
                if flipDegreesUserOneSet >= 360 {
                    flipDegreesUserOneSet = 0
                }
            }
        }
    }
    
    
    fileprivate func addUserTwoScore() {
       
        playerTwoScore += 1
        allScore += 1
        
        
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
    
    fileprivate func addUserTwoSetScore() {
        
        playerTwoSetScore += 1
        
        withAnimation(.easeInOut(duration: 0.25)) {
            // Rotate halfway
            flipDegreesUserTwoSet += 180
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.easeInOut(duration: 0.1)) {
                // Complete the flip
                flipDegreesUserTwoSet += 180
                
                // Reset to 0 (equivalent to 360) for next flip
                if flipDegreesUserTwoSet >= 360 {
                    flipDegreesUserTwoSet = 0
                }
            }
        }
    }
    
    fileprivate func subtractUserOneScore() {
        print(#fileID, #function, #line, "- <# 주석 #>")
        
        if playerOneScore <= 0 {
            return
        }
        
        
        playerOneScore -= 1
        allScore -= 1
        
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
    
    fileprivate func subtractUserOneSetScore() {
        print(#fileID, #function, #line, "- <# 주석 #>")
        
        if playerOneSetScore <= 0 {
            return
        }
        
        playerOneSetScore -= 1
        
        withAnimation(.easeInOut(duration: 0.25)) {
            // Rotate halfway in the reverse direction
            flipDegreesUserOneSet -= 180
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.easeInOut(duration: 0.1)) {
                // Complete the reverse flip
                flipDegreesUserOneSet -= 180
                
                // Reset to 0 (equivalent to -360) for next flip
                if flipDegreesUserOneSet <= -360 {
                    flipDegreesUserOneSet = 0
                }
            }
        }
    }
    
    fileprivate func subtractUserTwoScore() {
        print(#fileID, #function, #line, "- <# 주석 #>")
        
        if playerTwoScore <= 0 {
            return
        }
        
        
        playerTwoScore -= 1
        allScore -= 1
        
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
    
    fileprivate func subtractUserTwoSetScore() {
        print(#fileID, #function, #line, "- <# 주석 #>")
        
        if playerTwoSetScore <= 0 {
            return
        }
        
        allScore -= 1
        playerTwoSetScore -= 1
        
        withAnimation(.easeInOut(duration: 0.25)) {
            // Rotate halfway in the reverse direction
            flipDegreesUserTwoSet -= 180
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.easeInOut(duration: 0.1)) {
                // Complete the reverse flip
                flipDegreesUserTwoSet -= 180
                
                // Reset to 0 (equivalent to -360) for next flip
                if flipDegreesUserTwoSet <= -360 {
                    flipDegreesUserTwoSet = 0
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
        print(#fileID, #function, #line, "- <# 주석 #>")
        
        if gameOver { return }
        
        
        // 듀스게임
        if deuce {
            // abs는 절대값 함수
            if abs(playerOneScore - playerTwoScore) == 2 {
                gameOver = true
                // Deuce resolution
                if playerOneScore > playerTwoScore {
                    print(#fileID, #function, #line, "- 듀스에서 userOne이 이겼습니다.")
                    playerOneSetScore += 1
                    (playerOneScore, playerTwoScore) = (0, 0)

                   
                } else {
                    print(#fileID, #function, #line, "- 듀스에서 userTwo가 이겼습니다.")
                    playerTwoSetScore += 1
                    (playerOneScore, playerTwoScore) = (0, 0)

                   
                    // 이겼다 왕관 표시.
                    winPlayerTwo = true
                    // userDefaults에 스코어 저장.
                    let currentScore = PlayerScore(winnerName: playerTwoName, player: playerOneName, winnerScore: playerTwoScore, playerScore: playerOneScore, date: Date.now)
                    viewModel.saveScore(currentScore)
                }
        
            }
        } else {
            // Normal play
            if (playerOneScore >= 11 || playerTwoScore >= 11) && abs(playerOneScore - playerTwoScore) >= 2 {

                gameOver = true
                if playerOneScore > playerTwoScore {
                    print(#fileID, #function, #line, "- userOne이 이겼습니다!")
                    (playerOneScore, playerTwoScore) = (0, 0)
                    playerOneSetScore += 1
                  
                    
                    
                    
                    
                    
                    // userDefaults에 스코어 저장.
                    let currentScore = PlayerScore(winnerName: playerOneName, player: playerTwoName, winnerScore: playerOneScore, playerScore: playerTwoScore, date: Date.now)
                    viewModel.saveScore(currentScore)
                } else {
                    print(#fileID, #function, #line, "- userTwo가 이겼습니다.")
                    playerTwoSetScore += 1
                    (playerOneScore, playerTwoScore) = (0, 0)
             
                    
                    
                    
                    // userDefaults에 스코어 저장.
                    let currentScore = PlayerScore(winnerName: playerTwoName, player: playerOneName, winnerScore: playerTwoScore, playerScore: playerOneScore, date: Date.now)
                    viewModel.saveScore(currentScore)
                }
           
            } else if playerOneScore == 10 && playerTwoScore == 10 {
                // 듀스입니다!
                deuce = true
                print(#fileID, #function, #line, "- 듀스입니다.")
                // TODO: 듀스 사운드 재생.
            }
        }
        print(#fileID, #function, #line, "- winScore 끝")
    }
    
    fileprivate func resetGame() {
            print(#fileID, #function, #line, "- <# 주석 #>")
        playerOneScore = 0
        playerTwoScore = 0
        playerOneSetScore = 0
        playerTwoSetScore = 0
        allScore = 0
        deuce = false
        gameOver = false
        winPlayerOne = false
        winPlayerTwo = false
    }
    
    
    fileprivate func winSetScore() {
        print(#fileID, #function, #line, "- <# 주석 #>")
        
        if playerOneSetScore > playerTwoSetScore {// 이겼다 왕관 표시.
            print(#fileID, #function, #line, "- playerOne이 경기에서 우승했습니다")
            winPlayerOne = true
            takenCrownWinner = -0.12
            
            // userDefaults에 스코어 저장.
            let currentScore = PlayerScore(winnerName: playerOneName, player: playerTwoName, winnerScore: playerOneScore, playerScore: playerTwoScore, date: Date.now)
            viewModel.saveScore(currentScore)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                isGameOver = true
            }
            
            
            
        } else if playerTwoSetScore > playerOneSetScore {
            print(#fileID, #function, #line, "- playerTwo가 경기에서 우승했습니다")
            winPlayerTwo = true
            takenCrownWinner = 0.12
            
            // userDefaults에 스코어 저장.
            let currentScore = PlayerScore(winnerName: playerOneName, player: playerTwoName, winnerScore: playerOneScore, playerScore: playerTwoScore, date: Date.now)
            viewModel.saveScore(currentScore)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isGameOver = true
            }
        }
        
    }
    
    fileprivate func saveLastGame() {
        
        guard canSave == true else { return }
        
            print(#fileID, #function, #line, "- playerOne의 이름은 \(playerOneName)입니다.")
            
            // 저장할 항목 1. Score: playerOneScore, playerTwoScore,
            // 2. SetScore playerOneSetScore, playerTwoSetSocre
            // 3. 총 점수
            // 4. 서브권
        
        let scores = GameScores(playerOneName: self.playerOneName, playerTwoName: self.playerTwoName, playerOneScore: playerOneScore, playerTwoScore: playerTwoScore, playerOneSetScore: playerOneSetScore, playerTwoSetScore: playerTwoSetScore, totalScore: allScore, servingPlayerOne: isUserOneServing)

        print(#fileID, #function, #line, "- playerOne의 이름이 \(scores.playerOneName)으로 저장되었습니다.")
            
            if let encoded = try? JSONEncoder().encode(scores) {
                UserDefaults.standard.set(encoded, forKey: "SavedLastScores")
            }
    }
    
    fileprivate func reloadLastGame() {
            print(#fileID, #function, #line, "- <# 주석 #>")
        
        
        if let savedScores = UserDefaults.standard.object(forKey: "SavedLastScores") as? Data {
            if let decodedScores = try? JSONDecoder().decode(GameScores.self, from: savedScores) {
                self.playerOneName = decodedScores.playerOneName
                self.playerTwoName = decodedScores.playerTwoName
                self.playerOneScore = decodedScores.playerOneScore
                self.playerTwoScore = decodedScores.playerTwoScore
                self.playerOneSetScore = decodedScores.playerOneSetScore
                self.playerTwoSetScore =
                decodedScores.playerTwoSetScore
                self.allScore = decodedScores.totalScore
                self.isUserOneServing = decodedScores.servingPlayerOne
                
                print(#fileID, #function, #line, "- playerOneScore: \(playerOneScore), allScore: \(allScore)")
                
                canSave = true
            }
            
        }
    }
    
    
    
}


struct ScoreBoard_Previews: PreviewProvider {
    // Declare a @State variable for the preview

    static var previews: some View {
        // Use the state variable as a binding
        ScoreBoard(playerOneName: .constant("Player 1"), playerTwoName: .constant("Player 2"), serviceRight: .constant(true), loadLastGame: .constant(false), isUserOneServing: true)
            

    }
}



#Preview {
    ScoreBoard(playerOneName: .constant("Player 1"), playerTwoName: .constant("Player 2"), serviceRight: .constant(true), loadLastGame: .constant(false), isUserOneServing: true)
        .previewInterfaceOrientation(.landscapeLeft)

}


