import Foundation
import SystemConfiguration


enum InternetStatus {
	case offline, wwan, wifi
	
	init(InternetFlags flags: SCNetworkReachabilityFlags) {
		let connectionRequired = flags.contains(.connectionRequired)
		let isReachable = flags.contains(.reachable)
		let isWWAN = flags.contains(.isWWAN)
		
		if !connectionRequired && isReachable {
			if isWWAN { self = .wwan } else { self = .wifi }
		} else {
			self = .offline
		}
	}
	
}

public class Internet {
	
	/// Checks Internet connection status
	static var available: Bool {
		switch Internet().checkConnection() {
		case .offline:	return false
		case .wwan:		return true
		case .wifi: 	return true
		}
	}
	
	/// Checks Internet connection type: .offline .wwan .wifi
	static var connectedBy: InternetStatus {
		switch Internet().checkConnection() {
		case .offline:	return .offline
		case .wwan:		return .wwan
		case .wifi: 	return .wifi
		}
	}
	
	/// Monitor Internet and run code in SCNetworkReachabilitySetCallback when connection is established
	func monitorInternet() {
		var context = SCNetworkReachabilityContext(version: 0, info: nil, retain: nil, release: nil, copyDescription: nil)
		let reachable = SCNetworkReachabilityCreateWithName(nil, "apple.com")!
		
		SCNetworkReachabilitySetCallback(reachable, { ( _, _, _) in
			guard Internet.available else { return }
			if !AdMob.created && !Ads.removed { Ads.adMob.create() }
			if !Banners.File.downloaded && !Banners.File.trying && !Banners.File.attempted { Banners.getFile() }
		}, &context)
		
		SCNetworkReachabilityScheduleWithRunLoop(reachable, CFRunLoopGetMain(), RunLoopMode.commonModes as CFString)
	}
	
	/// Check Internet status
	private func checkConnection() -> InternetStatus {
		if let flags = getFlags() {	return InternetStatus(InternetFlags: flags) }
		return .offline
	}
	
	private func getFlags() -> SCNetworkReachabilityFlags? {
		guard let reachability = ipv4() ?? ipv6() else {	return nil	}
		var flags = SCNetworkReachabilityFlags()
		if !SCNetworkReachabilityGetFlags(reachability, &flags) { return nil }
		return flags
	}
	
	private func ipv6() -> SCNetworkReachability? {
		var zeroAddress = sockaddr_in6()
		zeroAddress.sin6_len = UInt8(MemoryLayout<sockaddr_in>.size)
		zeroAddress.sin6_family = sa_family_t(AF_INET6)
		
		return withUnsafePointer(to: &zeroAddress, {
			$0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
				SCNetworkReachabilityCreateWithAddress(nil, $0)
			}
		})
	}
	
	private func ipv4() -> SCNetworkReachability? {
		var zeroAddress = sockaddr_in()
		zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
		zeroAddress.sin_family = sa_family_t(AF_INET)
		
		return withUnsafePointer(to: &zeroAddress, {
			$0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
				SCNetworkReachabilityCreateWithAddress(nil, $0)
			}
		})
	}
	
	
}



















