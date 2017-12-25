//
//  ZQLSharedGLContext.swift
//  GLESImageKit_Example
//
//  Created by zang qilong on 2017/12/14.
//  Copyright © 2017年 CocoaPods. All rights reserved.
//

import Foundation
import OpenGLES
import AVFoundation

class ZQLGLContext {
    static let shared = ZQLGLContext()
    let context:EAGLContext
    
    lazy var textureCache:CVOpenGLESTextureCache = {
        var newTextureCache:CVOpenGLESTextureCache? = nil
        let err = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, nil, ZQLGLContext.shared.context, nil, &newTextureCache)
        return newTextureCache!
    }()
    
    private init() {
        context = EAGLContext(api: EAGLRenderingAPI.openGLES2)!
        EAGLContext.setCurrent(context)
    }
    
    public func makeCurrentContext() {
        if (EAGLContext.current() != self.context)
        {
            EAGLContext.setCurrent(self.context)
        }
    }
}
