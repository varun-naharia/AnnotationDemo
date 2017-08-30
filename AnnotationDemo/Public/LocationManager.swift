//
//  LocationManager.swift
//  OrganizationsVolunteer
//
//  Created by Varun Naharia on 14/03/17.
//  Copyright © 2017 Ravindra. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

protocol LocationManagerDelegate
{
    func locationUpdated(location:CLLocation)
}

class LocationManager: NSObject, CLLocationManagerDelegate {
    var location:CLLocation = CLLocation(latitude: CLLocationDegrees(exactly: 0.0)!, longitude: CLLocationDegrees(exactly: 0.0)!)
    var locationManager = CLLocationManager()
    static var isLocationNotReceived:Bool = true
    static let sharedInstance = LocationManager()
    var delegate:LocationManagerDelegate?
    private override init() {
        super.init()
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.location = locations.last!
        LocationManager.isLocationNotReceived = false
        //print("long = \((locations.last?.coordinate.longitude)!) \n lat = \((locations.last?.coordinate.latitude)!)")
        delegate?.locationUpdated(location: location)
    }
    
    func getLocation(locationReceived:@escaping(_ location:CLLocation)-> Void)
    {
        DispatchQueue.global().async{
            while LocationManager.isLocationNotReceived  {
               // print("waiting")
            }
            DispatchQueue.main.async {
                locationReceived(self.location)
                
            }
            
        }
        
    }
}
