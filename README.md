House Ads with Google's AdMob
=============================
Displays Google's AdMob banner. Additionally, downloads, saves, and can display personal banners (house ads), along with displaying a banner wall.

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
Banner sizes are 350x50 for iPhone and 728x90 for iPad. Code will obviously need to be changed to download your own data. You can do this in the Banners file. 

### Requirements:
iOS 10.0 - Swift 3.1

#### License:
[MIT License](https://github.com/bobbymay/HouseAds/blob/master/LICENSE)

