//
//  NoInternetView.swift
//  AnnotationDemo
//
//  Created by Varun Naharia on 30/08/17.
//  Copyright © 2017 Varun Naharia. All rights reserved.
//
//  This file was generated by the DVStarterProject Xcode Templates,
//  see http://technaharia.in
//  Credit: Dinesh Saini, Varun Naharia

import UIKit

class NoInternetView: UIView {

    @IBOutlet weak var lblNoInViewTitle : UILabel!
    @IBOutlet weak var lblNoInViewDescription : UILabel!
    
    @IBOutlet weak var imgView : UIImageView!
    
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    class func loadFromXIB() -> NoInternetView{
        return Bundle.main.loadNibNamed("NoInternetView", owner: nil, options: nil)!.first as! NoInternetView
    }
    
    @IBAction func retryInternet(_ sender : UIButton) -> Void{
        let reachability = Reachability()!
        switch reachability.currentReachabilityStatus {
        case .reachableViaWiFi, .reachableViaWWAN:
            self.removeFromSuperview()
            break
        default:
            break
        }
    }
}
