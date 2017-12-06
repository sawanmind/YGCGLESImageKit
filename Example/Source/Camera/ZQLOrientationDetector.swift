//
//  ZQLOrientationDetector.swift
//  GLESImageKit_Example
//
//  Created by zang qilong on 2017/11/24.
//  Copyright © 2017年 CocoaPods. All rights reserved.
//

import Foundation
import CoreMotion
import UIKit

class ZQLOrientationDetector {
    let motionManager = CMMotionManager()
    private(set) var lastOrientation = UIApplication.shared.statusBarOrientation
    
    init() {
        motionManager.accelerometerUpdateInterval = 0.2
        motionManager.gyroUpdateInterval = 0.2
    }
    
    deinit {
        stopDetector()
    }
    
    func startDetector() {
        motionManager.startAccelerometerUpdates(to: OperationQueue.main) { [unowned self](data, error) in
            if let dataExist = data {
                self.currentOrientationDetector(data: dataExist)
            }
            
        }
    }
    
    func stopDetector() {
        motionManager.stopAccelerometerUpdates()
    }
    
    private func currentOrientationDetector(data:CMAccelerometerData) {
        var newOrientation = UIApplication.shared.statusBarOrientation;
        if data.acceleration.x >= 0.75 {
            newOrientation = UIInterfaceOrientation.landscapeLeft
        }else if data.acceleration.x <= -0.75 {
            newOrientation = UIInterfaceOrientation.landscapeRight
        }else if data.acceleration.y <= -0.75 {
            newOrientation = UIInterfaceOrientation.portrait
        }else if data.acceleration.y >= 0.75 {
            newOrientation = UIInterfaceOrientation.portraitUpsideDown
        }
        
        if newOrientation == lastOrientation {
            return
        }
        
        lastOrientation = newOrientation
        
    }
}
