//
//  WWLocationManager.swift
//  WWLocationManager
//
//  Created by William.Weng on 2024/1/22.
//

import CoreLocation

// MARK: - WWLocationManager
open class WWLocationManager: NSObject {
    
    public static let shared = WWLocationManager()
    
    private var isAlways = false
    private var completionBlock: ((Constant.LocationCountryCode?) -> Void)?
    private var errorBlock: ((Error?) -> Void)?
    
    private lazy var locationManager: CLLocationManager? = { CLLocationManager._build(delegate: self) }()
    private override init() {}
}

// MARK: - CLLocationManagerDelegate
extension WWLocationManager: CLLocationManagerDelegate {
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        countryCode(with: manager, locations: locations)
    }
    
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        locationManagerStatus(manager)
    }
    
    public func locationManager(_ manager: CLLocationManager, didFinishDeferredUpdatesWithError error: Error?) {
        postLocationCountryCode(error: error)
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        postLocationCountryCode(error: error)
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailRangingFor beaconConstraint: CLBeaconIdentityConstraint, error: Error) {
        postLocationCountryCode(error: error)
    }
}

// MARK: - 定位相關 (CLLocationManager)
public extension WWLocationManager {
    
    /// [取得有關所在位置的資訊 => 定位要開](https://blog.csdn.net/mingC0758/article/details/102820616)
    /// - Parameters:
    ///   - isAlways: 要一直定位嗎？
    ///   - result: Constant.LocationCountryCode?
    func countryCode(isAlways: Bool = false, result: @escaping (Constant.LocationCountryCode?) -> Void, failure: @escaping (Error?) -> Void) {
        
        closeLocationManager()
        
        self.isAlways = isAlways
        completionBlock = result
        errorBlock = failure
        
        locationManager?._locationServicesAuthorizationStatus(alwaysHandler: {
            self.locationManager?.startUpdatingLocation()
        }, whenInUseHandler: {
            self.locationManager?.startUpdatingLocation()
        }, deniedHandler: {
            self.completionBlock?(CLLocationManager._locationCountryCode())
        })
    }
    
    /// 關閉定位
    func close() { closeLocationManager() }
}

// MARK: - 定位相關 (CLLocationManager)
private extension WWLocationManager {
    
    /// [LocationManager狀態處理 - iOS 14](https://www.appcoda.com.tw/ios-14-location-permission/)
    /// - Parameters:
    ///   - manager: [CLLocationManager](https://xdasu.com/2018/05/04/ios-develop-使用者定位權限/)
    func locationManagerStatus(_ manager: CLLocationManager) {
        
        let status = manager.authorizationStatus
        
        switch status {
        case .notDetermined: break
        case .authorizedAlways, .authorizedWhenInUse: manager.startUpdatingLocation()
        case .denied, .restricted: manager.stopUpdatingLocation(); postLocationCountryCode()
        @unknown default: fatalError()
        }
    }
    
    /// 取得該裝置的國家地域碼
    /// - Notification._name(._locationServices)
    /// - Parameters:
    ///   - manager: CLLocationManager
    ///   - locations: [CLLocation]
    func countryCode(with manager: CLLocationManager, locations: [CLLocation]) {
        
        guard let location = manager._locationInfomation(with: locations).location else { self.postLocationCountryCode(); return }
        
        location.coordinate._placemark { (result) in
            
            var code = CLLocationManager._locationCountryCode()
            
            switch result {
            case .failure(_): break
            case .success(let placemark): code.GPS = placemark.isoCountryCode
            }
            
            self.postLocationCountryCode(code)
        }
    }
    
    /// 傳送LocationCountryCode (不包含定位的)
    /// - Parameters:
    ///   - code: Constant.LocationCountryCode?
    ///   - error: Error?
    func postLocationCountryCode(_ code: Constant.LocationCountryCode? = nil, error: Error? = nil) {

        let countryCode = code ?? CLLocationManager._locationCountryCode()
        completionBlock?(countryCode)
        
        if (!isAlways) { closeLocationManager() }
        if let error = error { errorBlock?(error) }
    }
    
    /// 清除LocationManager
    func closeLocationManager() {
        locationManager?.stopUpdatingLocation()
        completionBlock = nil
        errorBlock = nil
        isAlways = false
    }
}
