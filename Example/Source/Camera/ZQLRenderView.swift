//
//  ZQLRenderView.swift
//  GLESImageKit_Example
//
//  Created by zang qilong on 2017/11/24.
//  Copyright © 2017年 CocoaPods. All rights reserved.
//

import UIKit
import AVFoundation
import OpenGLES

struct RenderSize {
    let width:GLint
    let height:GLint
    
    init(width:GLint, height:GLint) {
        self.width = width
        self.height = height
    }
}

enum RenderViewFillMode {
    case aspectRatio
    case aspectFill
    case stretch
    
    
}

class ZQLRenderView: UIView {
    
    var currentFrameBuffer:GLuint?
    var currentRenderBuffer:GLuint?
    var renderSize:RenderSize?
    var fillMode:RenderViewFillMode = .stretch

    override public class var layerClass: AnyClass {
        get {
            return CAEAGLLayer.self
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }

    func commonInit() {
        let eaglLayer = self.layer as! CAEAGLLayer
        eaglLayer.isOpaque = true
        eaglLayer.drawableProperties = [kEAGLDrawablePropertyRetainedBacking: false, kEAGLDrawablePropertyColorFormat: kEAGLColorFormatRGBA8]

    }
    
    func createBuffer() {
        var newFrameBuffer:GLuint = 0
        glGenFramebuffers(1, &newFrameBuffer)
        currentFrameBuffer = newFrameBuffer
        glBindBuffer(GLenum(GL_FRAMEBUFFER), newFrameBuffer)
        
        var newRenderBuffer:GLuint = 0
        glGenRenderbuffers(1, &newRenderBuffer)
        currentRenderBuffer = newRenderBuffer
        glBindBuffer(GLenum(GL_RENDERBUFFER), newRenderBuffer)
        
        ZQLSharedGLContext.shared.context.renderbufferStorage(Int(GL_RENDERBUFFER), from: self.layer as! CAEAGLLayer)
        
        var renderWidth:GLint = 0
        var renderHeight:GLint = 0
        
        glGetRenderbufferParameteriv(GLenum(GL_RENDERBUFFER), GLenum(GL_RENDERBUFFER_WIDTH), &renderWidth)
        glGetRenderbufferParameteriv(GLenum(GL_RENDERBUFFER), GLenum(GL_RENDERBUFFER_HEIGHT), &renderHeight)
        renderSize = RenderSize(width: renderWidth, height: renderHeight)
        
        guard (renderWidth > 0 && renderHeight > 0) else {
            fatalError("View init error")
        }
        
        glFramebufferRenderbuffer(GLenum(GL_FRAMEBUFFER), GLenum(GL_COLOR_ATTACHMENT0), GLenum(GL_RENDERBUFFER), currentRenderBuffer!)
        
        let status = glCheckFramebufferStatus(GLenum(GL_FRAMEBUFFER))
        if (status != GLenum(GL_FRAMEBUFFER_COMPLETE)) {
            fatalError("Display framebuffer creation failed with error: \(status)")
        }
        
    }
    
    func renderQuad(program:ZQLGLESProgram, vertices:[GLfloat]) {
        
    }
}
