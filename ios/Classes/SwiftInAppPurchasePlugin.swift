//
//  SwiftInAppPurchasesPlugin.swift
//  in_app_purchase
//
//  Created by Bohdan Krokhmaliuk on 19.11.2021.
//

import Flutter
import UIKit
import StoreKit

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
            let code = PurchaseError.serviceNotReady
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
        case .startPurchase:
            service?.startPurchase(argsMap, result: result)
        case .finishTransaction:
            service?.finishTransaction(argsMap, result: result)
        case .getInAppPurchases:
            service?.getInAppPurchases(argsMap, result: result)
        case .getPurchasedProducts:
            service?.getPurchasedProducts(argsMap, result: result)
        case .setLogging:
            service?.enableLogging(argsMap, result: result)
        }
    }
    
    deinit {
        service = nil
    }
}
