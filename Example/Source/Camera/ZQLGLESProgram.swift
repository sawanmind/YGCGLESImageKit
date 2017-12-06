//
//  ZQLGLESProgram.swift
//  GLESImageKit_Example
//
//  Created by zang qilong on 2017/11/28.
//  Copyright © 2017年 CocoaPods. All rights reserved.
//

import Foundation
import OpenGLES

class ZQLGLESProgram {
    
    private func compile(shaderName:String, type:GLenum) {
        guard let filePath = Bundle.main.path(forResource: shaderName, ofType: nil) else {
            print("filepath not exist")
            return
        }
//        let shaderContent = try! String(contentsOfFile: filePath, encoding: String.Encoding.utf8)
//        let shaderSource = UnsafePointer<CChar>(shaderContent.cString(using: String.Encoding.utf8))
//        
//        let shaderHandler = glCreateShader(type)
        
    }
}

extension String {
    
}
