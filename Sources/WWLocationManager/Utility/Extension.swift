//
//  Extension.swift
//  WWLocationManager
//
//  Created by William.Weng on 2024/1/22.
//

import UIKit
import CoreTelephony
import CoreLocation

// MARK: - Collection (override class function)
extension Collection {

    /// [為Array加上安全取值特性 => nil](https://stackoverflow.com/questions/25329186/safe-bounds-checked-array-lookup-in-swift-through-optional-bindings)
    subscript(safe index: Index) -> Element? { return indices.contains(index) ? self[index] : nil }
}

// MARK: - UIDevice (function)
extension UIDevice {
    
    /// [SIM卡供應商的國籍碼](https://stackoverflow.com/questions/18798398/how-to-get-the-users-country-calling-code-in-ios)
    /// - iOS 12之後有雙SIM卡 => [ISO 3166-1](https://zh.wikipedia.org/wiki/ISO_3166-1)
    /// - Returns: [String]
    static func _isoCountryCodes() -> [String] {
        
        var codeArray = [String]()
        
        if let info = CTTelephonyNetworkInfo().serviceSubscriberCellularProviders {
            for (_, value) in info { if let code = value.isoCountryCode { codeArray.append(code.uppercased()) }}
        }
        
        return codeArray
    }
}

// MARK: - Locale (static function)
extension Locale {
    
    /// 取得首選語系 (第一個語系)
    /// - 設定 -> 一般 -> 語言與地區 -> 偏好的語言順序 (zh-Hant-TW / [語系-分支-地區])
    /// - Returns: [語系辨識碼](https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/BPInternational/LanguageandLocaleIDs/LanguageandLocaleIDs.html)
    static func _preferredLanguage() -> String? {
        guard let language = Locale.preferredLanguages.first else { return nil }
        return language
    }
    
    /// 把完整的語系編碼分類
    /// - zh-Hant-TW => [語系-分支-地區]
    /// - Parameter language: 完整的語系文字
    /// - Returns: Constant.LanguageInformation?
    static func _preferredLanguageInfomation(_ language: String? = Locale.preferredLanguages.first) -> WWLocationManager.LanguageInformation? {

        guard let preferredLanguage = language,
              let languageInfos = Optional.some(preferredLanguage.split(separator: "-")),
              languageInfos.count > 0
        else {
            return nil
        }

        var info: WWLocationManager.LanguageInformation = (nil, nil, nil)

        switch languageInfos.count {
        case 1: info.code = languageInfos.first
        case 2: info.code = languageInfos.first; info.region = languageInfos.last
        case 3: info.code = languageInfos.first; info.region = languageInfos.last; info.script = languageInfos[safe: 1]
        default: break
        }

        return info
    }
    
    /// 取得裝置區域
    /// - 設定 -> 一般 -> 語言與地區 -> 地區 (TW)
    /// - Returns: 區域辨識碼
    static func _currentRegionCode() -> String? { return Locale.current.regionCode }
}

// MARK: - CLLocationCoordinate2D (function)
extension CLLocationCoordinate2D {
    
    /// 將坐標(25.04216003, 121.52873230) => CLPlacemark (地址)
    /// - Parameters:
    ///   - preferredLocale: 傳回的資料語系區域
    ///   - result: Result<CLPlacemark, Error>
    func _placemark(preferredLocale: Locale = Locale(identifier: "zh_TW"), result: @escaping (Result<CLPlacemark, Error>) -> Void)  {
        
        let location = CLLocation(latitude: latitude, longitude: longitude)
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(location, preferredLocale: preferredLocale) { placemarks, error in
            
            if let error = error { result(.failure(error)); return }
            if let placemark = placemarks?.first { result(.success(placemark)); return }
            
            result(.failure(WWLocationManager.CustomError.notGeocodeLocation))
        }
    }
}

// MARK: - CLLocationManager (static function)
extension CLLocationManager {
    
    /// 定位授權Manager產生器
    /// - Parameters:
    ///   - delegate: CLLocationManagerDelegate
    ///   - desiredAccuracy: 定位的精度
    ///   - distanceFilter: 過濾的距離
    /// - Returns: CLLocationManager
    static func _build(delegate: CLLocationManagerDelegate?, desiredAccuracy: CLLocationAccuracy = kCLLocationAccuracyBest, distanceFilter: CLLocationDistance = 1) -> CLLocationManager {
        
        let locationManager = CLLocationManager()

        locationManager.delegate = delegate
        locationManager.desiredAccuracy = desiredAccuracy
        locationManager.distanceFilter = distanceFilter
        
        return locationManager
    }
    
    /// 取得該裝置的國家地域碼 (不包含GPS定位)
    /// - Returns: LocationCountryCode
    static func _locationCountryCode() -> WWLocationManager.LocationCountryCode {
        
        var code = WWLocationManager.LocationCountryCode(GPS: nil, SIMs: [], preferredLanguage: nil, region: nil)
        
        code.SIMs = UIDevice._isoCountryCodes()
        code.region = Locale._currentRegionCode()
        
        if let codeWithLanguage = Locale._preferredLanguageInfomation()?.region { code.preferredLanguage = String(codeWithLanguage) }
        
        return code
    }
}

// MARK: - CLLocationManager (function)
extension CLLocationManager {
    
    /// [定位授權的各種狀態處理](https://www.appcoda.com.tw/ios-14-location-permission/)
    /// - requestWhenInUseAuthorization() => 詢問是否要開啟定位授權的提示視窗
    /// - info.plist => NSLocationAlwaysAndWhenInUseUsageDescription / NSLocationWhenInUseUsageDescription
    /// - Parameters:
    ///   - alwaysHandler: 選擇always後的動作
    ///   - whenInUseHandler: 選擇whenInUse後的動作
    ///   - deniedHandler: 選擇denied後的動作
    func _locationServicesAuthorizationStatus(alwaysHandler: @escaping () -> Void, whenInUseHandler: @escaping () -> Void, deniedHandler: @escaping () -> Void) {
        
        switch authorizationStatus {
        case .notDetermined: requestWhenInUseAuthorization()
        case .authorizedWhenInUse: whenInUseHandler()
        case .authorizedAlways: alwaysHandler()
        case .denied: deniedHandler()
        case .restricted: deniedHandler()
        @unknown default: fatalError()
        }
    }
    
    /// 處理位置的相關資料
    /// - 最後一筆的有效位置 > 0
    /// - Parameter locations: 取到的位置們
    /// - Returns: Constant.LocationInformation
    func _locationInfomation(with locations: [CLLocation]) -> WWLocationManager.LocationInformation {

        guard let location = locations.last,
              let isAvailable = Optional.some(location.horizontalAccuracy > 0)
        else {
            return (nil, false)
        }

        return (location, isAvailable)
    }
}
