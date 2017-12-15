//
//  ZQLSharedGLContext.swift
//  GLESImageKit_Example
//
//  Created by zang qilong on 2017/12/14.
//  Copyright © 2017年 CocoaPods. All rights reserved.
//

import Foundation
import OpenGLES

class ZQLSharedGLContext {
    static let shared = ZQLSharedGLContext()
    let context:EAGLContext
    
    private init() {
        context = EAGLContext(api: EAGLRenderingAPI.openGLES2)!
        EAGLContext.setCurrent(context)
    }
}
