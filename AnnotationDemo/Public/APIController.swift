//
//  APIController.swift
//  Thyssenkrupp
//
//  Created by Varun Naharia on 17/03/17.
//  Copyright © 2017 Varun Naharia. All rights reserved.
//

import UIKit

class APIController: NSObject {
    
    func addPlace(placeName:String, userId:String,lvl:String, unit:String, address:String, lati:String, lng:String, imageList:[[String:Any]], successHandler: @escaping (_ json:JSON) -> Void) {
        let parameters: [String:Any] =
            ["placeName":placeName, "userId":userId,"lvl":lvl, "unit":unit, "address":address, "lati":lati, "lng":lng, "imageList":imageList.jsonString()]
        ServiceManager.requestWithPost(baseURL:nil, methodName: "MaxServiceASMX.asmx/AddPlace", parameter: parameters, isHUD: true) { (jsonResponse) in
            print(jsonResponse)
            if(jsonResponse["status"].string == "1")
            {
                successHandler(jsonResponse)
            }
            else
            {
                ServiceManager.alert(message: jsonResponse["message"].string!)
            }
        }
    }
    
    func uploadImage(image:UIImage, successHandler: @escaping (_ imageName:String) -> Void) {
        
        let parameters: [String:Any] =
            [:]
        ServiceManager.requestWithPostMultipart(baseURL:nil, methodName: "PostedPlaceImage.aspx", image: image, parameter: parameters, isHUD: true) { (jsonResponse) in
            print(jsonResponse)
            if(jsonResponse["status"].string == "1")
            {
                let imageName = jsonResponse["data"].string
                successHandler(imageName!)
            }
            else
            {
                if(jsonResponse["message"] != JSON.null)
                {
                    ServiceManager.alert(message: jsonResponse["message"].string!)
                }
            }
        }
    }
    
    func getAllAddedPlace(successHandler: @escaping (_ json:JSON) -> Void) {
        let parameters: [String:Any] =
            ["userid":"57"]
        ServiceManager.requestWithGet(baseURL: nil, methodName: "MaxServiceASMX.asmx/GetAllAddedPlace", parameter: parameters, isHUD: true) {  (jsonResponse) in
            
            print(jsonResponse)
            if(jsonResponse["status"].string == "1")
            {
                successHandler(jsonResponse)
            }
            else
            {
                ServiceManager.alert(message: jsonResponse["message"].string!)
            }
        }
    }
    
    func getNearbyPlace(latitude:String, longitude:String, radius:String, successHandler: @escaping (_ json:JSON) -> Void) {
        let parameters: [String:Any] =
            ["userid":"57", "longitude":longitude, "latitude":latitude, "radius":radius]
        ServiceManager.requestWithGet(baseURL: nil, methodName: "MaxServiceASMX.asmx/GetNearByPlaces", parameter: parameters, isHUD: true) {  (jsonResponse) in
            
            print(jsonResponse)
            if(jsonResponse["status"].string == "1")
            {
                successHandler(jsonResponse)
            }
            else
            {
                ServiceManager.alert(message: jsonResponse["message"].string!)
            }
        }
    }
    
}
