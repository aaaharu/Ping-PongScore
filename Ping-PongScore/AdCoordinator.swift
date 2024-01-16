
import SwiftUI
import GoogleMobileAds

class AdCoordinator: NSObject, GADFullScreenContentDelegate {
  private var ad: GADInterstitialAd?

  func loadAd() {
    GADInterstitialAd.load(
      withAdUnitID: "ca-app-pub-3940256099942544/4411468910", request: GADRequest()
    ) { ad, error in
      if let error = error {
        return print("Failed to load ad with error: \(error.localizedDescription)")
      }

      self.ad = ad
        self.ad?.fullScreenContentDelegate = self

        print(#fileID, #function, #line, "- 광고가 준비되었습니다. ad: \(String(describing: self.ad))")
    }
  }

  func presentAd(from viewController: UIViewController) {
    guard let fullScreenAd = ad else {
      return print("Ad wasn't ready")
    }

    fullScreenAd.present(fromRootViewController: viewController)
          print(#fileID, #function, #line, "- 광고를 틀었습니다.")
  }
    
    // MARK: - 광고 이벤트 GADFullScreenContentDelegate methods

      func adDidRecordImpression(_ ad: GADFullScreenPresentingAd) {
        print("\(#function) called")
      }

      func adDidRecordClick(_ ad: GADFullScreenPresentingAd) {
        print("\(#function) called")
      }

      func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
          print("\(#function) called. 오류: \(error.localizedDescription)")
      }

      func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("\(#function) called")
      }


      func adWillDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("\(#function) called")
          
          // 다음 화면을 준비하세요.
          NotificationCenter.default.post(name: .movoToScoreRecord, object: nil)
      }

      func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("\(#function) called")
        
      }
    
}

struct AdViewControllerRepresentable: UIViewControllerRepresentable {
  let viewController = UIViewController()

  func makeUIViewController(context: Context) -> some UIViewController {
    return viewController
  }

  func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
    // No implementation needed. Nothing to update.
  }
}
