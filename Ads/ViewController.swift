import UIKit

class ViewController: UIViewController {

	override func viewDidAppear(_ animated: Bool) {
		
		Ads.start()
		
		// Remove ads button
		if !Ads.removed {
			let button = RemoveAdsButton(frame: CGRect(x: 0, y: Screen.height * 0.3, width: Screen.width/2, height: 50))
			button.setTitle("Remove Ads", for: .normal)
			button.backgroundColor = UIColor.red
		}

		// Banner wall button
		let button = WallButton(frame: CGRect(x: Screen.width/2, y: Screen.height * 0.3, width: Screen.width/2, height: 50))
		button.setTitle("Show Wall", for: .normal)
		button.backgroundColor = UIColor.orange

	}
	
	override var prefersStatusBarHidden: Bool {
		return true
	}
	
}


