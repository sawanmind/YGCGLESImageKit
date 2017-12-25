//
//  ZQLGLESProgram.swift
//  GLESImageKit_Example
//
//  Created by zang qilong on 2017/11/28.
//  Copyright © 2017年 CocoaPods. All rights reserved.
//

import Foundation
import OpenGLES

enum ShaderType {
    case vertex
    case fragment
}

enum ShaderCompileError:Error {
    case linkError
    case fileNotExist
    case vertexCompileError
    case fragmentCompileError
}

class ZQLGLESProgram {
    
    let program:GLuint
    var vertexShader:GLuint!
    var fragmentShader:GLuint!
    
    init(vertex:String, fragment:String) throws {
        program = glCreateProgram()
        self.vertexShader = try compileShader(vertex, type: .vertex)
        self.fragmentShader = try compileShader(fragment, type: .fragment)
        glAttachShader(program, self.vertexShader)
        glAttachShader(program, self.fragmentShader)
        
        try link()
    }
    
    deinit {
        if vertexShader != nil {
            glDeleteShader(vertexShader)
        }
        
        if fragmentShader != nil {
            glDeleteShader(fragmentShader)
        }
    }
    
    func compileShader(_ shaderString:String, type:ShaderType) throws -> GLuint {
        let shaderHandle:GLuint
        switch type {
            case .vertex: shaderHandle = glCreateShader(GLenum(GL_VERTEX_SHADER))
            case .fragment: shaderHandle = glCreateShader(GLenum(GL_FRAGMENT_SHADER))
        }
        
        guard let filePath = Bundle.main.path(forResource: shaderString, ofType: nil) else {
            fatalError("file not exist")
        }
        let str = try! NSString(contentsOfFile: filePath, encoding: String.Encoding.utf8.rawValue)
        var cString = str.utf8String
        var length = GLint(str.length)
        glShaderSource(shaderHandle, 1, &cString, &length)
        glCompileShader(shaderHandle)

//        shaderString.withGLChar{glString in
//            var tempString:UnsafePointer<GLchar>? = glString
//            var length = tempString
//            glShaderSource(shaderHandle, 1, &tempString, nil)
//            glCompileShader(shaderHandle)
//        }
    
        var compileStatus:GLint = 1
        glGetShaderiv(shaderHandle, GLenum(GL_COMPILE_STATUS), &compileStatus)
        if (compileStatus != 1) {
            var logLength:GLint = 0
            glGetShaderiv(shaderHandle, GLenum(GL_INFO_LOG_LENGTH), &logLength)
            if (logLength > 0) {
                var compileLog = [CChar](repeating:0, count:Int(logLength))
                
                glGetShaderInfoLog(shaderHandle, logLength, &logLength, &compileLog)
                print("Compile log: \(String(cString:compileLog))")
                // let compileLogString = String(bytes:compileLog.map{UInt8($0)}, encoding:NSASCIIStringEncoding)
                
                switch type {
                    case .vertex: throw ShaderCompileError.vertexCompileError
                    case .fragment: throw ShaderCompileError.fragmentCompileError
                }
            }
        }
        
        return shaderHandle
    }
    
    func link() throws {
        glLinkProgram(program)
        
        var linkStatus:GLint = 0
        glGetProgramiv(program, GLenum(GL_LINK_STATUS), &linkStatus)
        if (linkStatus == 0) {
            var logLength:GLint = 0
            glGetProgramiv(program, GLenum(GL_INFO_LOG_LENGTH), &logLength)
            if (logLength > 0) {
                var compileLog = [CChar](repeating:0, count:Int(logLength))
                
                glGetProgramInfoLog(program, logLength, &logLength, &compileLog)
                print("Link log: \(String(cString:compileLog))")
            }
            
            throw ShaderCompileError.linkError
        }
    }
    
    func use() {
        glUseProgram(program)
    }
    
    func attributeLocation(attribute:String) -> GLuint? {
        var attributeAddress:GLint = -1
        attribute.withGLChar{glString in
            attributeAddress = glGetAttribLocation(self.program, glString)
        }
        
        if (attributeAddress < 0) {
            return nil
        } else {
            glEnableVertexAttribArray(GLuint(attributeAddress))
            return GLuint(attributeAddress)
        }
    }
    
    func uniformLocation(uniform:String) -> GLint? {
        var uniformAddress:GLint = -1
        uniform.withGLChar{glString in
            uniformAddress = glGetUniformLocation(self.program, glString)
        }
        if (uniformAddress < 0) {
            return nil
        } else {
            return uniformAddress
        }
    }
}

extension String {
    func withNonZeroSuffix(_ suffix:Int) -> String {
        if suffix == 0 {
            return self
        } else {
            return "\(self)\(suffix + 1)"
        }
    }
    
    func withGLChar(_ operation:(UnsafePointer<GLchar>) -> ()) {
        if let value = self.cString(using:String.Encoding.utf8) {
            operation(UnsafePointer<GLchar>(value))
        } else {
            fatalError("Could not convert this string to UTF8: \(self)")
        }
    }
}
