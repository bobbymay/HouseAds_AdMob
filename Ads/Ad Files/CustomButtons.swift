import UIKit


class RemoveAdsButton: UIButton {
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.tag = 5005
		self.addTarget(self, action: #selector(tapped), for: .touchUpInside)
		self.setTitleColor(UIColor.white, for: .normal)
		self.titleLabel?.font = UIFont(name:"ChalkboardSE-Bold", size: 12)
		self.setTitleColor(UIColor.white, for: .highlighted)
		UIApplication.shared.delegate?.window??.rootViewController?.view.addSubview(self)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	@objc func tapped(sender: UIButton) {
		Ads.buy(frame: sender.frame)
	}
	
}


class WallButton: UIButton {
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.tag = 5006
		self.addTarget(self, action: #selector(tapped), for: .touchUpInside)
		self.titleLabel?.font = UIFont(name:"ChalkboardSE-Bold", size: 12)
		self.setTitleColor(UIColor.white, for: .highlighted)
		UIApplication.shared.delegate?.window??.rootViewController?.view.addSubview(self)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	@objc func tapped(sender: UIButton) {
		Ads.showWall()
	}
	
}





