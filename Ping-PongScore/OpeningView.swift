//
//  OpeningView.swift
//  Ping-PongScore
//
//  Created by 김은지 on 1/2/24.
//

import SwiftUI

struct OpeningView: View {
    
@State private var moveToScoreBoard = false
@State private var moveToLoadRecentGame = false
    
    var body: some View {
        
        NavigationStack {
            
            VStack {
                Button("새 경기 시작하기") {
                    moveToScoreBoard = true
                }.foregroundStyle(.blue)
                    .buttonStyle(.bordered)
            }
            
            .navigationDestination(isPresented: $moveToScoreBoard, destination: {
                ScoreBoard()
            })
           
            
            Button("최근 경기로 돌아가기") {
                moveToLoadRecentGame = true
            }.foregroundStyle(.blue)
                .buttonStyle(.bordered)
            
                .navigationDestination(isPresented: $moveToLoadRecentGame, destination: {
                    LoadRecentGame()
                })
            
            Button("경기 기록") {
                moveToLoadRecentGame = true
            }.foregroundStyle(.blue)
                .buttonStyle(.bordered)
            
                .navigationDestination(isPresented: $moveToLoadRecentGame, destination: {
                    LoadRecentGame()
                })
            
            
            
            
            
            .navigationBarTitle("")
            
        }
        
        
    }
}


#Preview {
    OpeningView()
}
