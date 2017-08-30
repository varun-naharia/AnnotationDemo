//
//  ServiceManager.swift
//  Thyssenkrupp
//
//  Created by Varun Naharia on 10/03/17.
//  Copyright © 2017 Varun Naharia. All rights reserved.
//

import UIKit
import Alamofire

class ServiceManager: NSObject,MBProgressHUDDelegate {
    static let baseUrl:String = "http://132.148.80.234:8083/"
    //    static let activityIndicatorView
    //    static let indicator:NVActivityIndicatorView = indicatorView()
    static var HUDCommon = MBProgressHUD()
    func showHUD(){
        let topVC = ServiceManager.topMostController()
        ServiceManager.HUDCommon = MBProgressHUD(view:topVC.view)
        UIApplication.topViewController()?.view.addSubview(ServiceManager.HUDCommon)
        ServiceManager.HUDCommon.mode = .indeterminate
        ServiceManager.HUDCommon.labelText = "Fetching"
        ServiceManager.HUDCommon.show(true)
    }
    
    func hideHUD(){
        ServiceManager.HUDCommon.hide(true)
    }
    
    class func requestWithGet(baseURL:String?, methodName:String , parameter:[String:Any]?, isHUD:Bool, successHandler: @escaping (_ success:JSON) -> Void) {
        let errorDict:[String:Any] = [:]
        var errorJson:JSON = JSON(errorDict)
        if(ReachabilityCheck.sharedInstance.isInternetAvailable())
        {
            let topVC = ServiceManager.topMostController()
            let HUD = MBProgressHUD(view:topVC.view)
            if(isHUD)
            {
               
                //        HUD.color = UIColor(red: 0.06, green: 0.51, blue: 0.81, alpha: 1.00)
                UIApplication.topViewController()?.view.addSubview(HUD)
                HUD.labelText = "Loading"
                HUD.mode = .indeterminate
                HUD.labelText = "Fetching"
                HUD.show(true)
            }
            //        let parameters: Parameters = ["email": txtUsername.text!,"password": txtPassword.text!]
            var jsonResponse:JSON!
            var urlString:String = ""
            if(baseURL != nil)
            {
                if(methodName == "" && parameter == nil)
                {
                    urlString = baseURL!
                }
                else
                {
                    urlString = (baseURL?.appending("\(methodName)?"))!
                }
            }
            else
            {
                if(methodName == "" && parameter == nil)
                {
                    urlString = baseUrl
                }
                else
                {
                    urlString = (baseUrl.appending("\(methodName)?"))
                }
            }
            //            if(parameter != nil)
            //            {
            //                let parameterKey = parameter!.keys
            //                for key in parameterKey {
            //                    urlString =  urlString.appending("\(key)=\(parameter![key]!)&")
            //                }
            //            }
            
            
            Alamofire.request(urlString, method: .get, parameters:parameter, encoding: URLEncoding.default).debugLog().responseJSON { (response:DataResponse<Any>) in
                switch response.result{
                case .failure(let error):
                    print(error)
                    errorJson = ["status":0,"message":error.localizedDescription]
                    successHandler(errorJson)
                    break
                case .success(let value):
                    print(value)
                    let json = JSON(data: response.data!)
                    //                    print("\(json)")
                    jsonResponse = json
                    successHandler(jsonResponse)
                    break
                }
                
                
                HUD.hide(true)
                HUD.removeFromSuperview()
            }
        }
        else
        {
            errorJson = ["status":0,"message":"Network is Unreachable"]
            successHandler(errorJson)
            ServiceManager.alert(message: "Not Connected To Internet")
        }
    }
    
    class func requestWithPost(baseURL:String?, methodName:String , parameter:[String:Any]?, isHUD:Bool, successHandler: @escaping (_ success:JSON) -> Void) {
        let errorDict:[String:Any] = [:]
        var errorJson:JSON = JSON(errorDict)
        if(ReachabilityCheck.sharedInstance.isInternetAvailable())
        {
            let topVC = ServiceManager.topMostController()
            let HUD = MBProgressHUD(view:topVC.view)
            if(isHUD)
            {
                
                //        HUD.color = UIColor(red: 0.06, green: 0.51, blue: 0.81, alpha: 1.00)
                UIApplication.topViewController()?.view.addSubview(HUD)
                HUD.labelText = "Loading"
                HUD.mode = .indeterminate
                HUD.labelText = "Sending"
                HUD.show(true)
            }
            let parameters: Parameters = parameter!
            var jsonResponse:JSON!
            var urlString:String = ""
            if(baseURL != nil)
            {
                if(methodName == "" && parameter == nil)
                {
                    urlString = baseURL!
                }
                else
                {
                    urlString = (baseURL?.appending("\(methodName)?"))!
                }
                
                
            }
            else
            {
                if(methodName == "" && parameter == nil)
                {
                    urlString = baseUrl
                }
                else
                {
                    urlString = (baseUrl.appending("\(methodName)?"))
                }
            }
            
            Alamofire.request(urlString, method: .post,parameters: parameters, encoding: URLEncoding.default).responseJSON { (response:DataResponse<Any>) in
                switch response.result{
                case .failure(let error):
//                    ServiceManager.alert(message: error.localizedDescription)
                    //print(String(data: response.data!, encoding: .utf8)!)
                    print(error)
                    break
                case .success(let value):
                    print(value)
                    let json = JSON(data: response.data!)
                    print("\(json)")
                    jsonResponse = json
                    break
                }
                if(jsonResponse != nil && jsonResponse != JSON.null)
                {
                    successHandler(jsonResponse)
                }
                HUD.hide(true)
                HUD.removeFromSuperview()
            }
        }
        else
        {
            errorJson = ["status":0,"message":"Network is Unreachable"]
            successHandler(errorJson)
            ServiceManager.alert(message: "Not Connected To Internet")
        }
    }
    
    class func requestWithPostMultipart(baseURL:String?, methodName:String , image:UIImage, parameter:[String:Any]?, isHUD:Bool, successHandler: @escaping (_ success:JSON) -> Void) {
        if(ReachabilityCheck.sharedInstance.isInternetAvailable())
        {
            let topVC = ServiceManager.topMostController()
            let HUD = MBProgressHUD(view:topVC.view)
            if(isHUD)
            {
                
                //        HUD.color = UIColor(red: 0.06, green: 0.51, blue: 0.81, alpha: 1.00)
                UIApplication.topViewController()?.view.addSubview(HUD)
                HUD.mode = .annularDeterminate
                HUD.labelText = "Uploading"
                HUD.show(true)
            }
            let parameters: Parameters = parameter!
            var jsonResponse:JSON!
            var urlString:String = ""
            if(baseURL != nil)
            {
                if(methodName == "" && parameter == nil)
                {
                    urlString = baseURL!
                }
                else
                {
                    urlString = (baseURL?.appending("\(methodName)?"))!
                }
                
                
            }
            else
            {
                if(methodName == "" && parameter == nil)
                {
                    urlString = baseUrl
                }
                else
                {
                    urlString = (baseUrl.appending("\(methodName)?"))
                }
            }
            
            Alamofire.upload(multipartFormData: { (multipartFormData) in
                multipartFormData.append(UIImageJPEGRepresentation(image, 0.5)!, withName: "image", fileName: "image.jpeg", mimeType: "image/jpeg")
//                multipartFormData.append(video, withName: "video", fileName: "video.mov", mimeType: "video/mp4")
                for (key, value) in parameters {
                    multipartFormData.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key)
                }
            }, to: urlString, method: .post , headers:nil, encodingCompletion: { (result) in
                switch result {
                case .success(let upload, _, _):
                    
                    upload.uploadProgress(closure: { (progress) in
                        print(progress.fractionCompleted * 100)
                        HUD.progress = Float(progress.fractionCompleted)
                    })
                    
                    upload.responseJSON(completionHandler: { (response) in
                        if(response.data != nil)
                        {
                            let json = JSON(data: response.data!)
                            print("\(json)")
                            jsonResponse = json
                            HUD.hide(true)
                            HUD.removeFromSuperview()
                            successHandler(jsonResponse)
                        }
                    })
                case .failure(let error):
                    print(error)
                    HUD.hide(true)
                    HUD.removeFromSuperview()
                    
                }
            })
        }
        else
        {
            ServiceManager.alert(message: "Not Connected To Internet")
        }
    }
    
    
    class func topMostController() -> UIViewController {
        var topController: UIViewController? = UIApplication.shared.keyWindow?.rootViewController
        while ((topController?.presentedViewController) != nil) {
            topController = topController?.presentedViewController
        }
        return topController!
    }
    
    class func alert(message:String){
        let alert=UIAlertController(title: "Maxting", message: message, preferredStyle: .alert);
        let cancelAction: UIAlertAction = UIAlertAction(title: "OK", style: .cancel) { action -> Void in
            
        }
        alert.addAction(cancelAction)
        ServiceManager.topMostController().present(alert, animated: true, completion: nil);
    }
}
