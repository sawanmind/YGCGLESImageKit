//
//  ZQLCameraConfigure.swift
//  GLESImageKit_Example
//
//  Created by zang qilong on 2017/11/22.
//  Copyright © 2017年 CocoaPods. All rights reserved.
//

import Foundation
import AVFoundation

public enum PhysicalVideoDeviceType {
    case backCamera
    case frontCamera
    
    func imageOrientation() -> ImageOrientation {
        switch self {
        case .backCamera: return .landscapeRight
        case .frontCamera: return .landscapeLeft
        }
    }
    
    func captureDevicePosition() -> AVCaptureDevice.Position {
        switch self {
        case .backCamera: return .back
        case .frontCamera: return .front
        }
    }
    
    func device() -> AVCaptureDevice? {
        if let videoDevice = AVCaptureDevice.default(AVCaptureDevice.DeviceType.builtInWideAngleCamera, for: AVMediaType.video, position: self.captureDevicePosition()) {
            return videoDevice
        }else {
            return nil
        }
    }
}

public enum ImageOrientation {
    case portrait
    case portraitUpsideDown
    case landscapeLeft
    case landscapeRight
    
    func rotationNeededForOrientation(_ targetOrientation:ImageOrientation) -> Rotation {
        switch (self, targetOrientation) {
        case (.portrait, .portrait), (.portraitUpsideDown, .portraitUpsideDown), (.landscapeLeft, .landscapeLeft), (.landscapeRight, .landscapeRight): return .noRotation
        case (.portrait, .portraitUpsideDown): return .rotate180
        case (.portraitUpsideDown, .portrait): return .rotate180
        case (.portrait, .landscapeLeft): return .rotateCounterclockwise
        case (.landscapeLeft, .portrait): return .rotateClockwise
        case (.portrait, .landscapeRight): return .rotateClockwise
        case (.landscapeRight, .portrait): return .rotateCounterclockwise
        case (.landscapeLeft, .landscapeRight): return .rotate180
        case (.landscapeRight, .landscapeLeft): return .rotate180
        case (.portraitUpsideDown, .landscapeLeft): return .rotateClockwise
        case (.landscapeLeft, .portraitUpsideDown): return .rotateCounterclockwise
        case (.portraitUpsideDown, .landscapeRight): return .rotateCounterclockwise
        case (.landscapeRight, .portraitUpsideDown): return .rotateClockwise
        }
    }
}

public enum Rotation {
    case noRotation
    case rotateCounterclockwise
    case rotateClockwise
    case rotate180
    case flipHorizontally
    case flipVertically
    case rotateClockwiseAndFlipVertically
    case rotateClockwiseAndFlipHorizontally
    
    func flipsDimensions() -> Bool {
        switch self {
        case .noRotation, .rotate180, .flipHorizontally, .flipVertically: return false
        case .rotateCounterclockwise, .rotateClockwise, .rotateClockwiseAndFlipVertically, .rotateClockwiseAndFlipHorizontally: return true
        }
    }
}
