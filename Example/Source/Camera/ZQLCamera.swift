//
//  ZQLCamera.swift
//  GLESImageKit_Example
//
//  Created by zang qilong on 2017/11/20.
//  Copyright © 2017年 CocoaPods. All rights reserved.
//

import UIKit
import AVFoundation

protocol ZQLCameraDelegate {
    func didOutputSample(sampleBuffer:CMSampleBuffer)
}

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
    let videoConnection:AVCaptureConnection
    
    let microphoneDevice:AVCaptureDevice
    let audioDeviceInput:AVCaptureDeviceInput
    let audioDataOutput:AVCaptureAudioDataOutput
    let audioConnection:AVCaptureConnection
    
    let context = ZQLGLContext.shared
    
    let semaphore = DispatchSemaphore(value: 1)
    
    public var delegate:ZQLCameraDelegate?
    
    init(sessionPreset:AVCaptureSession.Preset, videoDevice:PhysicalVideoDeviceType = .backCamera) throws {
        
        session.beginConfiguration()
         /// Video Device Initialize
        if let videoDevice = videoDevice.device() {
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
        videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
        videoDataOutput.alwaysDiscardsLateVideoFrames = false
        
        if session.canAddOutput(videoDataOutput) {
            session.addOutput(videoDataOutput)
        }
        videoConnection = videoDataOutput.connection(with: AVMediaType.video)!
        
        audioDataOutput = AVCaptureAudioDataOutput()
        if session.canAddOutput(audioDataOutput) {
            session.addOutput(audioDataOutput)
        }
        
        audioConnection = audioDataOutput.connection(with: AVMediaType.audio)!
        
        session.sessionPreset = sessionPreset
        session.commitConfiguration()
        
        super.init()
        
        videoDataOutput.setSampleBufferDelegate(self, queue: videoQueue)
        audioDataOutput.setSampleBufferDelegate(self, queue: audioQueue)
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
        if connection == videoConnection {
            guard (semaphore.wait(timeout:DispatchTime.now()) == DispatchTimeoutResult.success) else { return }
            delegate?.didOutputSample(sampleBuffer: sampleBuffer)
            semaphore.signal()
        }else {
            
        }
    }
}

extension ZQLCamera: AVCaptureAudioDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
    }
}
