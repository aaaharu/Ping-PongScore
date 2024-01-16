import UIKit
import GoogleMobileAds

class AdViewController: UIViewController, GADFullScreenContentDelegate {

    static let shared = AdViewController()
    private var interstitial: GADInterstitialAd?

    func loadAd() {
            print(#fileID, #function, #line, "- <# 주석 #>")
        let request = GADRequest()
        GADInterstitialAd.load(withAdUnitID: "ca-app-pub-3940256099942544/5135589807",
                               request: request,
                               completionHandler: { [weak self] ad, error in
            if let error = error {
                print("Failed to load interstitial ad with error: \(error.localizedDescription)")
                return
            }
            self?.interstitial = ad
            self?.interstitial?.fullScreenContentDelegate = self
           
            // 광고가 로드 되면 화면을 띄운다.
            self?.showAdVC()
        })
        
       
    }



    func showAdVC() {
            print(#fileID, #function, #line, "- <# 주석 #>")
        if let ad = interstitial {
            if let rootVC = getRootViewController() {
                ad.present(fromRootViewController: rootVC)
            }
        } else {
            print("Ad wasn't ready")
            
        }
    }

    private func getRootViewController() -> UIViewController? {
            print(#fileID, #function, #line, "- <# 주석 #>")
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return nil }
        guard let rootViewController = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController else { return nil }
            print(#fileID, #function, #line, "- <# 주석 #>")
        return rootViewController
    }
}
