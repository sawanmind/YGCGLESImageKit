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
    var renderView:ZQLRenderView!

    override func viewDidLoad() {
        super.viewDidLoad()
        ZQLGLContext.shared.makeCurrentContext()
        camera = try! ZQLCamera(sessionPreset: AVCaptureSession.Preset.photo)
        camera.delegate = self
        renderView = ZQLRenderView(frame: self.view.bounds)
        self.view.addSubview(renderView)
      //  renderView.renderQuad()
        camera.startCapture()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension ViewController: ZQLCameraDelegate {
    func didOutputSample(sampleBuffer: CMSampleBuffer) {
        renderView.displayCVPixel(sampleBuffer: sampleBuffer)
    }
}
