//
//  ReceiptService.swift
//  in_app_purchase
//
//  Created by Bohdan Krokhmaliuk on 21.11.2021.
//

import Foundation
import StoreKit

protocol ReceiptService {
    func requestReceiptData(_ compeletion: @escaping (String?, FlutterError?)->())
}

class ReceiptServiceImpl :  NSObject, SKRequestDelegate, ReceiptService {
    private var refreshReceiptCallbacks = [((String?, FlutterError?) -> ())]()
    private var isReceiptPresent: Bool {
        get {
            let canReach = try? Bundle.main.appStoreReceiptURL?.checkResourceIsReachable()
            return canReach ?? false
        }
    }
    
    func requestReceiptData(_ compeletion: @escaping (String?, FlutterError?)->()) {
        if isReceiptPresent {
            let refreshReceiptRequest = SKReceiptRefreshRequest()
            refreshReceiptRequest.delegate = self
            refreshReceiptRequest.start()
            refreshReceiptCallbacks.append(compeletion)
        } else {
            applyReceiptData(compeletion)
        }
    }
    
    private func applyReceiptData(_ compeletion: (String?, FlutterError?) -> Void) {
        do {
            let receiptData = try Data(contentsOf: Bundle.main.appStoreReceiptURL!, options: .alwaysMapped)
            compeletion(receiptData.base64EncodedString(options: []), nil)
        }
        catch {
            compeletion(nil, buildError("Failed to fetch a receipt"))
        }
    }
    
    func requestDidFinish(_ request: SKRequest) {
        if request is SKReceiptRefreshRequest && !refreshReceiptCallbacks.isEmpty {
            if isReceiptPresent {
                applyReceiptData() { (receipt,error) -> () in
                    refreshReceiptCallbacks.forEach() {(callback) -> () in callback(receipt,error)}
                }
            }
            else {
                refreshReceiptCallbacks.forEach(
                    {(callback) -> () in callback(nil, buildError("Receipt refreshed, but still not available"))}
                )
            }
            
            refreshReceiptCallbacks.removeAll()
        }
    }
    
    func buildError(_ message: String) -> FlutterError {
        return FlutterError(code: "E_RECEIPT_ERROR", message: message, details: nil)
    }
}
