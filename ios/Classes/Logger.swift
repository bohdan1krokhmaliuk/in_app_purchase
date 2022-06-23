//
//  Logger.swift
//  in_app_purchase
//

import Foundation

protocol Logger{
    func enable()
    func disable()
    func log(_ message: String)
}

class LoggerImpl: Logger {
    var isEnabled = false
    
    func enable() {
        isEnabled = true
    }
    
    func disable() {
        isEnabled = false
    }
    
    func log(_ message: String) {
        if isEnabled {
            NSLog(message)
        }
    }
}
