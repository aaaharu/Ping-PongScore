//
//  ContentView.swift
//  Ping-PongScore
//
//  Created by 김은지 on 12/29/23.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            
            ZStack {
                // 사각형
                Rectangle()
                    .frame(width: 130, height: 130)
                    .foregroundColor(.red)
                    .offset(x: -80, y: -160)
                
                Rectangle()
                    .frame(width: 130, height: 130)
                    .foregroundColor(.red)
                    .offset(x: 80, y: -160)
            }
            
        }
    
        
        
        .padding()
    }
}

#Preview {
    ContentView()
}
