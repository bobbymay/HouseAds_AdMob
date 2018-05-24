import UIKit
import AVFoundation

/// Screen information: width, height, status bar height
enum Screen {
	static var width: CGFloat {
		return UIScreen.main.bounds.width
	}
	static var height: CGFloat {
		return UIScreen.main.bounds.height
	}
	static var statusBarHeight: CGFloat {
		return UIApplication.shared.statusBarFrame.size.height
	}
}

// MARK: -

/// Enum: landscape or portrait. mode func returns results
enum Orientation {
	case portrait, landscape
	/// landscape or portrait
	static var mode: Orientation {
		if Screen.width > Screen.height { return .landscape }
		return .portrait
	}
}

// MARK: -

/// Enum: all device types. types Func gets specific device type
enum Device {
	/// iPhone 5, iPhone SE
	case smallPhone
	/// iPhone 6 & 7
	case phone
	/// iPhone Plus
	case largePhone
	/// iPhone X
	case phoneX
	/// iPad Air's, iPad Pro 9.7
	case pad
	/// iPad Pro 10.5
	case padLarge
	/// iPad Pro 12.9
	case padPro
	/// Individual device types
	static var types: Device {
		// finds the larger screen orientation
		let size = UIScreen.main.bounds.height > UIScreen.main.bounds.width ? UIScreen.main.bounds.height : UIScreen.main.bounds.width
		switch size {
		case _ where size <= 568: return .smallPhone
		case _ where size <= 667: return .phone
		case _ where size <= 768: return .largePhone
		case _ where size <= 812: return .phoneX
		case _ where size <= 1024: return .pad
		case _ where size <= 1112: return .padLarge
		default: return .padPro
		}
	}
	/// iPhone or iPad
	static var type: Device {
		return UIScreen.main.bounds.width >= 1024 || UIScreen.main.bounds.height >= 1024 ? .pad : .phone
	}
}

// MARK: - Variables

var language: String {
	if let l = (Locale.current as NSLocale).object(forKey: .languageCode) as? String {
		for e in ["en", "es", "fr", "it", "ja", "ko", "nl", "de", "pt", "ru", "zh"] {
			if e == l {	return l	}
		}
		return "en"
	}
	return "en"
}

// MARK: - Functions

func alert(title: String, message: String, button: String, view: ViewController)  {
	let alertController = UIAlertController(title: title as String, message: message as String, preferredStyle: .alert)
	let OKAction = UIAlertAction(title: button, style: .default)
	alertController.addAction(OKAction)
	view.present(alertController, animated: true, completion:nil)
}


func actionSheet(title: String?, message: String, button1: String, button2: String?, view: ViewController) {
	let sheet = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
	let b1 = UIAlertAction(title: button1, style: .default, handler: { (alert: UIAlertAction!) -> Void in
		print(button1)
	})
	sheet.addAction(b1)
	if let message = button2 {
		let b2 = UIAlertAction(title: button2, style: .default, handler: { (alert: UIAlertAction!) -> Void in
			print(message)
		})
		sheet.addAction(b2)
	}
	let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (alert: UIAlertAction!) -> Void in
		print("Cancelled")
	})
	sheet.addAction(cancel)
	view.present(sheet, animated: true, completion: nil)
}

// MARK: - Extensions

extension CGRect {
	/// Returns view's center position with the size
	static	func center(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) -> CGRect {
		let view = UIView(frame: CGRect(x: 0, y: 0, width: width, height: height))
		view.center = CGPoint(x: x, y: y)
		return CGRect(x: view.frame.origin.x, y: view.frame.origin.y, width: view.frame.size.width, height: view.frame.size.height)
	}
}




























