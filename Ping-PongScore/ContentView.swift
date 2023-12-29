//
//  ContentView.swift
//  Ping-PongScore
//
//  Created by 김은지 on 12/29/23.
//

import SwiftUI

struct ContentView: View {
    
    
    @State var userOneText = 0
    @State var userTwoText = 0
    
    var body: some View {
        
        VStack {
            
            ZStack {
                // 첫번째 유저 사각형
                Rectangle()
                    .frame(width: 130, height: 130)
                    .foregroundColor(.red)
                    .offset(x: -80, y: -160)
                    .onTapGesture {
                        userOneScore()
                    }
                Text("\(userOneText)")
                    .foregroundStyle(.yellow)
                    .bold()
                    .font(.largeTitle)
                    .offset(x: -80, y: -160)
                
                
                Rectangle()
                    .frame(width: 130, height: 130)
                    .foregroundColor(.red)
                    .offset(x: 80, y: -160)
                    .onTapGesture {
                        userTwoScore()
                    }
                
                Text("\(userTwoText)")
                    .foregroundStyle(.yellow)
                    .bold()
                    .font(.largeTitle)
                    .offset(x: 80, y: -160)
            }
            
            
        }
        
        
        
        .padding()
        
        
    }
    
    fileprivate func userOneScore() {
        print(#fileID, #function, #line, "- <# 주석 #>")
        userOneText += 1
    }
    
    fileprivate func userTwoScore() {
        print(#fileID, #function, #line, "- <# 주석 #>")
        userTwoText += 1
    }
    
    
}

#Preview {
    ContentView()
}


