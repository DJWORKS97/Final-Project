//
//  LocationManager.swift
//  FrFinder
//
//  Created by David Jones on 27/07/2022.
//

import Foundation
import CoreLocation

class LocationManager: NSObject, ObservableObject {
    private let manager = CLLocationManager()
    @Published var userLocation: CLLocation?
    @Published var locality = String()
    static let shared = LocationManager()
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.startUpdatingLocation()
    }
    
    func requestLocation() {
        manager.requestWhenInUseAuthorization()
    }
    
    func lookUpCurrentLocation(completionHandler: @escaping (CLPlacemark?) -> Void ) {
        let geocoder = CLGeocoder()

        geocoder.reverseGeocodeLocation(userLocation!, completionHandler: { (placemarks, error) in
            if error == nil {
                let firstLocation = placemarks?[0]
                completionHandler(firstLocation)
            } else {
                completionHandler(nil)
            }
        })
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            print("DEBUG: Not determined")
        case .restricted:
            print("DEBUG: Restricted")
        case .denied:
            print("DEBUG: Denied")
        case .authorizedAlways:
            print("DEBUG: Auth always")
        case .authorizedWhenInUse:
            print("DEBUG: Auth when in use")
        @unknown default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("test")
        guard let location = locations.last else { return }
        let geocoder = CLGeocoder()

        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            if (error != nil) {
                print("error")
            }
            let placemark = placemarks! as [CLPlacemark]
            if placemark.count>0 {
                let placemark = placemarks![0]
                self.userLocation = location
                self.locality = placemark.locality!
            }
        }
    }
}
