//
//  Utilities.swift
//  RudyGrubFeeder
//
//  Created by Varun Naharia on 02/02/17.
//  Copyright © 2017 TechNaharia. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

let GoogleMapsAPIServerKey = "AIzaSyCcRfm46grZkxmqPmN51baEkMa4Fq_X9oc"
private var _screenHeight = UIScreen.main.bounds.height
private var _screenSize = UIScreen.main.bounds
private var _screenWidth = UIScreen.main.bounds.width
private var _screenCenterX = UIScreen.main.bounds.width/2
private var _screenCenterY = UIScreen.main.bounds.height/2

class Utilities {
    
    public class var screenHeight: CGFloat
    {
        get { return _screenHeight }
        set { _screenHeight = newValue }
    }
    
    public class var screenSize: CGRect
    {
        get { return _screenSize }
        set { _screenSize = newValue }
    }
    
    public class var screenWidth: CGFloat
    {
        get { return _screenWidth }
        set { _screenWidth = newValue }
    }
    
    public class var screenCenterX: CGFloat
        {
        get { return _screenCenterX }
        set { _screenCenterX = newValue }
    }
    
    public class var screenCenterY: CGFloat
        {
        get { return _screenCenterY }
        set { _screenCenterY = newValue }
    }
    
    public class func setStatusBarColor(color:UIColor, controller:UIViewController){
        let viewBG = UIView(frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.size.width, height: 20.0))
        viewBG.backgroundColor = color
        controller.navigationController?.view.addSubview(viewBG)
    }
    
    public class func setNavigationColor(controller:UIViewController, backgroundColor:UIColor, tintColor:UIColor, titleTextColor:UIColor, barStyle:UIBarStyle)
    {
        let nav = controller.navigationController?.navigationBar
        nav?.barStyle = barStyle
        nav?.tintColor = tintColor
        nav?.backgroundColor = backgroundColor //
        nav?.titleTextAttributes = [NSForegroundColorAttributeName: titleTextColor]
    }
    
    public class func getAddressFrom(location: CLLocation, completion:@escaping ((String?) -> Void)) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in

            if(placemarks != nil && (placemarks?.count)! > 0)
            {
                let placemark:CLPlacemark = (placemarks?.first)!
                //let subThoroughfare:String? = (placemark.subThoroughfare)!
                //let thoroughfare:String? = (placemark.thoroughfare)!
                let name:String = placemark.name != nil ? placemark.name!:""
                let locality:String = placemark.locality != nil ? placemark.locality!:""
                let administrativeArea:String = placemark.administrativeArea != nil ? placemark.administrativeArea!:""
                let country:String = placemark.country != nil ? placemark.country!:""
                let pin:String = placemark.postalCode != nil ? placemark.postalCode!:""
                let address = "\(name), \(locality) \(administrativeArea), \(country), \(pin)"
                completion(address)
            }
            else
            {
                completion(nil)
            }
            //            if let placemark = placemarks?.first,
//                let locality = placemark.locality,
//                let administrativeArea = placemark.administrativeArea {
//                let address = locality + " " + administrativeArea
//                
//                //placemark.addressDictionary
//                print("addressmax:\(address)")
//                completion(address)
//                
//            }
//            else
//            {
//                completion(nil)
//            }
        }
        //***************************************************************
//        let baseUrl = "https://maps.googleapis.com/maps/api/geocode/json?"
////        let apikey = "AIzaSyAUY2IpJpM2XW1-pxrzapIs24WDWj3jzWc"
//        let url = "\(baseUrl)latlng=\(location.coordinate.latitude),\(location.coordinate.longitude)"
//        ServiceManager.requestWithGet(baseURL: url, methodName: "", parameter: nil, isHUD: false) { (response) in
//            if let result = response["results"].arrayObject as? [[String:Any]] {
//                if result.count > 0 {
//                    if let address = result[0]["address_components"] as? NSArray {
//                        let number = (address[0] as! [String:Any])["short_name"] as! String
//                        let street = (address[1] as! [String:Any])["short_name"] as! String
//                        let city = (address[2] as! [String:Any])["short_name"] as! String
//                        let state = (address[4] as! [String:Any])["short_name"] as! String
//                        let zip = (address[6] as! [String:Any])["short_name"] as! String
//                        print("\n\(number) \(street), \(city), \(state) \(zip)")
//                        completion("\(number) \(street), \(city), \(state) \(zip)")
//                    }
//                }
//            }
//        }
        
    }
    
    class func setUserDefault(ObjectToSave : AnyObject?  , KeyToSave : String)
    {
        let defaults = UserDefaults.standard
        
        if (ObjectToSave != nil)
        {
            
            defaults.set(ObjectToSave, forKey: KeyToSave)
        }
        
        UserDefaults.standard.synchronize()
    }
    
    class func getUserDefault(KeyToReturnValye : String) -> AnyObject?
    {
        let defaults = UserDefaults.standard
        
        if let name = defaults.value(forKey: KeyToReturnValye)
        {
            return name as AnyObject
        }
        return nil
    }
    
    class func removetUserDefault(KeyToRemove : String)
    {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: KeyToRemove)
        UserDefaults.standard.synchronize()
    }
    
    class func getNameOf(location:CLLocationCoordinate2D) -> String {
        let sync:SyncBlock = SyncBlock()
        var name:String = ""
        let url = URL(string: "https://maps.googleapis.com/maps/api/geocode/json?latlng=\(location.latitude),\(location.longitude)&sensor=true&location_type=ROOFTOP&key=\(GoogleMapsAPIServerKey)")
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            do
            {
                
                let dict = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String: Any]
                if(dict["status"] as! String == "OK")
                {
                    name = (dict["results"] as! [[String:Any]])[0]["formatted_address"] as! String
                }
                sync.complete()
            }
            catch
            {
                print(error)
            }
        }
        task.resume()
        sync.wait()
        return name
    }
}
