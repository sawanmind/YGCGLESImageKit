//
//  ViewController.swift
//  GLESImageKit
//
//  Created by zang qilong on 11/20/2017.
//  Copyright (c) 2017 zang qilong. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    var camera:ZQLCamera!
    var previewLayer:AVCaptureVideoPreviewLayer!

    override func viewDidLoad() {
        super.viewDidLoad()
        camera = try! ZQLCamera(sessionPreset: AVCaptureSession.Preset.photo)
        previewLayer = AVCaptureVideoPreviewLayer(session: camera.session)
        previewLayer.bounds = UIScreen.main.bounds
        previewLayer.position = self.view.center
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.view.layer.addSublayer(previewLayer)
        camera.startCapture()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

