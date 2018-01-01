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
    
    let verticallyInvertedImageVertices:[GLfloat] = [-1.0, 1.0, 1.0, 1.0, -1.0, -1.0, 1.0, -1.0]
    
    var textureCoordinate:[GLfloat] = [
        0.0, 0.0, // bottom left
        1.0, 0.0, // bottom right
        0.0,  1.0, // top left
        1.0,  1.0, // top right
    ]
    
    //var textureCoordinate:[GLfloat] = [0.0, 1.0, 1.0, 1.0,0.0, 0.0, 1.0, 0.0]
    let rotateVertices:[GLfloat] = [1.0, -1.0, 1, 1, -1,-1,1,-1]
    var rotateCoordinate:[GLfloat] =  [1.0, 0.0, 1.0, 1.0, 0.0, 0.0, 0.0, 1.0]

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
        
        if !Thread.isMainThread{
            DispatchQueue.main.sync {
                guard let frameBuffer = currentFrameBuffer else {
                    fatalError("frame buffer not intialized")
                }
                
                guard let positionSlot = shaderProgram.attributeLocation(attribute: "a_Position"), let textureCoordinateSlot = shaderProgram.attributeLocation(attribute: "a_TexCoordIn") else {
                    fatalError("vertex has not position slot")
                }
                
                guard let textureSlot = shaderProgram.uniformLocation(uniform: "u_Texture") else {
                    fatalError("fragment has not texture slot")
                }
                
                
                glBindFramebuffer(GLenum(GL_FRAMEBUFFER), frameBuffer)
                glViewport(0, 0, Int32(renderSize!.width), Int32(renderSize!.height))
                shaderProgram.use()
                
                let pixel = CMSampleBufferGetImageBuffer(sampleBuffer)!
                let bufferWidth = CVPixelBufferGetWidth(pixel)
                let bufferHeight = CVPixelBufferGetHeight(pixel)
                checkPixelBuffer(pixel: pixel)
                var cvTexture:CVOpenGLESTexture? = nil
                let error = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                    ZQLGLContext.shared.textureCache,
                    pixel,
                    nil,
                    GLenum(GL_TEXTURE_2D),
                    GL_RGBA,
                    GLsizei(bufferWidth),
                    GLsizei(bufferHeight),
                    GLenum(GL_BGRA),
                    GLenum(GL_UNSIGNED_BYTE),
                    0,
                    &cvTexture)
                if error == kCVReturnError || cvTexture == nil {
                    fatalError("texture cache create texture error")
                }
            
                glActiveTexture(GLenum(GL_TEXTURE5))
                glBindTexture(CVOpenGLESTextureGetTarget(cvTexture!), CVOpenGLESTextureGetName(cvTexture!))
                glUniform1i(textureSlot, 5)
                
                glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GL_LINEAR)
                glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MAG_FILTER), GL_LINEAR)
                glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_S), GL_CLAMP_TO_EDGE)
                glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_T), GL_CLAMP_TO_EDGE)
                
                
                glVertexAttribPointer(positionSlot, 2, GLenum(GL_FLOAT), 0, 0, vertices)
                glEnableVertexAttribArray(GLuint(positionSlot))
                
                var textureSamplingSize:CGSize = CGSize.zero
                let cropScaleAmount = CGSize(width: self.bounds.size.width / CGFloat(bufferWidth), height: self.bounds.size.height / CGFloat(bufferHeight));
                if ( cropScaleAmount.height > cropScaleAmount.width ) {
                    textureSamplingSize.width = self.bounds.size.width / ( CGFloat(bufferWidth) * CGFloat(cropScaleAmount.height) );
                    textureSamplingSize.height = 1.0;
                }
                else {
                    textureSamplingSize.width = 1.0;
                    textureSamplingSize.height = self.bounds.size.height / ( CGFloat(bufferHeight) * CGFloat(cropScaleAmount.width) );
                }
                
                let width1 = GLfloat(( 1.0 - textureSamplingSize.width ) / 2.0)
                let width2 = GLfloat(( 1.0 + textureSamplingSize.width ) / 2.0)
                let height1 = GLfloat(( 1.0 - textureSamplingSize.height ) / 2.0)
                let height2 = GLfloat(( 1.0 + textureSamplingSize.height ) / 2.0)
                // Perform a vertical flip by swapping the top left and the bottom left coordinate.
                // CVPixelBuffers have a top left origin and OpenGL has a bottom left origin.
                let passThroughTextureVertices:[GLfloat] = [
                    width1, height2, // top left
                    width2, height2, // top right
                    width1, height1, // bottom left
                    width2, height1, // bottom right
                ];
                
                glVertexAttribPointer(textureCoordinateSlot, 2, GLenum(GL_FLOAT), 0, 0, rotateCoordinate)
                glEnableVertexAttribArray(GLuint(textureCoordinateSlot))
                glDrawArrays( GLenum(GL_TRIANGLE_STRIP), 0, 4 );
                
                glBindRenderbuffer(GLenum(GL_RENDERBUFFER), self.currentRenderBuffer!)
                ZQLGLContext.shared.context.presentRenderbuffer(Int(GL_RENDERBUFFER))
                
                glBindTexture(CVOpenGLESTextureGetTarget(cvTexture!), 0)
                glBindTexture(GLenum(GL_TEXTURE_2D), 0)
               // CVPixelBufferUnlockBaseAddress(pixel, CVPixelBufferLockFlags(rawValue: CVOptionFlags(0)))
                CVOpenGLESTextureCacheFlush(ZQLGLContext.shared.textureCache, 0);
            }
        }
        
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
        
        guard let textureSlot = shaderProgram.uniformLocation(uniform: "u_Texture") else {
            fatalError("texture not exist")
        }
        
//        if let pixelBuffer = self.buffer(from: #imageLiteral(resourceName: "wuyanzu.jpg")) {
//            let bufferWidth = CVPixelBufferGetWidth(pixelBuffer)
//            let bufferHeight = CVPixelBufferGetHeight(pixelBuffer)
//    //        let pixelForamt = cvpixelbufferget
//            var cvTexture:CVOpenGLESTexture? = nil
//            let error = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault, ZQLGLContext.shared.textureCache, pixelBuffer, nil, GLenum(GL_TEXTURE_2D), GL_RGBA, GLsizei(bufferWidth), GLsizei(bufferHeight), GLenum(GL_BGRA), GLenum(GL_UNSIGNED_BYTE), 0, &cvTexture)
//            if error == kCVReturnError || cvTexture == nil {
//                fatalError("texture cache create texture error")
//            }
//            
//            glActiveTexture(GLenum(GL_TEXTURE0))
//            glBindTexture(CVOpenGLESTextureGetTarget(cvTexture!), CVOpenGLESTextureGetName(cvTexture!))
//            glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GL_LINEAR)
//            glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MAG_FILTER), GL_LINEAR)
//            glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_S), GL_CLAMP_TO_EDGE)
//            glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_T), GL_CLAMP_TO_EDGE)
//            glUniform1i(textureSlot, 0)
//        }
        
        glVertexAttribPointer(GLuint(positionSlot), 2, GLenum(GL_FLOAT), 0, 0, vertices)
        glEnableVertexAttribArray(GLuint(positionSlot))
        
        glVertexAttribPointer(GLuint(textureCoordinateSlot), 2, GLenum(GL_FLOAT), 0, 0, textureCoordinate)
        glEnableVertexAttribArray(GLuint(textureCoordinateSlot))
        
        glDrawArrays( GLenum(GL_TRIANGLE_STRIP), 0, 4 );
        ZQLGLContext.shared.context.presentRenderbuffer(Int(GL_RENDERBUFFER))
    }
    
    func buffer(from image: UIImage) -> CVPixelBuffer? {
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer : CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(image.size.width), Int(image.size.height), kCVPixelFormatType_32BGRA, attrs, &pixelBuffer)
        guard (status == kCVReturnSuccess) else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)
        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pixelData, width: Int(image.size.width), height: Int(image.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
        
        context?.translateBy(x: 0, y: image.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        
        UIGraphicsPushContext(context!)
        image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        UIGraphicsPopContext()
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        
        return pixelBuffer
    }
}


