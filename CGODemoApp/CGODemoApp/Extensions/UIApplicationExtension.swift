//
//  UIApplicationExtension.swift
//  CGODemoApp
//
//  Created by rajkumar.sharma on 5/10/18.
//  Copyright © 2018 rajkumar.sharma. All rights reserved.
//


import UIKit

extension UIApplication {
    
    class func setupReachability() {
        // Allocate a reachability object
        let reach = Reachability.forInternetConnection()
        APPDELEGATE.isReachable = reach!.isReachable()
        
        // Set the blocks
        reach?.reachableBlock = { (reachability) in
            
            DispatchQueue.main.async(execute: {
                APPDELEGATE.isReachable = true
            })
        }
        reach?.unreachableBlock = { (reachability) in
            DispatchQueue.main.async(execute: {
                APPDELEGATE.isReachable = false
            })
        }
        reach?.startNotifier()
    }
}
