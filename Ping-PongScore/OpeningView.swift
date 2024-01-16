//
//  OpeningView.swift
//  Ping-PongScore
//
//  Created by 김은지 on 1/2/24.
//

import SwiftUI
import UIKit
import AdSupport
import AppTrackingTransparency
import GoogleMobileAds
import GoogleMobileAdsTarget



class TransparentAdModalViewController: UIViewController {
    
    private var hostingController: UIHostingController<AdAlertView>?
    
    init(moveToScoreRecord: Binding<Bool>, moveToPurchaseView: Binding<Bool>) {
        
        
        super.init(nibName: nil, bundle: nil)
        
        let rootView = AdAlertView(dismissAction: { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }, moveToScoreRecord: moveToScoreRecord, moveToPurchaseView: moveToPurchaseView)
        
        hostingController = UIHostingController(rootView: rootView)
        
        setupHostingController()
        
        NotificationCenter.default.addObserver(forName: .dismissAlertView, object: nil, queue: nil) { noti in
            
            self.close()
        }
    }
    
    func close() {
        self.dismiss(animated: true)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupHostingController() {
        guard let hostingView = hostingController?.view else { return }
        view.addSubview(hostingView)
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        
        hostingView.backgroundColor = .clear
        
        NSLayoutConstraint.activate([
            hostingView.topAnchor.constraint(equalTo: view.topAnchor),
            hostingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}


struct AdAlertView: View {
    
    var dismissAction: () -> Void
    @Binding  var moveToScoreRecord: Bool
    @Binding  var moveToPurchaseView: Bool
    
    @State private var isAdLoaded = false
    
    
    var body: some View {
        ZStack {
            
            VStack {
                
                
                StrokeText(text: "Notice", width: 1, color: Color(red: 0/255, green: 0/255, blue: 0/255))
                    .foregroundStyle(Color(red: 255/255, green: 255/255, blue: 255/255))
                    .font(.custom("DungGeunMo", size: 30))
                    .offset(y: UIScreen.main.bounds.height * 0.07)
                
                Button {
                    print(#fileID, #function, #line, "- <# 주석 #>")
                    dismissAction()
                } label: {
                    Image("exit", bundle: .main)
                }.offset(x: UIScreen.main.bounds.width * 0.17, y: UIScreen.main.bounds.height * -0.1)
                
                
                
                Button(action: {
                    moveToPurchaseView = true
                    dismissAction()
                }) {
                    StrokeText(text: "Purchase the App and Continue", width: 1, color: Color(red: 0/255, green: 0/255, blue: 0/255))
                        .foregroundStyle(Color(red: 255/255, green: 255/255, blue: 255/255))
                        .font(.custom("DungGeunMo", size: 25))
                }
                .frame(width: 320, height: 60)
                .background(Color.blue)
                .cornerRadius(10)
                .padding(.bottom, 5)
                .navigationDestination(isPresented: $moveToScoreRecord, destination: {
                    ScoreRecord()
                }).navigationBarBackButtonHidden()
                
                
                Button(action: {
                 
                        
                    NotificationCenter.default.post(name: .dismissAlertView, object: nil)
                    
                    
                    
                    
                }) {
                    StrokeText(text: "Watch Ads and Continue", width: 1, color: Color(red: 0/255, green: 0/255, blue: 0/255))
                        .foregroundStyle(Color(red: 255/255, green: 255/255, blue: 255/255))
                        .font(.custom("DungGeunMo", size: 25))
                }
                
                
                .frame(width: 320, height: 60)
                .background(Color.red)
                .cornerRadius(10)
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
        .onDisappear(perform: {
            // 화면이 꺼질 때 광고를 틀어달라고 노티 보내기
            NotificationCenter.default.post(name: .loadedAd, object: nil)
        })
        
       
        
        
        .backgroundStyle(.clear)
        .frame(width: UIScreen.main.bounds.width * 0.3, height: UIScreen.main.bounds.height * 0.55)
        .offset(x: UIScreen.main.bounds.width * 0, y: UIScreen.main.bounds.height * 0)
        
        
        
    }
    
    //    fileprivate func showAd() {
    //            print(#fileID, #function, #line, "- <# 주석 #>")
    //        // 현재 활성 뷰 컨트롤러를 찾는다
    //        if let windowScene = UIApplication.shared.connectedScenes
    //            .first(where: { $0 is UIWindowScene }) as? UIWindowScene {
    //            if let rootVC = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController {
    //                // 여기에서 rootVC를 사용함.
    //                AdViewController.shared.showAdVC(from: rootVC)
    //            }
    //
    //        }
    //    }
    
}

class OpeningViewModel: ObservableObject {
    @Published var hasPurchased: Bool = false
    
    init() {
        loadPurchaseStatus()
    }
    
    func loadPurchaseStatus() {
        hasPurchased = UserDefaults.standard.bool(forKey: "hasPurchased")
    }
}



struct OpeningView: View {
    
    private let adViewControllerRepresentable = AdViewControllerRepresentable()
    private let adCoordinator = AdCoordinator() // 광고를 로드하고 표시하는 역할

    
    let idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString

    
    @ObservedObject var viewModel = OpeningViewModel()
    
    @State private var restoreLoading = false
    
    @State private var hasPurchased: Bool = false
    @State private var showAdView: Bool = false
    @State private var moveToPurchaseView: Bool = false
    
    @State private var defaultNameOne = ""
    @State private var defaultNameTwo = ""
    
    @State private var defaultScore = 0
    @State private var defaultBool = false
    
    @State private var moveToNewGame = false
    @State private var moveToLastGame = false
    @State private var moveToScoreRecord = false
    
    @State var loadLastGame: Bool
    
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
                
                Button {
                    // 구매복원하는 동안 로딩중 표시하기
                    InAppService.shared.restorePurchase()
                    // 구매복원 후 vm 다시 로드하기
                    viewModel.loadPurchaseStatus()
                    
                } label: {
                    Image("home-white")
                        .resizable()
                        .frame(width: 50, height: 100)
                }
                .offset(x: UIScreen.main.bounds.width * -0.38, y: UIScreen.main.bounds.height * 0.4)
                
                
                // 복원 구매 로딩중
                if restoreLoading {
                    Color.gray.opacity(0.3).ignoresSafeArea()
                        .overlay(alignment: .center, content: {
                            ProgressView()
                        }).zIndex(2)
                    
                    
                }
                
                
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
                            Button(action: {
                                loadLastGame = true
                                moveToLastGame = true
                            }, label: {
                                Text("Last \nGame")
                                    .font(.custom("DungGeunMo", size: 40))
                                    .shadow(color: Color(red: 0/255, green: 0/255, blue: 0/255).opacity(0.25), radius: 2, x: 2, y: 3)
                            })
                            .frame(width: UIScreen.main.bounds.width * 0.17, height: UIScreen.main.bounds.height * 0.40)
                            .contentShape(Rectangle())
                            .foregroundStyle(.black)
                            .backgroundStyle(.clear)
                            .padding(0)
                            .layoutPriority(1)
                            
                            .navigationDestination(isPresented: $moveToLastGame, destination: {
                                ScoreBoard(playerOneName: $defaultNameOne, playerTwoName: $defaultNameTwo, serviceRight: $defaultBool, loadLastGame: $loadLastGame, isUserOneServing: defaultBool)
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
                    .offset(y: UIScreen.main.bounds.height * 0.02)
                    
                    
                    
                    
                    VStack(spacing: 0) {
                        
                        ZStack() {
                            // 검은판
                            blackRectangle
                            Button(action: {
                                moveToNewGame = true
                            }) {
                                Text("New \nGame")
                                    .font(.custom("DungGeunMo", size: 40))
                                    .foregroundStyle(.white
                                    )
                            }
                            .tint(.black)
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
                    .offset(y: UIScreen.main.bounds.height * 0.02)
                    
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
                            Button(action: {
                                
                                if viewModel.hasPurchased {
                                    moveToScoreRecord = true
                                } else {
                                    presentAdAlertView()
                                }
                            }, label: {
                                Text("Score \nRecord")
                                    .font(.custom("DungGeunMo", size: 40))
                                    .shadow(color: Color(red: 0/255, green: 0/255, blue: 0/255).opacity(0.25), radius: 2, x: 2, y: 3)
                            })   .frame(width: UIScreen.main.bounds.width * 0.17, height: UIScreen.main.bounds.height * 0.40)
                                .contentShape(Rectangle())
                                .foregroundStyle(.black)
                                .backgroundStyle(.clear)
                                .padding(0)
                                .layoutPriority(1)
                                .font(.custom("DungGeunMo", size: 40))
                                .navigationDestination(isPresented: $moveToPurchaseView, destination: {
                                    PurchaseView(moveToPurchaseView: $moveToPurchaseView)
                                }).navigationBarBackButtonHidden()
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
                    .offset(y: UIScreen.main.bounds.height * 0.02)
                    
                    
                    
                    
                    
                    
                    
                }
                
                
                
            }
            .onAppear {
                viewModel.loadPurchaseStatus()
                adCoordinator.loadAd() // 광고를 미리 준비하세요.
                print("IDFA: \(idfa)")
            
                
                // 광고를 트세요.
                NotificationCenter.default.addObserver(forName: .loadedAd, object: nil, queue: nil) { noti in
                    adCoordinator.presentAd(from: adViewControllerRepresentable.viewController)
                }
                
                // ScoreRecord 화면을 열어주세요.
                NotificationCenter.default.addObserver(forName: .movoToScoreRecord, object: nil, queue: nil) { noti in
                   moveToScoreRecord = true
                }
    
               
                // ad tracking request auth
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    ATTrackingManager.requestTrackingAuthorization { (status) in
                        
                        
                        
                        switch status {
                            
                            
                            
                        case .authorized:
                            
                            
                            
                            print("authorized")
                            
                            
                            
                        case .denied:
                            
                            
                            
                            print("denied")
                            
                            
                            
                        case .notDetermined:
                            
                            
                            
                            print("notDetermined")
                            
                            
                            
                        case .restricted:
                            
                            
                            
                            print("restricted")
                            
                            
                            
                            
                        @unknown default:
                            fatalError()
                        }
                    }
                    
                    
                    
                }
                
            }
            .onReceive(InAppService.shared.$restoreLoading, perform: { restoreLoading in
                self.restoreLoading = restoreLoading
            })
            
        }
        // 광고vc 뷰 계층에 추가
        .background{
            adViewControllerRepresentable
                    .frame(width: .zero, height: .zero)
        }}
    
    
    fileprivate func presentAdAlertView() {
        
        
        // 새로운 방식으로 윈도우 찾기
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController else {
            return
        }
        
        // TransparentAdModalViewController 초기화
        let viewController = TransparentAdModalViewController(moveToScoreRecord: $moveToScoreRecord, moveToPurchaseView: $moveToPurchaseView)
        
        // TransparentAdModalViewController를 모달로 표시
        rootViewController.present(viewController, animated: true, completion: nil)
        
    }
    
    
    
    
}


#Preview {
    OpeningView(loadLastGame: false)
}
