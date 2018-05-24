import Foundation
import GoogleMobileAds


class AdMob: NSObject, GADBannerViewDelegate {
	static var banner: GADBannerView!
	static var size = CGSize()
	static var showing = false
	static var created = false
	
	override init() {
		super.init()
		GADMobileAds.configure(withApplicationID: appID)
	}
	
	/// Returns ID, make sure testMode is false to get live ads
	private var unitID: String {
		return Ads.testMode ? "ca-app-pub-3940256099942544/2934735716" : "LIVE"
	}
	
	/// Returns App ID, make sure testMode is false to get live ID
	private var appID: String {
		return Ads.testMode ? "ca-app-pub-3940256099942544~1458002511" : "LIVE"
	}
	
	/// Create banner
	func create() {
		AdMob.created = true
		AdMob.banner = GADBannerView(adSize: UIDevice.current.orientation.isLandscape ? kGADAdSizeSmartBannerLandscape : kGADAdSizeSmartBannerPortrait)
		AdMob.banner.tag = 5001
		AdMob.banner.delegate = self
		UIApplication.shared.delegate?.window??.rootViewController?.view.addSubview(AdMob.banner)
		AdMob.banner.adUnitID = unitID
		AdMob.banner.rootViewController = UIApplication.shared.delegate?.window??.rootViewController
		AdMob.banner.load(GADRequest())
	}
	
	/// Delegate function
	func adViewDidReceiveAd(_ bannerView: GADBannerView) {
		print("adMob: Received")
		AdMob.showing = true
		AdMob.size = bannerView.frame.size
		AdMob.banner.frame = CGRect.center(x: Screen.width/2, y: Screen.statusBarHeight + (AdMob.size.height/2), width: AdMob.size.width, height: AdMob.size.height)
		
		if let topBanner = UIApplication.shared.delegate?.window??.rootViewController?.view.viewWithTag(5000) {
			topBanner.removeFromSuperview()
			TopBanner.removed()
		}
		if BannerWall.showing { BannerWall.resize() }
	}
	
	/// Delegate function
	func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
		print("adMob: Failed")
		AdMob.showing = false
		AdMob.size.height = 0
		AdMob.banner.frame = CGRect(x: 0, y: -bannerView.frame.size.height, width: bannerView.frame.size.width, height: bannerView.frame.size.height)
		
		if let mb = UserDefaults.standard.dictionary(forKey: "MyBanners") { // creates top banner
			if !TopBanner.created && mb.count > 0 && Banners.count > 0 {
				_ = TopBanner()
			}
		}
	}
	
	/// Banner was removed
	static func removed() {
		AdMob.banner.delegate = nil
		AdMob.showing = false
		AdMob.size.height = 0.0
		AdMob.size.width = 0.0
	}
	
}













