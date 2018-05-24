import UIKit
import StoreKit

class AdsPurchase: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
	
	private lazy var frame = CGRect()
	
	/// returns product ID
	static var productID: String {
		return "com.companyName.productID"
	}
	
	/// Attempt to remove ads
	func removeAds(id: String, frame: CGRect) {
		if Internet.available {
			if (UIScreen.main.traitCollection.userInterfaceIdiom == .pad) { self.frame = frame }
			SKPaymentQueue.default().add(self)
			request(id)
		} else {
			alert(title: "No Internet", message: "You need an Internet connection", button: "OK", view: UIApplication.shared.delegate?.window??.rootViewController as! ViewController)
		}
	}
	
	/// Fetches product information
	func request(_ id: String) {
		if SKPaymentQueue.canMakePayments() {
			let product: SKProductsRequest = SKProductsRequest(productIdentifiers: NSSet(object: id) as! Set<String>)
			product.delegate = self
			product.start()
			print("Fetching Products")
		} else {
			alert(title: "Not Authorized", message: "Restricted from accessing the App Store. Settings > General > Restrictions: enable App Store", button: "OK", view: UIApplication.shared.delegate?.window??.rootViewController as! ViewController)
		}
	}
	
	/// Received response from product request (Delegate)
	func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
		if (response.products.count > 0) {
			let product = response.products[0] as SKProduct
			let format = NumberFormatter(); format.numberStyle = .currency
			let price = format.string(from: product.price) ?? "$0.99"
			let message = "Ads will be removed for \(price). If you already made this purchase you can restore it."
			adActionSheet(message: message, product: product, request: request)
		} else {
			print("Error: Make sure the bundle Identifier matches the app, and check the product identifier")
		}
	}
	
	/// Show action sheet: Buy, Restore, Cancel
	func adActionSheet(message: String, product: SKProduct, request: SKProductsRequest) {
		let sheet = UIAlertController(title: nil, message: message, preferredStyle: .actionSheet)
		let button1 = UIAlertAction(title: "Buy", style: .default, handler: { [unowned self] (alert: UIAlertAction!) -> Void in
			self.purchase(product: product)
		})
		sheet.addAction(button1)
		let button2 = UIAlertAction(title: "Restore Purchase", style: .default, handler: { (alert: UIAlertAction!) -> Void in
			SKPaymentQueue.default().restoreCompletedTransactions()
		})
		sheet.addAction(button2)
		let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (alert: UIAlertAction!) -> Void in
			SKPaymentQueue.default().remove(self)
			request.cancel()
		})
		sheet.addAction(cancel)
		if (UIScreen.main.traitCollection.userInterfaceIdiom == .pad) {
			sheet.popoverPresentationController?.sourceView = UIApplication.shared.delegate?.window??.rootViewController?.view
			sheet.popoverPresentationController?.sourceRect = self.frame
		}
		UIApplication.shared.delegate?.window??.rootViewController?.present(sheet, animated: true, completion: nil)
	}
	
	/// Purchase button on action sheet pressed
	func purchase(product: SKProduct) {
		let payment = SKPayment(product: product)
		SKPaymentQueue.default().add(payment)
	}
	
	/// Sent when the transaction array has changed. (Observer)
	func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
		for transaction:AnyObject in transactions {
			if let trans:SKPaymentTransaction = transaction as? SKPaymentTransaction {
				switch trans.transactionState {
				case .purchasing:
					print("Transaction state -> Purchasing")
				case .purchased:
					print("Transaction state -> Purchased")
					Ads.purchased()
					SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
				case .restored:
					print("Transaction state -> Restored")
					Ads.purchased()
					SKPaymentQueue.default().restoreCompletedTransactions()
				case .failed:
					print("Transaction state -> Failed or Cancelled")
					SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
				default: break
				}
			}
		}
	}
	
}
