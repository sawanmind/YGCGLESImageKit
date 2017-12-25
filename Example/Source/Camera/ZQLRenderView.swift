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
    case scaleFill
}

class ZQLRenderView: UIView {
    
    var currentFrameBuffer:GLuint?
    var currentRenderBuffer:GLuint?
    var renderSize:RenderSize?
    var fillMode:RenderViewFillMode = .scaleFill
    let shaderProgram:ZQLGLESProgram
    var vertices:[GLfloat] = [
        -1.0, -1.0, // bottom left
        1.0, -1.0, // bottom right
        -1.0,  1.0, // top left
        1.0,  1.0, // top right
    ]
    
    var textureCoordinate:[GLfloat] = [
        0.0, 0.0, // bottom left
        1.0, 0.0, // bottom right
        0.0,  1.0, // top left
        1.0,  1.0, // top right
    ]

    override public class var layerClass:Swift.AnyClass {
        get {
            return CAEAGLLayer.self
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        shaderProgram = try! ZQLGLESProgram(vertex: "baseVertexShader.vsh", fragment: "baseFragmentShader.fsh")
        super.init(coder: aDecoder)
       commonInit()
        
    }
    
    override init(frame: CGRect) {
        shaderProgram = try! ZQLGLESProgram(vertex: "baseVertexShader.vsh", fragment: "baseFragmentShader.fsh")
        super.init(frame: frame)
        commonInit()
        self.backgroundColor = UIColor.yellow
        
    }

    func commonInit() {
        let eaglLayer = self.layer as! CAEAGLLayer
        eaglLayer.isOpaque = true
        eaglLayer.drawableProperties = [kEAGLDrawablePropertyRetainedBacking: false, kEAGLDrawablePropertyColorFormat: kEAGLColorFormatRGBA8]
        
        createBuffer()
        

    }
    
    func createBuffer() {
        var newFrameBuffer:GLuint = 0
        glGenFramebuffers(1, &newFrameBuffer)
        currentFrameBuffer = newFrameBuffer
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), currentFrameBuffer!)
        
        var newRenderBuffer:GLuint = 0
        glGenRenderbuffers(1, &newRenderBuffer)
        currentRenderBuffer = newRenderBuffer
        glBindRenderbuffer(GLenum(GL_RENDERBUFFER), currentRenderBuffer!)
        
        ZQLGLContext.shared.context.renderbufferStorage(Int(GL_RENDERBUFFER), from: self.layer as! CAEAGLLayer)
        
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
    
    func displayCVPixel(sampleBuffer:CMSampleBuffer) {
        guard let frameBuffer = currentFrameBuffer else {
            fatalError("frame buffer not intialized")
        }
        
        guard let positionSlot = shaderProgram.attributeLocation(attribute: "a_Position"), let textureCoordinateSlot = shaderProgram.attributeLocation(attribute: "a_TexCoordIn") else {
            fatalError("vertex has not position slot")
        }
        
        guard let textureSlot = shaderProgram.uniformLocation(uniform: "u_Texture") else {
            fatalError("fragment has not texture slot")
        }
        
        let pixel = CMSampleBufferGetImageBuffer(sampleBuffer)!
        let bufferWidth = CVPixelBufferGetWidth(pixel)
        let bufferHeight = CVPixelBufferGetHeight(pixel)
     //   CVPixelBufferLockBaseAddress(pixel, CVPixelBufferLockFlags(rawValue: CVOptionFlags(0)))
        checkPixelBuffer(pixel: pixel)
        var cvTexture:CVOpenGLESTexture? = nil
        let error = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault, ZQLGLContext.shared.textureCache, pixel, nil, GLenum(GL_TEXTURE_2D), GL_RGBA, GLsizei(bufferWidth), GLsizei(bufferHeight), GLenum(GL_BGRA), GLenum(GL_UNSIGNED_BYTE), 0, &cvTexture)
        if error == kCVReturnError || cvTexture == nil {
            fatalError("texture cache create texture error")
        }
        
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), frameBuffer)
        glViewport(0, 0, Int32(renderSize!.width), Int32(renderSize!.height))
        shaderProgram.use()
        
        glActiveTexture(GLenum(GL_TEXTURE0))
        glBindTexture(CVOpenGLESTextureGetTarget(cvTexture!), CVOpenGLESTextureGetName(cvTexture!))
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GL_LINEAR)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MAG_FILTER), GL_LINEAR)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_S), GL_CLAMP_TO_EDGE)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_T), GL_CLAMP_TO_EDGE)
        glUniform1i(textureSlot, 0)
        
        
        
        glVertexAttribPointer(GLuint(positionSlot), 2, GLenum(GL_FLOAT), 0, 0, vertices)
        glEnableVertexAttribArray(GLuint(positionSlot))
        
        glVertexAttribPointer(GLuint(textureCoordinateSlot), 2, GLenum(GL_FLOAT), 0, 0, textureCoordinate)
        glEnableVertexAttribArray(GLuint(textureCoordinateSlot))
        
        glDrawArrays( GLenum(GL_TRIANGLE_STRIP), 0, 4 );
        glBindRenderbuffer(GLenum(GL_RENDERBUFFER), currentRenderBuffer!)
        ZQLGLContext.shared.context.presentRenderbuffer(Int(GL_RENDERBUFFER))
        
//        glBindTexture( CVOpenGLESTextureGetTarget(cvTexture!), 0 );
//        glBindTexture(GLenum(GL_TEXTURE_2D), 0)
//        CVPixelBufferUnlockBaseAddress(pixel, CVPixelBufferLockFlags(rawValue: CVOptionFlags(0)))
//        glFlush()
    }
    
    func checkPixelBuffer(pixel:CVPixelBuffer){
        
        if CVPixelBufferGetPixelFormatType(pixel) != kCVPixelFormatType_32BGRA {
            fatalError("pixel foramt error")
        }
    }
    
    
    func renderQuad() {
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), currentFrameBuffer!)
        glViewport(0, 0, Int32(renderSize!.width), Int32(renderSize!.height))
        shaderProgram.use()
        guard let positionSlot = shaderProgram.attributeLocation(attribute: "a_Position"), let textureCoordinateSlot = shaderProgram.attributeLocation(attribute: "a_TexCoordIn") else {
            fatalError("vertex has not position slot")
        }
        
        glVertexAttribPointer(GLuint(positionSlot), 2, GLenum(GL_FLOAT), 0, 0, vertices)
        glEnableVertexAttribArray(GLuint(positionSlot))
        
        glVertexAttribPointer(GLuint(textureCoordinateSlot), 2, GLenum(GL_FLOAT), 0, 0, textureCoordinate)
        glEnableVertexAttribArray(GLuint(textureCoordinateSlot))
        
        glDrawArrays( GLenum(GL_TRIANGLE_STRIP), 0, 4 );
        ZQLGLContext.shared.context.presentRenderbuffer(Int(GL_RENDERBUFFER))
    }
}
