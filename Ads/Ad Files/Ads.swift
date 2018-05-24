import UIKit
import GoogleMobileAds

/// Wrapper to control everything
class Ads: NSObject {
	static var started = false
	static let testMode = true
	static let adMob = AdMob()
	private static let wall = BannerWall()
	private static let purchase = AdsPurchase()
	
	/// Was in-app purchase used to remove ads
	static var removed: Bool {
		return UserDefaults.standard.bool(forKey: "AdsPurchased")
	}
	
	/// Is AdMob or in-house banner showing
	static var showing: Bool {
		if AdMob.showing || TopBanner.showing { return true }
		return false
	}
	
	/// Brings AdMob or in-house banner to the front of the screen
	static func bringToFront() {
		if AdMob.showing, let admob = UIApplication.shared.delegate?.window??.rootViewController?.view.viewWithTag(5001) {
			UIApplication.shared.delegate?.window??.rootViewController?.view.bringSubview(toFront: admob)
		}
		if TopBanner.showing, let topBanner = UIApplication.shared.delegate?.window??.rootViewController?.view.viewWithTag(5000) {
			UIApplication.shared.delegate?.window??.rootViewController?.view.bringSubview(toFront: topBanner)
		}
	}
	
	/// Returns the height of AdMob or in-house banner
	static var height: CGFloat {
		switch true {
		case AdMob.showing: return AdMob.size.height + Screen.statusBarHeight
		case TopBanner.showing: return TopBanner.height + Screen.statusBarHeight
		default: return 0.0
		}
	}
	
	/// Starts everything
	static func start() {
		if !Ads.started {
			started = true
			
			let starts = UserDefaults.standard.integer(forKey: "adStarts") + 1
			UserDefaults.standard.set(starts, forKey: ("adStarts"))
			
			if Internet.available {
				if !Ads.removed { adMob.create() }
				Banners.getFile()
			} else {
				// if there is no Internet, monitor it, when there is a connection getFile() will be called
				Internet().monitorInternet()
				// creates top banner if they exist
				if let mb = UserDefaults.standard.dictionary(forKey: "MyBanners") {
					if !Ads.removed && !TopBanner.created && mb.count > 0 && Banners.count > 0 {
						_ = TopBanner()
					}
				}
			}
		}
		
		// if changing the orientation is not supported, deleted this and change this class to struct
		UIDevice.current.beginGeneratingDeviceOrientationNotifications()
		NotificationCenter.default.addObserver(self,		selector: #selector(Ads.orientationChanged(notification:)), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
	}
	
	/// Shows wall of banners
	static func showWall() {
		if !BannerWall.showing && Banners.count > 0 {
			wall.show()
		}
	}
	
	/// Remove ads
	static func buy(frame: CGRect) {
		purchase.removeAds(id: AdsPurchase.productID, frame: frame)
	}
	
	/// Ads have been purchased to be removed
	static func purchased() {
		UserDefaults.standard.set(true, forKey: "AdsPurchased")
		
		if let admob = UIApplication.shared.delegate?.window??.rootViewController?.view.viewWithTag(5001) {
			admob.removeFromSuperview()
			AdMob.removed()
		}
		
		if let topBanner = UIApplication.shared.delegate?.window??.rootViewController?.view.viewWithTag(5000) {
			topBanner.removeFromSuperview()
			TopBanner.removed()
		}
		
		if let adsRemoveButton = UIApplication.shared.delegate?.window??.rootViewController?.view.viewWithTag(5005) {
			adsRemoveButton.removeFromSuperview()
		}
		
		if let tableRemoveButton = UIApplication.shared.delegate?.window??.rootViewController?.view.viewWithTag(8000)?.viewWithTag(8001) {
			tableRemoveButton.removeFromSuperview()
		}
		
		if BannerWall.showing { BannerWall.resize() }
	}
	
	/// Handles orientation changes (delete if not supported)
	@objc static func orientationChanged(notification: NSNotification) {
		
		if AdMob.showing, let admob = UIApplication.shared.delegate?.window??.rootViewController?.view.viewWithTag(5001) as? GADBannerView {
			admob.adSize = UIDevice.current.orientation.isLandscape ? kGADAdSizeSmartBannerLandscape : kGADAdSizeSmartBannerPortrait
			AdMob.size.height = admob.frame.size.height
		}
		
		if TopBanner.showing, let topBanner = UIApplication.shared.delegate?.window??.rootViewController?.view.viewWithTag(5000) {
			topBanner.frame = CGRect.center(x: Screen.width/2, y: topBanner.frame.size.height/2 + Screen.statusBarHeight, width: topBanner.frame.size.width, height: topBanner.frame.size.height)
		}
		
		if BannerWall.showing { BannerWall.resize() }
	}
	
}















