//
//  Session.swift
//  AnnotationDemo
//
//  Created by Varun Naharia on 30/08/17.
//  Copyright © 2017 Varun Naharia. All rights reserved.
//
//  This file was generated by the DVStarterProject Xcode Templates,
//  see http://technaharia.in
//  Credit: Dinesh Saini, Varun Naharia
import Foundation


extension URLSession{
    
    func dataTask(with request: URLRequest, requestID : Int, completionHandler: @escaping (Data?, URLResponse?, Error?, _ requestID : Int) -> Void){
        let task = self.dataTask(with: request) { (data, res, error) in
            completionHandler(data, res, error, requestID)
        }
        task.resume()
    }
}
