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
    
    
    @State private var userOneText = 0
    @State private var userTwoText = 0
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
                    .offset(x: -250, y: 0)
                    .rotation3DEffect(Angle(degrees: flipDegreesUserOne), axis: (x: 1, y: 0, z: 0), perspective: flipPersDegreesUserOne) // 뒤로 넘어가는 효과
                    .onTapGesture {
                        
                        AddUserOneScore()
                    }
                    .gesture(DragGesture(minimumDistance: 20, coordinateSpace: .local)
                                        .onEnded({ value in
                                            if value.translation.width < 0 {
                                                // left
                                            }

                                            if value.translation.width > 0 {
                                                // right
                                            }
                                            if value.translation.height < 0 {
                                             AddUserOneScore()
                                            }

                                            if value.translation.height > 0 {
                                                // down
                                                subtractUserOneScore()
                                            }
                                        }))
                Text("\(userOneText)")
                    .foregroundStyle(.yellow)
                    .bold()
                    .font(.largeTitle)
                    .offset(x: -250, y: 0)
                // 서브권
                Rectangle()
                    .frame(width: 160, height: 10)
                    .offset(x: -250, y: 110)
                    .foregroundColor(isUserOneServing ? .indigo : .clear)
                
                
                
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
                    .offset(x: 250, y: 0)
                    .rotation3DEffect(Angle(degrees: flipDegreesUserTwo), axis: (x: 1, y: 0, z: 0), perspective: flipPersDegreesUserTwo) // 뒤로 넘어가는 효과
                    .onTapGesture {
                        AddUserTwoScore()
                    }
                    .gesture(DragGesture(minimumDistance: 20, coordinateSpace: .local)
                                        .onEnded({ value in
                                            if value.translation.width < 0 {
                                                // left
                                            }

                                            if value.translation.width > 0 {
                                                // right
                                            }
                                            if value.translation.height < 0 {
                                            AddUserTwoScore()
                                            }

                                            if value.translation.height > 0 {
                                               subtractUserTwoScore()
                                            }
                                        }))
                // 서브권
                Rectangle()
                    .frame(width: 160, height: 10)
                    .offset(x: 250, y: 110)
                    .foregroundColor(isUserOneServing ? .clear : .indigo)
                
                Text("\(userTwoText)")
                    .foregroundStyle(.yellow)
                    .bold()
                    .font(.largeTitle)
                    .offset(x: 250, y: 0)
            }
            
            
        }
        
        
        
        .padding()
        .background(LandscapeOnlyViewControllerWrapper())
        
    }
    
    fileprivate func AddUserOneScore() {
        print(#fileID, #function, #line, "- <# 주석 #>")
        withAnimation(.easeInOut(duration: 0.5)) {
            allScore += 1
            userOneText += 1
            flipDegreesUserOne += 180
            flipPersDegreesUserOne = 0.5
        }
    }
    
    
    fileprivate func AddUserTwoScore() {
        print(#fileID, #function, #line, "- <# 주석 #>")
        withAnimation(.easeInOut(duration: 0.5)) {
            allScore += 1
            userTwoText += 1
            flipDegreesUserTwo += 180
            flipPersDegreesUserTwo = 0.5
        }
    }
    
    fileprivate func subtractUserOneScore() {
        print(#fileID, #function, #line, "- <# 주석 #>")
        
        if userOneText <= 0 {
            return
        }
        
        withAnimation(.easeInOut(duration: 0.5)) {
            allScore -= 1
            userOneText -= 1
            flipDegreesUserOne -= 180
            flipPersDegreesUserOne = -0.5
        }
    }
    
    fileprivate func subtractUserTwoScore() {
        print(#fileID, #function, #line, "- <# 주석 #>")
        
        if userTwoText <= 0 {
            return
        }
        
        withAnimation(.easeInOut(duration: 0.5)) {
            allScore -= 1
            userTwoText -= 1
            flipDegreesUserTwo -= 180
            flipPersDegreesUserTwo = -0.5
        }
    }
    
    fileprivate func updateServing() {
        if allScore % 4 == 0 {
            isUserOneServing.toggle()
        }
    }
    
    
}

#Preview {
    ContentView()
}


