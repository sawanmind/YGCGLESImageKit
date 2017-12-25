//
//  ZQLRenderUtil.swift
//  GLESImageKit_Example
//
//  Created by zang qilong on 2017/12/24.
//  Copyright © 2017年 CocoaPods. All rights reserved.
//

import Foundation
import OpenGLES

enum TextureUnit {
    case textureUnit0
    case textureUnit1
    case textureUnit2
    case textureUnit3
    case textureUnit4
    case textureUnit5
    
    var unit:GLenum {
        switch self {
        case .textureUnit0:
            return GLenum(GL_TEXTURE0)
        case .textureUnit1:
            return GLenum(GL_TEXTURE1)
        case .textureUnit2:
            return GLenum(GL_TEXTURE2)
        case .textureUnit3:
            return GLenum(GL_TEXTURE3)
        case .textureUnit4:
            return GLenum(GL_TEXTURE4)
        case .textureUnit5:
            return GLenum(GL_TEXTURE5)
        }
    }
}

func generateTexture(minFilter:Int32, magFilter:Int32, wrapS:Int32, wrapT:Int32, textureUnit:TextureUnit) -> GLuint {
    var texture:GLuint = 0
    
    glActiveTexture(GLenum(textureUnit.unit))
    glGenTextures(1, &texture)
    glBindTexture(GLenum(GL_TEXTURE_2D), texture)
    glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), minFilter)
    glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MAG_FILTER), magFilter)
    glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_S), wrapS)
    glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_T), wrapT)
    
    glBindTexture(GLenum(GL_TEXTURE_2D), 0)
    
    return texture
}
