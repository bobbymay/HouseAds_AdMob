import UIKit

struct Banners {
	
	static var finished = false
	static var finalCount = -1
	
	struct File {
		static var downloaded = false
		static var trying = false
		static var attempted = false
	}
	
	
	/// Banner count
	static var count: Int {
		if finalCount >= 0 { return finalCount } // avoids reading from documents every time
		// count banners by searching documents folder using data stored in UserDefaults
		guard let mb = UserDefaults.standard.dictionary(forKey: "MyBanners") else { return 0 }
		guard let doc = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) else {	 return 0 }
		var count = 0
		for e in mb.keys {
			if FileManager().fileExists(atPath: doc.appendingPathComponent(e).path) {
				count += 1
			}
		}
		if Banners.finished { finalCount = count }
		return count
	}
	
	
	/// Gets file that holds apple ids and banner image names
	static func getFile() {
		
		// avoid file being read as often through data connectivity. File will be downloaded 1, 2, 5, 10, 15, 20... opens, through data connectivity
		if Internet.connectedBy != .wifi {
			let starts = UserDefaults.standard.integer(forKey: "adStarts")
			if starts > 2 && starts % 5 != 0 { return }
		}
		
		File.trying = true
		Banners.getFrom(web: "http://digitalbananasapps.com/banners/ids.txt", cashe: false) {
			File.attempted = true
			File.trying = false
			if let data = $0 {
				File.downloaded = true
				// get banners
				guard let file = NSString(data: data as! Data, encoding: String.Encoding.utf8.rawValue)?.components(separatedBy: "\n") else {	return	}
				guard let mb = UserDefaults.standard.dictionary(forKey: "MyBanners") else {
					// first time or no banner stored, so download
					download(file, first: true)
					return
				}
				// check for new banners
				if file.count == Banners.count { print("nothing new"); Banners.saveIDs(file); Banners.finished = true; return	 }
				// download more banners
				if file.count > Banners.count { missing(file) }
				// delete banners
				if file.count < Banners.count { 	delete(file: file, stored: [String](mb.keys))	}
			}
			File.trying = false
		}
	}
	
	
	/**
		Saves IDs to UserDefaults
		- Parameters:
    - file: Data read from file on website with image names and app IDs
 */
	private static func saveIDs(_ file: [String]) {
		var nameIds = [String : String]()
		file.forEach {
			let t = $0.components(separatedBy: ",")
			nameIds[t[0]] = t[1]
		}
		// update
		UserDefaults.standard.set(nameIds, forKey: "MyBanners")
	}
	
	
	/**
		Downloads images and IDs
		- Parameters:
		  - array: This holds image names and IDs separated by a comma
	  	- first: Is this the first time downloading data
 */
	private static func download(_ array: [String], first: Bool = false) {
		var nameIds = [String : String]()
		// count banner downloads to know when finished
		var count = 0
		for e in array {
			// add to dictionary
			let t = e.components(separatedBy: ",")
			nameIds[t[0]] = t[1]
			// get banners from website
			let domain = "http://digitalbananasapps.com/banners/\(language)/\(t[0])\(Device.types == .pad ? "pad" : "phone")_\(language).jpg"
			Banners.getFrom(web: domain, cashe: false) {
				if let data = $0, let image = UIImage(data: (data as! NSData) as Data) {
					if save(image: image, name: t[0]) {
						print("Image downloaded: \(e) - ", true)
						downloaded()
					}
				}
			}
		}
		
		// Saves images names and IDs
		if first { // first time
			UserDefaults.standard.set(nameIds, forKey: "MyBanners")
		} else { // update
			if var mb = UserDefaults.standard.dictionary(forKey: "MyBanners") {
				nameIds.forEach { mb[$0.key] = $0.value }
				UserDefaults.standard.set(mb, forKey: "MyBanners")
			}
		}
		
		/// Called everytime an image is downloaded successfully
		func downloaded() {
			// as soon one banner is downloaded, attempt to display it
			if !TopBanner.created && !Ads.removed {
				TopBanner.created = true
				DispatchQueue.main.async { _ = TopBanner() }
			}
			// check if all banners are downloaded
			count += 1
			if count >= array.count && Banners.finished == false {
				print("Downloads Completed")
				Banners.finished = true
				// if banners are finished downloading and table is showing, reload
				if BannerWall.showing, let tableView = UIApplication.shared.delegate?.window??.rootViewController?.view.viewWithTag(7000) as? UITableView {
					DispatchQueue.main.async {
						BannerWall.setBanners()
						tableView.reloadData()
					}
				}
			}
		}
		
	}
	
	
	/**
		Get data from web
		- Parameters:
    - web: Domain name
		  - cashe: Should the data be cashed
		  - closure: Escaping closure to return data that was downloaded
 */
	private static func getFrom(web: String, cashe: Bool, closure: @escaping (Any?) -> Void) {
		guard let url = URL(string: web) else {	return closure(nil)	}
		// configure based on whether or not to cashe
		let config = URLSessionConfiguration.default
		if !cashe { 	config.requestCachePolicy = .reloadIgnoringLocalCacheData;	config.urlCache = nil	}
		// download data, check for errors
		let task = URLSession(configuration: config).dataTask(with: url) { (data, response, error) in
			guard error == nil else {		return closure(nil)	}
			guard response != nil else {	return closure(nil)	}
			if let httpResponse = response as? HTTPURLResponse {
				if httpResponse.statusCode > 400 { return closure(nil) }
			}
			guard data != nil else {		return closure(nil)	}
			closure(data!) // return data that was downloaded
		}; task.resume()
	}
	
	
	/**
		Saves images to the documents folder
		- Parameters:
		  - image: Image to be stored
			 - name: Name of image
 */
	private static func save(image: UIImage, name: String) -> Bool {
		guard let data = UIImagePNGRepresentation(image) ?? UIImageJPEGRepresentation(image, 1) else {	return false	}
		guard let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) as NSURL else {	return false	}
		do {
			try data.write(to: directory.appendingPathComponent(name)!)
			blockCloud(filePath: (directory.appendingPathComponent(name)?.path)!)
			return true
		} catch {
			print(error.localizedDescription)
			return false
		}
	}
	
	
	/**
		Finds banners that need to be downloaded
		- Parameters:
	  	- file: Array of strings holding image names and Apple IDs separated by a comma
		*/
	private static func missing(_ file: [String]) {
		guard let doc = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) else {	 return }
		var banners = [String]()
		for e in file {
			let t = e.components(separatedBy: ",")
			if FileManager().fileExists(atPath: doc.appendingPathComponent(t[0]).path) == false {
				banners.append(e)
			}
		}
		download(banners)
	}
	
	
	/**
		Delete banners no longer listed on websites file
		- Parameters:
		  - file: Array of strings holding image names and Apple IDs separated by a comma
		  - stored: Image names and Apple IDs that  is already saved
		*/
	private static func delete(file: [String], stored: [String]) {
		guard let doc = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) else {	 return }
		for ban in stored {
			var found = false
			for f in file {
				if f.contains(ban) { found = true;	break }
			}
			if !found { // delete banners not listed in file
				if FileManager().fileExists(atPath: doc.appendingPathComponent(ban).path) {
					do {	try FileManager.default.removeItem(at:doc.appendingPathComponent(ban)) } catch {	 print(error.localizedDescription) 	}
				}
			}
		}
		// update user defaults
		var nameIds = [String: String]()
		for e in file {
			let t = e.components(separatedBy: ",")
			nameIds[t[1]] = t[0].components(separatedBy: ".").first
		}
		UserDefaults.standard.set(nameIds, forKey: "MyBanners")
		Banners.finished = true
	}
	
	
	/**
		Prevents banners from being backed up to iCloud (app can be rejected for using more than 2 MB)
		- Parameters:
	  	- filePath: File path to the app directory
		*/
	private static func blockCloud(filePath:String) {
		//		https://developer.apple.com/library/content/qa/qa1719/_index.html
		guard FileManager().fileExists(atPath:filePath) else { print("blockCloud: file does not exist"); return }
		assert(FileManager.default.fileExists(atPath: filePath), "File \(filePath) does not exist")
		let url = NSURL.fileURL(withPath: filePath) as NSURL
		do {
			try url.setResourceValue(true, forKey:URLResourceKey.isExcludedFromBackupKey)
		} catch let error as NSError {
			print("Error excluding \(String(describing: url.lastPathComponent)) from backup \(error)");
		}
	}
	
}









