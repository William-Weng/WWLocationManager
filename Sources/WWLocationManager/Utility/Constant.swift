//
//  Constant.swift
//  WWLocationManager
//
//  Created by William.Weng on 2024/1/22.
//

import UIKit
import CoreLocation

// MARK: - typealias
public extension WWLocationManager {
    
    typealias LocationInformation = (location: CLLocation?, isAvailable: Bool)                                              // 定位的相關資訊
    typealias LocationCountryCode = (GPS: String?, SIMs: [String], preferredLanguage: String?, region: String?)             // 定位位置 => [GPS / SIM卡 / 首選語言 / 區域]
    typealias LanguageInformation = (code: String.SubSequence?, script: String.SubSequence?, region: String.SubSequence?)   // 語言資訊 => [語系-分支-地區]
}

// MARK: - Error
public extension WWLocationManager {
    
    /// 自訂錯誤
    enum CustomError: Error, LocalizedError {
        
        var errorDescription: String { errorMessage() }

        case notGeocodeLocation
        
        /// 顯示錯誤說明
        /// - Returns: String
        private func errorMessage() -> String {

            switch self {
            case .notGeocodeLocation: return "地理編碼錯誤"
            }
        }
    }
}
