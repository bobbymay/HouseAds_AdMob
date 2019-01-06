House Ads with Google's AdMob
=============================
Displays Google's [AdMob banner](https://developers.google.com/admob/ios/banner). Additionally, downloads, saves, and displays personal banners (house ads), along with the ability to display a banner wall.

![example](https://github.com/bobbymay/HouseAds_AdMob/blob/master/example.gif)

### How It Works:
At launch, a banner from AdMob will be displayed, if this banner fails, a house banner will replace it until an AdMob banner is received. Using In-App Purchase the user has the option to remove these advertisements (excluding the banner wall, which is only displayed after a button is tapped).

* Banner image changes at certain intervals.
* Banner wall shuffles banners every time shown.
* Supports portrait and landscape modes.
* Opens App Store within app when banner tapped.

### Installing AdMob:
 [Download](https://developers.google.com/admob/ios/download) the SDK, or use CocoaPods (Google preferred):

Add to your Podfile:
```
pod 'Google-Mobile-Ads-SDK'
```

### Example:
##### Initiate:
```swift
Ads.start()
```
##### Show Banner Wall:
```swift
Ads.showWall()
```
You can change the code to download your own data in the [Banners.swift](https://github.com/bobbymay/HouseAds/blob/master/Ads/Ad%20Files/Banners.swift) file.

### Sizes:
iPhone: 350x50  
iPad: 728x90 

### Requirements:
iOS 10.0 - Swift 3.1

#### License:
[MIT License](https://github.com/bobbymay/HouseAds/blob/master/LICENSE)

