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
        self.vertexShader = try compile(shaderName: vertex, type: .vertex)
        self.fragmentShader = try compile(shaderName: fragment, type: .fragment)
        glAttachShader(program, self.vertexShader)
        glAttachShader(program, self.fragmentShader)
        
        
    }
    
    deinit {
        if vertexShader != nil {
            glDeleteShader(vertexShader)
        }
        
        if fragmentShader != nil {
            glDeleteShader(fragmentShader)
        }
    }
    
    private func compile(shaderName:String, type:ShaderType) throws -> GLuint {
        guard let filePath = Bundle.main.path(forResource: shaderName, ofType: nil) else {
            throw ShaderCompileError.fileNotExist
        }
        let shaderHandler:GLuint
        switch type {
        case .vertex:
            shaderHandler = glCreateShader(GLenum(GL_VERTEX_SHADER))
        case .fragment:
            shaderHandler = glCreateShader(GLenum(GL_FRAGMENT_SHADER))
        }
        let shaderContent = try String(contentsOfFile: filePath, encoding: String.Encoding.utf8)
        var source = shaderContent.toGLCharPointer()
        glShaderSource(shaderHandler, 1, &source, nil)
        glCompileShader(shaderHandler)
        
        var compileSuccess:GLint = 1
        glGetShaderiv(shaderHandler, GLenum(GL_COMPILE_STATUS), &compileSuccess)
        if compileSuccess != 1 {
            var logLength:GLint = 0
            glGetShaderiv(shaderHandler, GLenum(GL_INFO_LOG_LENGTH), &logLength)
            if logLength > 0 {
                var compileLog = Array<CChar>.init(repeating: 0, count: Int(logLength))
                glGetShaderInfoLog(shaderHandler, logLength, &logLength, &compileLog)
                print("compile shader error \(compileLog)")
                switch type {
                case .vertex: throw ShaderCompileError.vertexCompileError
                case .fragment: throw ShaderCompileError.fragmentCompileError
                }
            }
        }
        return shaderHandler
    }
    
    private func link() throws {
        glLinkProgram(program)
        
        var linkSuccess:GLint = 0
        glGetShaderiv(program, GLenum(GL_LINK_STATUS), &linkSuccess)
        if linkSuccess == 0 {
            var logLength:GLint = 0
            glGetShaderiv(program, GLenum(GL_INFO_LOG_LENGTH), &logLength)
            if logLength > 0 {
                var log = Array<CChar>.init(repeating: 0, count: Int(logLength))
                glGetShaderInfoLog(program, logLength, &logLength, &log)
                print("link error \(log)")
            }
            
            throw ShaderCompileError.linkError
        }
    }
    
    func use() {
        glUseProgram(program)
    }
}

extension String {
    func toGLCharPointer() -> UnsafePointer<GLchar>? {
        if let cString = self.cString(using: String.Encoding.utf8) {
            return UnsafePointer<GLchar>(cString)
        }
        return nil
    }
}
