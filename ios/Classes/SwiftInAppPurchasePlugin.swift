//
//  SwiftInAppPurchasesPlugin.swift
//  in_app_purchase
//
//  Created by Bohdan Krokhmaliuk on 19.11.2021.
//

import Flutter
import UIKit
import StoreKit

private enum Method: String {
    case initConnection = "canMakePayments"
    case endConnection = "endConnection"
    case buyProduct = "buyProduct"
    case fetchInAppPurchases = "getItems"
    case requestReceipt = "requestReceipt"
    case getPendingTransactions = "getPendingTransactions"
    case finishTransaction = "finishTransaction"
    case finishAllCompletedTransactions = "clearTransactions"
    case retrievePurchasedProducts = "getAvailableItems"
    case getAppStoreInitiatedProducts = "getAppStoreInitiatedProducts"
    case getCachedInAppPurchases = "getCachedInAppPurchases"
}

public class SwiftInAppPurchasePlugin: NSObject, FlutterPlugin {
    private var service: InAppPurchasesService?;
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "in_app_purchase", binaryMessenger: registrar.messenger())
        let instance = SwiftInAppPurchasePlugin()
        instance.service = InAppPurchasesServiceImpl(channel: channel)
        
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if service == nil {
            let code = ErrorCode.serviceNotReady
            return result(FlutterError(code: code.rawValue, message: code.defaultMessage, details: nil))
        }
        
        guard let method = Method(rawValue: call.method) else {
            return result(FlutterMethodNotImplemented)
        }
        
        let argsMap = call.arguments as? [String: Any?] ?? [String:Any?]()
        
        switch method {
        case .initConnection:
            service?.initConnection(result: result)
        case .endConnection:
            service?.endConnection(result: result)
        case .requestReceipt:
            service?.requestReceipt(result: result)
        case .getPendingTransactions:
            service?.getPendingTransactions(result: result)
        case .finishAllCompletedTransactions:
            service?.finishAllCompletedTransactions(result: result)
        case .getAppStoreInitiatedProducts:
            service?.getAppStoreInitiatedInAppPurchases(result: result)
        case .getCachedInAppPurchases:
            service?.getCachedInAppPurchases(result: result)
        case .buyProduct:
            service?.buyProduct(argsMap, result: result)
        case .finishTransaction:
            service?.finishTransaction(argsMap, result: result)
        case .fetchInAppPurchases:
            service?.fetchInAppPurchases(argsMap, result: result)
        case .retrievePurchasedProducts:
            service?.retrievePurchasedProducts(argsMap, result: result)
        
        }
    }
    
    deinit {
        service = nil
    }
}
