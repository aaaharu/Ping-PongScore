import SwiftUI
import GoogleMobileAds


struct ScoreRecord: View {
    @ObservedObject var viewModel = ScoreBoardVM()
    @State private var moveToHome = false
    
    @State private var defaultLastGameBool: Bool = false

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all) // 전체 뷰의 배경색을 검은색으로 설정
            
            // 홈버튼
            Button(action: {
                moveToHome = true
            }, label: {
                Image("home-white")
                    .resizable()
                    .scaledToFit()
            })
            .frame(width: 50, height: 100)
            .offset(x: UIScreen.main.bounds.width * -0.42, y: UIScreen.main.bounds.height * -0.3)
            .navigationDestination(isPresented: $moveToHome, destination: {
                OpeningView(loadLastGame: defaultLastGameBool)
            }).navigationBarBackButtonHidden(
            
            )
            VStack {
                // New Match
                HStack {
                    Image("trophy")
                    StrokeText(text: "Score Record", width: 1, color: Color(red: 240/255, green: 54/255, blue: 42/255))
                        .foregroundStyle(Color(red: 255/255, green: 199/255, blue: 0/255))
                        .font(.custom("DungGeunMo", size: 40))
                        .offset(y: UIScreen.main.bounds.height * 0)
                }
                .padding(10)
                ZStack {// 리스트 제목
                    HStack {
                        
                        Text("Players").foregroundColor(.white)
                            .font(.custom("DungGeunMo", size: 25))

                        
                    }.padding(.leading, -180)
                    
                    HStack {
                        Text("Score").foregroundColor(.white)
                            .font(.custom("DungGeunMo", size: 25))

                    }.padding(.leading, 130)
                    
                    HStack {
                        Text("Time").foregroundColor(.white)
                            .font(.custom("DungGeunMo", size: 25))

                    }.padding(.leading, 500)
                    
                }.padding(0)
                
                
                // 리스트
                List {
                    ForEach(Array(viewModel.scores.sorted { $0.date > $1.date }.enumerated()), id: \.1.id) { (index, score) in

                        HStack {
                            Text("\(index + 1)").foregroundStyle(.white)
                                .padding(.trailing, 50)
                                .font(.custom("DungGeunMo", size: 35))
                            
                            Text("\(score.winnerName)")
                                .font(.custom("DungGeunMo", size: 30))
                                .foregroundStyle(Color(red: 255/255, green: 199/255, blue: 0/255))
                                .padding(.trailing, 0)
                            
                            Text("\(score.player)").foregroundStyle(.white)
                                .font(.custom("DungGeunMo", size: 30))
                            
                            Spacer()
                            Text("\(score.winnerScore)").foregroundStyle(Color(red: 240/255, green: 54/255, blue: 42/255))
                                .font(.custom("DungGeunMo", size: 40))
                                .padding(.trailing, 0)
                            Text(":").foregroundStyle(.white)
                                .font(.custom("DungGeunMo", size: 40))
                                .padding(.trailing, 0)
                            Text("\(score.playerScore)").foregroundStyle(.white)
                                .font(.custom("DungGeunMo", size: 40))
                            Spacer()
                            
                            Text("\(score.date, formatter: dateFormatter)").foregroundColor(.white)
                                .font(.custom("DungGeunMo", size: 30))

                        }
                        .padding([.leading, .trailing], 10) // 각 행의 패딩 조정
                    }
                    .listRowBackground(Color.black) // 각 행의 배경색을 검은색으로 설정
                }
            }
            .listStyle(PlainListStyle()) // 리스트 스타일을 평면 스타일로 설정
            .offset(y: UIScreen.main.bounds.height * 0.1)
            .padding(0)
        }
    }
    
    // 날짜 포맷팅을 위한 DateFormatter
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "MMM.dd HH:mm"
        return formatter
    }()
}

struct ScoreRecord_Previews: PreviewProvider {
    static var previews: some View {
        ScoreRecord()
    }
}
