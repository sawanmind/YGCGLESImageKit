//
//  ZQLCamera.swift
//  GLESImageKit_Example
//
//  Created by zang qilong on 2017/11/20.
//  Copyright © 2017年 CocoaPods. All rights reserved.
//

import UIKit
import AVFoundation

enum GLESImageKitError:Error {
    case deviceNotFind
}

class ZQLCamera: NSObject {
    let sessionQueue = DispatchQueue(label: "com.glesImageKit.sessionQueue")
    let videoQueue = DispatchQueue(label: "com.glesImageKit.videoQueue")
    let audioQueue = DispatchQueue(label: "com.glesImageKit.audioQueue")
    
    let session = AVCaptureSession()
    
    let cameraDevice:AVCaptureDevice
    let cameraDeviceInput:AVCaptureDeviceInput
    let videoDataOutput:AVCaptureVideoDataOutput
    
    let microphoneDevice:AVCaptureDevice
    let audioDeviceInput:AVCaptureDeviceInput
    
    let videoDeviceDiscoverySession:AVCaptureDevice.DiscoverySession
    
    let context = ZQLSharedGLContext.shared
    
    init(sessionPreset:AVCaptureSession.Preset) throws {
        
        session.beginConfiguration()
         /// Video Device Initialize
        let deviceTypes = [AVCaptureDevice.DeviceType.builtInWideAngleCamera, AVCaptureDevice.DeviceType.builtInDualCamera, AVCaptureDevice.DeviceType.builtInTelephotoCamera]
        videoDeviceDiscoverySession = AVCaptureDevice.DiscoverySession.init(deviceTypes: deviceTypes, mediaType: AVMediaType.video, position: AVCaptureDevice.Position.unspecified)
        if let videoDevice = AVCaptureDevice.default(AVCaptureDevice.DeviceType.builtInWideAngleCamera, for: AVMediaType.video, position: AVCaptureDevice.Position.unspecified) {
            self.cameraDevice = videoDevice
        }else {
            throw GLESImageKitError.deviceNotFind
        }
        
        do {
            cameraDeviceInput = try AVCaptureDeviceInput(device: cameraDevice)
        } catch  {
            throw error
        }
        
        /// Audio Device Initialize
        if let audioDevice = AVCaptureDevice.default(AVCaptureDevice.DeviceType.builtInMicrophone, for: AVMediaType.audio, position: AVCaptureDevice.Position.unspecified) {
            self.microphoneDevice = audioDevice
        }else {
            throw GLESImageKitError.deviceNotFind
        }
        
        do {
            audioDeviceInput = try AVCaptureDeviceInput(device: microphoneDevice)
        } catch  {
            throw error
        }
        
        if session.canAddInput(cameraDeviceInput) {
            session.addInput(cameraDeviceInput)
        }else {
            print("can't add camera deivce")
        }
        
        if session.canAddInput(audioDeviceInput) {
            session.addInput(audioDeviceInput)
        }else {
            print("can't add audio deivce")
        }
        
        videoDataOutput = AVCaptureVideoDataOutput()
        videoDataOutput.videoSettings = 
        videoDataOutput.alwaysDiscardsLateVideoFrames = false
        
        if session.canAddOutput(videoDataOutput) {
            session.addOutput(videoDataOutput)
        }
        
        session.sessionPreset = sessionPreset
        session.commitConfiguration()
        
        super.init()
        
        videoDataOutput.setSampleBufferDelegate(self, queue: videoQueue)
        
    }
    
    func startCapture() {
        sessionQueue.async {
            if !self.session.isRunning {
                self.session.startRunning()
            }
        }
    }
    
    func stopCapture() {
        sessionQueue.async {
            if self.session.isRunning {
                self.session.stopRunning()
            }
        }
    }

}

extension ZQLCamera: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
    }
}
