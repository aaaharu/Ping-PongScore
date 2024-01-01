//
//  ContentView.swift
//  Ping-PongScore
//
//  Created by 김은지 on 12/29/23.
//

import SwiftUI

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



struct ContentView: View {
    
    
    @State private var userOneText = 0 {
        didSet {
            winScore()
        }
    }
    @State private var userTwoText = 0 {
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
        }
    }
    
    @State private var isUserOneServing = true  // 플레이어 원이 서브권을 가질 때
    @State private var setScoreUserOne = 0
    @State private var setScoreUserTwo = 0
    @State private var deuce = false
    @State private var gameOver = false
    
    
    var body: some View {
        
        VStack {
            
            ZStack {
                // 첫번째 유저 큰 점수판
                Rectangle()
                    .clipShape(
                        .rect(
                            topLeadingRadius: 10,
                            bottomLeadingRadius: 10,
                            bottomTrailingRadius: 10,
                            topTrailingRadius: 10
                        )
                    )
                    .frame(width: 180, height: 250)
                    .foregroundColor(.red)
                    .offset(x: -250, y: 80)
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
                Text("\(userOneText)")
                    .foregroundStyle(.yellow)
                    .bold()
                    .font(.largeTitle)
                    .offset(x: -250, y: 80)
                // 서브권
                Rectangle()
                    .frame(width: 160, height: 10)
                    .offset(x: -250, y: 190)
                    .foregroundColor(isUserOneServing ? .indigo : .clear)
                // 세트 스코어
                Rectangle()
                    .frame(width:70, height: 90)
                    .foregroundColor(.red)
                    .offset(x: -110, y: 160)
                Text("\(setScoreUserOne)")
                    .foregroundStyle(.yellow)
                    .bold()
                    .font(.largeTitle)
                    .offset(x: -110, y: 160)
                
                
                
                // 두번쨰 유저 큰 점수판
                Rectangle()
                    .clipShape(
                        .rect(
                            topLeadingRadius: 10,
                            bottomLeadingRadius: 10,
                            bottomTrailingRadius: 10,
                            topTrailingRadius: 10
                        )
                    )
                    .frame(width: 180, height: 250)
                    .foregroundColor(.red)
                    .offset(x: 250, y: 80)
                    .rotation3DEffect(Angle(degrees: flipDegreesUserTwo), axis: (x: 1, y: 0, z: 0), perspective: flipPersDegreesUserTwo) // 뒤로 넘어가는 효과
                    .onTapGesture {
                        addUserTwoScore()
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
                Rectangle()
                    .frame(width: 160, height: 10)
                    .offset(x: 250, y: 190)
                    .foregroundColor(isUserOneServing ? .clear : .indigo)
                
                Text("\(userTwoText)")
                    .foregroundStyle(.yellow)
                    .bold()
                    .font(.largeTitle)
                    .offset(x: 250, y: 80)
            }
            
            // 세트 스코어
            Rectangle()
                .frame(width:70, height: 90)
                .foregroundColor(.red)
                .offset(x: 110, y: -30)
            Text("\(setScoreUserTwo)")
                .foregroundStyle(.yellow)
                .bold()
                .font(.largeTitle)
                .offset(x: 110, y: -190)
            
        }
        .padding()
        .background(LandscapeOnlyViewControllerWrapper())
        
    }
    
    fileprivate func addUserOneScore() {
        allScore += 1
        userOneText += 1

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
        userTwoText += 1

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
        
        if userOneText <= 0 {
            return
        }
        
        allScore -= 1
        userOneText -= 1

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
        
        if userTwoText <= 0 {
            return
        }
        
        allScore -= 1
        userTwoText -= 1

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
            if abs(userOneText - userTwoText) == 2 {
                gameOver = true
                // Deuce resolution
                if userOneText > userTwoText {
                    setScoreUserOne += 1
                    print(#fileID, #function, #line, "- 듀스에서 userOne이 이겼습니다.")
                } else {
                    setScoreUserTwo += 1
                    print(#fileID, #function, #line, "- 듀스에서 userTwo가 이겼습니다.")
                }
                resetGame()
            }
        } else {
            // Normal play
            if (userOneText >= 11 || userTwoText >= 11) && abs(userOneText - userTwoText) >= 2 {
                gameOver = true
                if userOneText > userTwoText {
                    setScoreUserOne += 1
                    print(#fileID, #function, #line, "- userOne이 이겼습니다!")
                } else {
                    setScoreUserTwo += 1
                    print(#fileID, #function, #line, "- userTwo가 이겼습니다.")
                }
                resetGame()
            } else if userOneText == 10 && userTwoText == 10 {
                // 듀스입니다!
                deuce = true
                print(#fileID, #function, #line, "- 듀스입니다.")
            }
        }
    }
    
    fileprivate func resetGame() {
        userOneText = 0
        userTwoText = 0
        allScore = 0
        deuce = false
        gameOver = false
    }

    
    
}



// 화면이 안 꺼지게 하기 앱이 Foreground에 있을 떄
// 서브 권이 맨 처음 언제인지 표시하기!

#Preview {
    ContentView()
}


