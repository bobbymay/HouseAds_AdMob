import UIKit

class BannerWall: UIViewController {
	static var banners = [String]()
	static var showing = false
	static var verified = false
	private lazy var appStore = AppStore()
	
	convenience init() {
		self.init(nibName:nil, bundle:nil)
		self.view.backgroundColor = UIColor.black
		self.view.tag = 8000
	}
	
	/// Find banners in documents, save names to array. Shuffles on subsequent calls
	static func setBanners() {
		guard let doc = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) else {	 return }
		if !verified { // check to see if all the banners in the user defaults are already stored in appNames array
			if !BannerWall.banners.isEmpty { BannerWall.banners.removeAll() }
			let mb = UserDefaults.standard.dictionary(forKey: "MyBanners")!
			verified = true
			for e in mb.keys {
				if FileManager().fileExists(atPath: doc.appendingPathComponent(e).path) {
					BannerWall.banners.append(e)
				}
			}
		}
		BannerWall.banners.shuffle() // shuffle banners positions within the array so there in a different order every time its displayed
	}
	
	/// Shows banner wall
	func show() {
		BannerWall.setBanners()
		BannerWall.showing = true
		let topPadding: CGFloat = UIScreen.main.traitCollection.userInterfaceIdiom == .phone ? 28.0 : 47.0
		let width: CGFloat = UIScreen.main.traitCollection.userInterfaceIdiom == .phone ? 320.0 : 728.0
		let topBannerHeight = TopBanner.height + AdMob.size.height
		self.view.frame = CGRect(x: -Screen.width, y: topBannerHeight + Screen.statusBarHeight, width: width, height: Screen.height - (topBannerHeight + Screen.statusBarHeight))
		// _______ Prevents tapping through view _______
		let bg = UIButton(frame: CGRect(x: 0, y: 0, width: width, height: topPadding))
		self.view.addSubview(bg)
		bg.backgroundColor = UIColor.black
		// _______ Remove ads button _______
		let bSize: CGRect
		if UIScreen.main.traitCollection.userInterfaceIdiom == .phone {
			bSize = CGRect.center(x: width * 0.098, y: topPadding/2, width: width * 0.17, height: topPadding * 0.68)
		} else {
			bSize = CGRect.center(x: width * 0.085, y: topPadding/2, width: width * 0.124, height: topPadding * 0.64)
		}
		if !Ads.removed {
			let button = UIButton(frame: bSize)
			button.tag = 8001
			button.addTarget(self, action: #selector(self.removeAds), for: .touchUpInside)
			self.view.addSubview(button)
			button.backgroundColor = UIColor.black
			button.layer.cornerRadius = UIScreen.main.traitCollection.userInterfaceIdiom == .phone ? 2.3 : 2.3
			button.layer.borderWidth = UIScreen.main.traitCollection.userInterfaceIdiom == .phone ? 0.55 : 0.9
			button.layer.borderColor = UIColor.white.cgColor
			button.setTitle("Remove Ads", for: .normal)
			button.titleLabel?.adjustsFontSizeToFitWidth = true
			button.titleLabel?.font = UIFont(name: UIScreen.main.traitCollection.userInterfaceIdiom == .phone ? "KohinoorDevanagari-Medium" : "KohinoorBangla-Semibold", size: UIScreen.main.traitCollection.userInterfaceIdiom == .phone ? 7 : 10.5)
			button.setTitleColor(UIColor.lightGray, for: .highlighted)
			button.setTitleColor(UIColor.white, for: .normal)
		}
		// _______ Free apps label _______
		let labelWidth = width/2 - (bSize.origin.x + bSize.size.width)
		let label = UILabel(frame: CGRect(x: bSize.origin.x + bSize.size.width, y: 0, width: labelWidth * 2, height: topPadding))
		label.textAlignment = .center
		label.text = "Free Apps"
		label.font = UIFont(name: "Avenir-Medium", size: UIScreen.main.traitCollection.userInterfaceIdiom == .phone ? 15 : 21)
		label.textColor = UIColor.white
		label.adjustsFontSizeToFitWidth = true
		self.view.addSubview(label)
		// _______ X button _______
		let xButton = UIButton(frame: CGRect(x: width - topPadding * 1.1, y: 0, width: topPadding, height: topPadding))
		xButton.addTarget(self, action: #selector(self.dismissTable), for: .touchUpInside)
		xButton.setBackgroundImage(UIImage(named:"ads_X.png"), for: .normal)
		self.view.addSubview(xButton)
		// _______ Create table view _______
		let tv = UITableView(frame: CGRect(x: 0, y: topPadding, width: self.view.frame.size.width, height: self.view.frame.size.height - topPadding))
		tv.backgroundColor = UIColor.black
		tv.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
		tv.dataSource = self
		tv.delegate = self
		tv.rowHeight = Device.type == .phone ? 50 : 90
		tv.tag = 7000
		self.view.addSubview(tv)
		UIApplication.shared.delegate?.window??.rootViewController?.view.addSubview(self.view)
		// _______ Slide table left to right changing alpha, scroll banners upwards
		tv.scrollToRow(at: IndexPath.init(row: Int((Float(BannerWall.banners.count) * 0.27).rounded()), section: 0), at: .top, animated: false)
		self.view.alpha = 0
		UIView.animate(withDuration: 1, animations: {
			self.view.alpha = 1
			self.view.frame = CGRect.center(x: Screen.width/2, y: Screen.height/2 + topBannerHeight/2 + Screen.statusBarHeight/2, width: self.view.frame.size.width, height: self.view.frame.size.height)
		}, completion: { finished in
			UIView.animate(withDuration: 1, animations: {
				tv.scrollToRow(at: IndexPath.init(row: 0, section: 0), at: .top, animated: false)
			})
		})
	}
	
	/// Resizes tableview with ad banners
	static func resize() {
		if let tableVC = UIApplication.shared.delegate?.window??.rootViewController?.view.viewWithTag(8000) {
			let topBannerHeight = TopBanner.height + AdMob.size.height + Screen.statusBarHeight
			let width: CGFloat = UIScreen.main.traitCollection.userInterfaceIdiom == .phone ? 320.0 : 728.0
			tableVC.frame = CGRect.center(x: Screen.width/2, y: Screen.height/2 + topBannerHeight/2, width: width, height: Screen.height - topBannerHeight)
			// resize table
			let topPadding: CGFloat = UIScreen.main.traitCollection.userInterfaceIdiom == .phone ? 28.0 : 47.0
			let tableView = UIApplication.shared.delegate?.window??.rootViewController?.view.viewWithTag(7000)
			tableView?.frame = CGRect( x: 0, y: topPadding, width: tableVC.frame.size.width, height: tableVC.frame.size.height - topPadding)
		}
	}
	
	/// Slides table off screen
	@objc func dismissTable() {
		UIView.animate(withDuration: 1, animations: {
			self.view.alpha = 0
			self.view.frame = CGRect(x: Screen.width, y: self.view.frame.origin.y, width: self.view.frame.size.width, height: self.view.frame.size.height)
		}, completion: { finished in
			if finished {
				for layer in self.view.subviews {
					layer.removeFromSuperview() // removes views and images to free up memory
				}
				BannerWall.showing = false
			}
		})
	}
	
	/// Get image from documents directory
	func getImage(_ index: Int) -> UIImageView? {
		guard let doc = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) else {	 return nil }
		let iv = UIImageView(image: UIImage(contentsOfFile: URL(fileURLWithPath: doc.absoluteString).appendingPathComponent(BannerWall.banners[index]).path))
		return iv
	}
	
	/// Remove ads button on banner wall
	@objc func removeAds(sender: UIButton) {
		let main = UIApplication.shared.delegate?.window??.rootViewController
		guard let button = main?.view.viewWithTag(8001) else { return }
		guard let tv = main?.view.viewWithTag(8000) else { return }
		if let 	converted = UIApplication.shared.delegate?.window??.rootViewController?.view.convert(button.frame, from: tv) {
			Ads.buy(frame: converted)
		}
	}
	
}

/// Delegate functions
extension BannerWall: UITableViewDelegate, UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return BannerWall.banners.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath as IndexPath)
		cell.selectionStyle = .none
		cell.backgroundColor = UIColor.black
		cell.backgroundView = getImage(indexPath.row)
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		guard let mb = UserDefaults.standard.dictionary(forKey: "MyBanners") else { return }
		guard let idStrings = mb[BannerWall.banners[Int(indexPath.row)]] else { return }
		let id = (idStrings as AnyObject).components(separatedBy: "_")
		if id.count > 1 { // if there are two elements, there is an iphone and ipad version
			Device.type == .phone ? appStore.open(UInt32(id[0])!) : appStore.open(UInt32(id[1])!)
		} else {
			appStore.open(UInt32(id[0])!)
		}
	}
	
}

/// Shuffles the elements in an array
extension Array {
	mutating func shuffle() {
		if self.count >= 5 {
			for _ in self {
				// generate random indexes that will be swapped
				var (a, b) = (Int(arc4random_uniform(UInt32(self.count - 1))), Int(arc4random_uniform(UInt32(self.count - 1))))
				if a == b { // if the same indexes are generated swap the first and last
					a = 0
					b = self.count - 1
				}
				self.swapAt(a, b)
			}
		}
	}
}












