import SwiftUI

struct ScoreRecord: View {
    @ObservedObject var viewModel = ScoreBoardVM()
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all) // 전체 뷰의 배경색을 검은색으로 설정

            List {
                ForEach(Array(viewModel.scores.enumerated()), id: \.1.id) { (index, score) in
                    HStack {
                        Text("\(index + 1)").foregroundColor(.white)
                        Spacer()
                        Text("\(score.winnerName)").foregroundColor(.white)
                       Spacer()
                        Text("\(score.player)").foregroundColor(.white)
                        Spacer()
                        Text("\(score.winnerScore)").foregroundColor(.white)
                        Spacer()
                        Text("\(score.playerScore)").foregroundColor(.white)
                        Spacer()
                        Text("\(score.date, formatter: dateFormatter)").foregroundColor(.white)

                    }
                    .listRowBackground(Color.black) // 각 행의 배경색을 검은색으로 설정
                }
            }
            .listStyle(PlainListStyle()) // 리스트 스타일을 평면 스타일로 설정
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
