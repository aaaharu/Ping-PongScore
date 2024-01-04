//
//  NewGame.swift
//  Ping-PongScore
//
//  Created by 김은지 on 1/4/24.
//

import SwiftUI

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
            .foregroundColor(color)
            Text(text)
        }
    }
}

struct NewGame: View {
    
    
    @State private var showYellowOutline = true

    // 서비스 버튼의 위치(왼쪽 서브)
    @State private var offsetX: CGFloat = -0.2
    @State private var offsetY: CGFloat = 0.25

    // 원래 위치
    let originalX: CGFloat = -0.2
    let originalY: CGFloat = 0.25

    // 새로운 위치(오른쪽 서브)
    let newX: CGFloat = 0.1
    let newY: CGFloat = 0.3

    
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
                    .foregroundColor(Color(red: 255/255, green: 199/255, blue: 0/255))
                    .font(.custom("DungGeunMo", size: 40))
                    .offset(y: UIScreen.main.bounds.height * 0.10)
                
                // 서비스 이미지
                Button(action: {
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


                
                
                    // 흰 사각형
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
                     
                        
           

                        
                    

            }
        }
    }
}

#Preview {
    NewGame()
}
