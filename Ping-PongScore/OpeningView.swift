//
//  OpeningView.swift
//  Ping-PongScore
//
//  Created by 김은지 on 1/2/24.
//

import SwiftUI
import UIKit

struct OpeningView: View {
    
    @State private var moveToNewGame = false
    @State private var moveToLastGame = false
    @State private var moveToScoreRecord = false
    
    var body: some View {
        
        let blackRectangle = Rectangle()
            .frame(width: UIScreen.main.bounds.width * 0.17, height:  UIScreen.main.bounds.height * 0.40)
            .foregroundStyle(Color(red: 0/255, green: 0/255, blue: 0/255))
            .clipShape(
                .rect(
                    topLeadingRadius: 40,
                    bottomLeadingRadius: 0,
                    bottomTrailingRadius: 0,
                    topTrailingRadius: 40
                )
            )
        NavigationStack {
          
            ZStack {
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
                
                Rectangle()
                    .frame(width: UIScreen.main.bounds.width * 0.88, height:  6)
                    .foregroundStyle(.white)
                
                HStack(spacing: 27) {
                    VStack(spacing: 0) {
                        
                        ZStack {
                            // 빨간판
                            Rectangle()
                                .frame(width: UIScreen.main.bounds.width * 0.17, height:  UIScreen.main.bounds.height * 0.40)
                                .foregroundStyle(Color(red: 240/255, green: 54/255, blue: 42/255))
                                .clipShape(
                                    .rect(
                                        topLeadingRadius: 40,
                                        bottomLeadingRadius: 0,
                                        bottomTrailingRadius: 0,
                                        topTrailingRadius: 40
                                    )
                                )
                            Button("Last \nGame") {
                                moveToLastGame = true
                            }    .frame(width: UIScreen.main.bounds.width * 0.17, height: UIScreen.main.bounds.height * 0.40)
                                .contentShape(Rectangle())
                                .backgroundStyle(.clear)
                                .padding(0)
                                .layoutPriority(1)
                                .font(.custom("DungGeunMo", size: 40))
                                .navigationDestination(isPresented: $moveToLastGame, destination: {
                                    LastGame()
                                }).navigationBarBackButtonHidden()
                        }
                        // 빨간판 밑
                        Rectangle()
                            .frame(width: UIScreen.main.bounds.width * 0.17, height:  UIScreen.main.bounds.height * 0.1)
                        
                            .foregroundStyle(Color(red: 211/255, green: 165/255, blue: 140/255))
                            .clipShape(
                                .rect(
                                    topLeadingRadius: -40,
                                    bottomLeadingRadius: 50,
                                    bottomTrailingRadius: 50,
                                    topTrailingRadius: -40
                                )
                            )
                        // 탁구 막대바
                        Rectangle()
                            .frame(width: UIScreen.main.bounds.width * 0.05, height:  UIScreen.main.bounds.height * 0.15)
                        
                            .foregroundStyle(Color(red: 166/255, green: 127/255, blue: 106/255))
                    }
                    
                    
                    
                    VStack(spacing: 0) {
                        
                        ZStack() {
                            // 검은판
                            blackRectangle
                            Button(action: {
                                moveToNewGame = true
                            }) {
                                Text("New \nGame")
                                    .font(.custom("DungGeunMo", size: 40))
                                    .foregroundStyle(.yellow)
                            }
                            .tint(.purple)
                            .padding(0)
                            .buttonStyle(.borderedProminent)
                            .contentShape(Rectangle()) // 전체 영역이 클릭 가능하도록
                            .navigationDestination(isPresented: $moveToNewGame, destination: {
                                NewGame()
                            })
                        }
                        
                        
                        // 빨간판 밑
                        Rectangle()
                            .frame(width: UIScreen.main.bounds.width * 0.17, height:  UIScreen.main.bounds.height * 0.1)
                        
                            .foregroundStyle(Color(red: 211/255, green: 165/255, blue: 140/255))
                            .clipShape(
                                .rect(
                                    topLeadingRadius: -40,
                                    bottomLeadingRadius: 50,
                                    bottomTrailingRadius: 50,
                                    topTrailingRadius: -40
                                )
                            )
                        // 탁구 막대바
                        Rectangle()
                            .frame(width: UIScreen.main.bounds.width * 0.05, height:  UIScreen.main.bounds.height * 0.15)
                        
                            .foregroundStyle(Color(red: 166/255, green: 127/255, blue: 106/255))
                    }
                    
                    VStack(spacing: 0) {
                        
                        ZStack {
                            // 빨간판
                            Rectangle()
                                .frame(width: UIScreen.main.bounds.width * 0.17, height:  UIScreen.main.bounds.height * 0.40)
                                .foregroundStyle(Color(red: 240/255, green: 54/255, blue: 42/255))
                                .clipShape(
                                    .rect(
                                        topLeadingRadius: 40,
                                        bottomLeadingRadius: 0,
                                        bottomTrailingRadius: 0,
                                        topTrailingRadius: 40
                                    )
                                )
                            Button("Score \nRecord") {
                                moveToScoreRecord = true
                            }    .frame(width: UIScreen.main.bounds.width * 0.17, height: UIScreen.main.bounds.height * 0.40)
                                .contentShape(Rectangle())
                                .backgroundStyle(.clear)
                                .padding(0)
                                .layoutPriority(1)
                                .font(.custom("DungGeunMo", size: 40))
                                .navigationDestination(isPresented: $moveToScoreRecord, destination: {
                                    ScoreRecord()
                                }).navigationBarBackButtonHidden()
                        }
                        // 빨간판 밑
                        Rectangle()
                            .frame(width: UIScreen.main.bounds.width * 0.17, height:  UIScreen.main.bounds.height * 0.1)
                        
                            .foregroundStyle(Color(red: 211/255, green: 165/255, blue: 140/255))
                            .clipShape(
                                .rect(
                                    topLeadingRadius: -40,
                                    bottomLeadingRadius: 50,
                                    bottomTrailingRadius: 50,
                                    topTrailingRadius: -40
                                )
                            )
                        // 탁구 막대바
                        Rectangle()
                            .frame(width: UIScreen.main.bounds.width * 0.05, height:  UIScreen.main.bounds.height * 0.15)
                        
                            .foregroundStyle(Color(red: 166/255, green: 127/255, blue: 106/255))
                    }
                    
                    
                    
                    
                    
                    
                    
                }
                
            }
            
        }
    }
}


#Preview {
    OpeningView()
}
