//
//  UINavigationController+Extra.swift
//  Thyssenkrupp
//
//  Created by Varun Naharia on 06/03/17.
//  Copyright © 2017 Varun Naharia. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

extension UINavigationController
{
    func popOrPopToViewController(viewController:UIViewController, animated:Bool) -> UIViewController? {
        var arrViewControllers:[UIViewController] = []
        
        arrViewControllers = self.viewControllers
        for vc:UIViewController in arrViewControllers {
            if(vc.isKind(of: viewController.classForCoder))
            {
                let  vcs = self.popToViewController(vc, animated: animated)
                if(vcs != nil)
                {
                    return vcs?.last
                }
                else
                {
                    return nil
                }
                
            }
            
        }
        return  nil
    }

}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension Request {
    public func debugLog() -> Self {
        #if DEBUG
            debugPrint(self)
        #endif
        return self
    }
}

extension Date {
    var millisecondsSince1970:Double {
        return Double((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    init(milliseconds:Int) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds / 1000))
    }
    
    init?(jsonDate: String) {
        
        let prefix = "/Date("
        let suffix = ")/"
        
        // Check for correct format:
        guard jsonDate.hasPrefix(prefix) && jsonDate.hasSuffix(suffix) else { return nil }
        
        // Extract the number as a string:
        let from = jsonDate.index(jsonDate.startIndex, offsetBy: prefix.characters.count)
        let to = jsonDate.index(jsonDate.endIndex, offsetBy: -suffix.characters.count)
        
        // Convert milliseconds to double
        guard let milliSeconds = Double(jsonDate[from ..< to]) else { return nil }
        
        // Create NSDate with this UNIX timestamp
        self.init(timeIntervalSince1970: milliSeconds/1000.0)
    }
    
    
}

import MapKit

fileprivate let MERCATOR_OFFSET: Double = 268435456
fileprivate let MERCATOR_RADIUS: Double = 85445659.44705395

extension MKMapView {
    
    func getZoomLevel() -> Double {
        
        let reg = self.region
        let span = reg.span
        let centerCoordinate = reg.center
        
        // Get the left and right most lonitudes
        let leftLongitude = centerCoordinate.longitude - (span.longitudeDelta / 2)
        let rightLongitude = centerCoordinate.longitude + (span.longitudeDelta / 2)
        let mapSizeInPixels = self.bounds.size
        
        // Get the left and right side of the screen in fully zoomed-in pixels
        let leftPixel = self.longitudeToPixelSpaceX(longitude: leftLongitude)
        let rightPixel = self.longitudeToPixelSpaceX(longitude: rightLongitude)
        let pixelDelta = abs(rightPixel - leftPixel)
        
        let zoomScale = Double(mapSizeInPixels.width) / pixelDelta
        let zoomExponent = log2(zoomScale)
        let zoomLevel = zoomExponent + 20
        
        return zoomLevel
    }
    
    func setCenter(coordinate: CLLocationCoordinate2D, zoomLevel: Int, animated: Bool) {
        
        let zoom = min(zoomLevel, 28)
        
        let span = self.coordinateSpan(centerCoordinate: coordinate, zoomLevel: zoom)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        
        self.setRegion(region, animated: true)
    }
    
    // MARK: - Private func
    
    private func coordinateSpan(centerCoordinate: CLLocationCoordinate2D, zoomLevel: Int) -> MKCoordinateSpan {
        
        // Convert center coordiate to pixel space
        let centerPixelX = self.longitudeToPixelSpaceX(longitude: centerCoordinate.longitude)
        let centerPixelY = self.latitudeToPixelSpaceY(latitude: centerCoordinate.latitude)
        
        // Determine the scale value from the zoom level
        let zoomExponent = 20 - zoomLevel
        let zoomScale = NSDecimalNumber(decimal: pow(2, zoomExponent)).doubleValue
        
        // Scale the map’s size in pixel space
        let mapSizeInPixels = self.bounds.size
        let scaledMapWidth = Double(mapSizeInPixels.width) * zoomScale
        let scaledMapHeight = Double(mapSizeInPixels.height) * zoomScale
        
        // Figure out the position of the top-left pixel
        let topLeftPixelX = centerPixelX - (scaledMapWidth / 2)
        let topLeftPixelY = centerPixelY - (scaledMapHeight / 2)
        
        // Find delta between left and right longitudes
        let minLng: CLLocationDegrees = self.pixelSpaceXToLongitude(pixelX: topLeftPixelX)
        let maxLng: CLLocationDegrees = self.pixelSpaceXToLongitude(pixelX: topLeftPixelX + scaledMapWidth)
        let longitudeDelta: CLLocationDegrees = maxLng - minLng
        
        // Find delta between top and bottom latitudes
        let minLat: CLLocationDegrees = self.pixelSpaceYToLatitude(pixelY: topLeftPixelY)
        let maxLat: CLLocationDegrees = self.pixelSpaceYToLatitude(pixelY: topLeftPixelY + scaledMapHeight)
        let latitudeDelta: CLLocationDegrees = -1 * (maxLat - minLat)
        
        return MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
    }
    
    private func longitudeToPixelSpaceX(longitude: Double) -> Double {
        return round(MERCATOR_OFFSET + MERCATOR_RADIUS * longitude * .pi / 180.0)
    }
    
    private func latitudeToPixelSpaceY(latitude: Double) -> Double {
        if latitude == 90.0 {
            return 0
        } else if latitude == -90.0 {
            return MERCATOR_OFFSET * 2
        } else {
            return round(MERCATOR_OFFSET - MERCATOR_RADIUS * Double(logf((1 + sinf(Float(latitude * .pi) / 180.0)) / (1 - sinf(Float(latitude * .pi) / 180.0))) / 2.0))
        }
    }
    
    private func pixelSpaceXToLongitude(pixelX: Double) -> Double {
        return ((round(pixelX) - MERCATOR_OFFSET) / MERCATOR_RADIUS) * 180.0 / .pi
    }
    
    
    private func pixelSpaceYToLatitude(pixelY: Double) -> Double {
        return (.pi / 2.0 - 2.0 * atan(exp((round(pixelY) - MERCATOR_OFFSET) / MERCATOR_RADIUS))) * 180.0 / .pi
    }
}

extension String {
    func characterAtIndex(index: Int) -> Character? {
        var cur = 0
        for char in self.characters {
            if cur == index {
                return char
            }
            cur += 1
        }
        return nil
    }
    
    func verifyUrl () -> Bool {
        
        if let url = URL(string: self) {
            return UIApplication.shared.canOpenURL(url)
        }
        return false
    }
    
    func hasHttp()->Bool{
        
        if(self.hasPrefix("http") || self.hasPrefix("https")){
            return true
        }
        return false
    }
    
    func isValidEmail() -> Bool {
        // print("validate calendar: \(testStr)")
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
}

extension MKMapView
{
    func removeAllOverlay(){
        for overlay:MKOverlay in self.overlays  {
            self.remove(overlay)
        }
    }
    
}

extension UIApplication {
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}

public extension UIWindow {
    
    func captureWindow() -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(self.frame.size, self.isOpaque, UIScreen.main.scale)
        self.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
}

public extension UIView {
    
    func capture() -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(self.frame.size, self.isOpaque, UIScreen.main.scale)
        self.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
}

extension Data
{
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
}

extension Array {
    mutating func delete(element: Int) {
        self = self.filter() { $0 as! Int != element }
    }
    
    func jsonString() -> String {
        
        let jsonData = try! JSONSerialization.data(withJSONObject: self, options: JSONSerialization.WritingOptions.prettyPrinted)
        var JSONString:String!
        //Convert back to string. Usually only do this for debugging
        if let strJson = String(data: jsonData, encoding: String.Encoding.utf8) {
            print(strJson)
            JSONString = strJson
        }
//        do {
//            //In production, you usually want to try and cast as the root data structure. Here we are casting as a dictionary. If the root object is an array cast as [AnyObject].
//            //var json = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String: AnyObject]
//        } catch {
//            print(error.localizedDescription)
//        }
        
        return JSONString
    }
    
}

extension UILabel {
    
    func isTruncated() -> Bool {
        
        if let string = self.text {
            
            let size: CGSize = (string as NSString).boundingRect(
                with: CGSize(width: self.frame.size.width, height: CGFloat.greatestFiniteMagnitude),
                options: NSStringDrawingOptions.usesLineFragmentOrigin,
                attributes: [NSFontAttributeName: self.font],
                context: nil).size
            
            return (size.height > self.bounds.size.height)
        }
        
        return false
    }
    
}

extension UITextField {
    
    func isTruncated() -> Bool {
        
        if let string = self.text {
            
            let size: CGSize = (string as NSString).boundingRect(
                with: CGSize(width: self.frame.size.width, height: CGFloat.greatestFiniteMagnitude),
                options: NSStringDrawingOptions.usesLineFragmentOrigin,
                attributes: [NSFontAttributeName: self.font!],
                context: nil).size
            
            return (size.height > self.bounds.size.height)
        }
        
        return false
    }
    
}

extension UIToolbar {
    
    func ToolbarPiker(selector : Selector) -> UIToolbar {
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor.black
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: selector)
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        
        toolBar.setItems([ spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        return toolBar
    }
    
    func addDoneButton(_ closure: @escaping ()->()) -> UIToolbar  {
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor.black
        toolBar.sizeToFit()
        let sleeve = ClosureSleeve(closure)
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: sleeve, action: #selector(ClosureSleeve.invoke))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        
        toolBar.setItems([ spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        objc_setAssociatedObject(toolBar, String(format: "[%d]", arc4random()), sleeve, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        return toolBar
    }
    
    
}

class ClosureSleeve {
    let closure: ()->()
    
    init (_ closure: @escaping ()->()) {
        self.closure = closure
    }
    
    @objc func invoke () {
        closure()
    }
}

extension UIControl {
    func add(for controlEvents: UIControlEvents, _ closure: @escaping ()->()) {
        let sleeve = ClosureSleeve(closure)
        addTarget(sleeve, action: #selector(ClosureSleeve.invoke), for: controlEvents)
        objc_setAssociatedObject(self, String(format: "[%d]", arc4random()), sleeve, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
    }
}


extension UIView {
    
    func dropShadow() {

        let lineWidth: CGFloat = 1
        let shapeLayer = CAShapeLayer()
        self.layer.addSublayer(shapeLayer)
        let path : UIBezierPath = UIBezierPath(rect: frame)
        shapeLayer.path = path.cgPath
        shapeLayer.lineWidth = lineWidth
        shapeLayer.strokeColor = UIColor.lightGray.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        
        shapeLayer.shadowColor = UIColor(white: 0.0, alpha: 1).cgColor
        shapeLayer.shadowRadius = 10.0
//        shapeLayer.layer.shadowPath = CGPath(rect: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height), transform: nil)
        shapeLayer.shadowOpacity = 1.0
        shapeLayer.shadowOffset = CGSize(width: 1, height: 1)

    }
    
    func elevate(elevation: Double) {
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: elevation)
        self.layer.shadowRadius = CGFloat(elevation)
        self.layer.shadowOpacity = 0.24
    }
}


extension Int {
    func randomIntFrom(start: Int, to end: Int) -> Int {
        var a = start
        var b = end
        // swap to prevent negative integer crashes
        if a > b {
            swap(&a, &b)
        }
        return Int(arc4random_uniform(UInt32(b - a + 1))) + a
    }
}



