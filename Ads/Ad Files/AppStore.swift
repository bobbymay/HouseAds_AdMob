import Foundation
import StoreKit


class AppStore: NSObject, SKStoreProductViewControllerDelegate {
	
	/// Presents the app store
	func open(_ id: UInt32) {
		if Internet.available {
			let id = [SKStoreProductParameterITunesItemIdentifier: id]
			let storeView = SKStoreProductViewController()
			storeView.delegate = self
			storeView.loadProduct(withParameters: id, completionBlock: { (status: Bool, error: Error?) -> Void in
				if status {
					UIApplication.shared.delegate?.window??.rootViewController?.present(storeView, animated: true, completion: nil)
				} else {
					print("Error: \(String(describing: error?.localizedDescription))")
				}})
		} else {
			alert(title: "No Internet", message: "You need an Internet connection", button: "OK", view: UIApplication.shared.delegate?.window??.rootViewController as! ViewController)
		}
	}
	
	/// Dismisses app store
	func productViewControllerDidFinish(_ viewController: SKStoreProductViewController) {
		viewController.presentingViewController?.dismiss(animated: true, completion: nil)
	}
	
}



