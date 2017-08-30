//
//  CustomPointAnnotation.swift
//  Maxting
//
//  Created by Varun Naharia on 17/04/17.
//  Copyright © 2017 Logictrix. All rights reserved.
//

import UIKit
import Foundation
import MapKit

class CustomPointAnnotation: MKPointAnnotation {
    var data:JSON?
    var index:Int?
    var distance:CLLocationDistance!
    var imageName:String!
    var annotation:MKAnnotation!
    
    func calculateDistance(fromLocation: CLLocation?)
    {
        let location = CLLocation(latitude: self.coordinate.latitude, longitude: self.coordinate.longitude)
        distance =  location.distance(from: fromLocation!)
    }

}
