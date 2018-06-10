import UIKit

class TopBanner: NSObject {
	
	static var created = false
	static var showing = false
	static var height: CGFloat = 0.0
	private lazy var bannerID: UInt32 = 0
	private lazy var appStore = AppStore()
	static var timer = Timer()
	
	override init() {
		super.init()
		let size = UIScreen.main.traitCollection.userInterfaceIdiom == .pad ? CGSize(width: 728, height: 90) : CGSize(width: 320, height: 50)
		let banner = UIButton(frame: CGRect(x: 0, y: -size.height, width: size.width, height: size.height))
		TopBanner.created = true
		banner.tag = 5000
		banner.addTarget(self, action: #selector(self.tapped), for: .touchUpInside)
		UIApplication.shared.delegate?.window??.rootViewController?.view.addSubview(banner)
		if setImage() { TopBanner.timer = Timer.scheduledTimer(timeInterval: 60.0, target: self, selector: #selector(setImage), userInfo: nil, repeats: true) }
		show()
	}
	
	/// Show in-house banner
	func show() {
		if let banner = UIApplication.shared.delegate?.window??.rootViewController?.view.viewWithTag(5000) {
			TopBanner.showing = true
			TopBanner.height = banner.frame.size.height
			banner.frame = CGRect.center(x: Screen.width/2, y: banner.frame.size.height/2 + Screen.statusBarHeight, width: banner.frame.size.width, height: banner.frame.size.height)
			if BannerWall.showing { BannerWall.resize() }
		}
	}
	
	/// Hide in-house banner
	func hide() {
		if let banner = UIApplication.shared.delegate?.window??.rootViewController?.view.viewWithTag(5000) {
			banner.frame = CGRect.center( x: Screen.width/2, y: -banner.frame.size.height, width: banner.frame.size.width, height: banner.frame.size.height)
			TopBanner.showing = false
			TopBanner.height = 0
		}
	}
	
	/// Chooses a random image, verifies it, sets image and ID
	@objc func setImage() -> Bool {
		let mb = UserDefaults.standard.dictionary(forKey: "MyBanners")!
		guard let doc = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) else {	 return false }
		// get random banner and ID
		var found = false
		for _ in mb { // randomly sets banner
			let index = Int(arc4random_uniform(UInt32(mb.count)))
			let name = Array(mb.keys)[index]
			let id = Array(mb.values)[index] as! NSString
			if id.contains(String(bannerID)) { continue } // same banner that was showing
			// make sure banner exists, sets image and ID
			if FileManager().fileExists(atPath: doc.appendingPathComponent(name).path) {
				let banner = UIApplication.shared.delegate?.window??.rootViewController?.view.viewWithTag(5000) as! UIButton
				banner.setBackgroundImage(UIImage(contentsOfFile: URL(fileURLWithPath: doc.absoluteString).appendingPathComponent(name).path), for: .normal)
				bannerID = UInt32(id as String)!
				found = true
				break
			}
		}
		// if nothing is found randomly, use brute force to find a banner, this is just a safety check, should be unnecessary.
		if !found {
			for (app, ids) in mb {
				if FileManager().fileExists(atPath: doc.appendingPathComponent(app).path) {
					// set banner
					let banner = UIApplication.shared.delegate?.window??.rootViewController?.view.viewWithTag(5000) as! UIButton
					banner.setBackgroundImage(UIImage(contentsOfFile: URL(fileURLWithPath: (doc.absoluteString)).appendingPathComponent(app).path), for: .normal)
					// set ID
					var id = ids as! NSString
					if id.contains("_") { // could be iPhone or iPad
						let t = id.components(separatedBy: "_")
						id = UIScreen.main.traitCollection.userInterfaceIdiom == .phone ? t[0] as NSString : t[1] as NSString
					}
					bannerID = UInt32(id as String)!
					break
				}
			}
		}
		return true
	}
	
	/// Opens app store
	@objc func tapped(sender: UIButton) {
		appStore.open(bannerID)
	}
	
	/// Removes top banner
	static func removed() {
		timer.invalidate() // stops setImage from being called, and allows banner to be removed from memory, the timer keeps the object around so the action method (tapped) can be called
		TopBanner.created = false
		TopBanner.showing = false
		TopBanner.height = 0
	}
	
}






