# WWLocationManager

[![Swift-5.7](https://img.shields.io/badge/Swift-5.7-orange.svg?style=flat)](https://developer.apple.com/swift/) [![iOS-15.0](https://img.shields.io/badge/iOS-15.0-pink.svg?style=flat)](https://developer.apple.com/swift/) ![TAG](https://img.shields.io/github/v/tag/William-Weng/WWLocationManager) [![Swift Package Manager-SUCCESS](https://img.shields.io/badge/Swift_Package_Manager-SUCCESS-blue.svg?style=flat)](https://developer.apple.com/swift/) [![LICENSE](https://img.shields.io/badge/LICENSE-MIT-yellow.svg?style=flat)](https://developer.apple.com/swift/)

## [Introduction - 簡介](https://swiftpackageindex.com/William-Weng)
- Find location-related settings on your phone. (Region / Language / SIM / GPS)
- 找出手機上跟地點相關的設定。 (地區 / 語系 / SIM / GPS定位)
- [Teaching - 設計教學](https://william-weng.github.io/2021/05/swift-5我到底身在何方我到底去到何處/)
- [iOS 16.4之後，CTCarrier棄用 / isoCountryCode取不到了](https://developer.apple.com/documentation/ios-ipados-release-notes/ios-ipados-16_4-release-notes)

## [Achievements display - 成果展示](https://www.hkweb.com.hk/blog/ui設計基礎知識：引導頁對ui設計到底有什麼作用/)

![WWLocationManager](./Example.png)

## [Installation with Swift Package Manager - 安裝方式](https://medium.com/彼得潘的-swift-ios-app-開發問題解答集/使用-spm-安裝第三方套件-xcode-11-新功能-2c4ffcf85b4b)

```bash
dependencies: [
    .package(url: "https://github.com/William-Weng/WWLocationManager.git", .upToNextMajor(from: "1.1.0"))
]
```

## Function - 可用函式

|函式|功能|
|-|-|
|countryCode(isAlways:result:)|取得有關所在位置的資訊 (Info.plist => NSLocationWhenInUseUsageDescription)|
|countryCode()|取得有關所在位置的資訊 (單次 / 持續)|
|locationCountryCode()|取得該裝置的國家地域碼 (不包含GPS定位)|
|preferredLanguageInfomation(_:)|把完整的語系編碼分類 (zh-Hant-TW => [語系-分支-地區])|
|close()|關閉定位|

## Example - 程式範例
```swift
import UIKit
import WWLocationManager

final class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Task {
            let code = await WWLocationManager.shared.countryCode()
            print(code)
        }
    }
}
```
