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
    private enum SupportedCall: String {
        case initConnection = "canMakePayments"
        case endConnection = "endConnection"
        case buyProduct = "buyProduct"
        case fetchInAppPurchases = "getItems"
        case requestProductWithOfferIOS = "requestProductWithOfferIOS"
        case requestProductWithQuantityIOS = "requestProductWithQuantityIOS"
        case requestReceipt = "requestReceipt"
        case getPendingTransactions = "getPendingTransactions"
        case finishTransaction = "finishTransaction"
        case finishAllCompletedTransactions = "clearTransactions"
        case retrievePurchasedProducts = "getAvailableItems"
        case getAppStoreInitiatedProducts = "getAppStoreInitiatedProducts"
    }
    
    private var service: InAppPurchasesService?;
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "in_app_purchase", binaryMessenger: registrar.messenger())
        let instance = SwiftInAppPurchasePlugin()
        instance.service = InAppPurchasesServiceImpl(channel: channel)
        
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if service == nil {
            return result(FlutterError(code: "NOT_READY", message: "Plugin is not registred yet", details: nil))
        }
        
        guard let method = SupportedCall(rawValue: call.method) else {
            return result(FlutterMethodNotImplemented)
        }
        
        switch method {
            case .initConnection:
                service?.initConnection(result: result)
            case .endConnection:
                service?.endConnection(result: result)
            case .buyProduct, .requestProductWithOfferIOS, .requestProductWithQuantityIOS:
                service?.buyProduct(call.arguments, result: result)
            case .fetchInAppPurchases:
                service?.fetchInAppPurchases(call.arguments, result: result)
            case .requestReceipt:
                service?.requestReceipt(call.arguments, result: result)
            case .getPendingTransactions:
                service?.getPendingTransactions(call.arguments, result: result)
            case .finishTransaction:
                service?.finishTransaction(call.arguments, result: result)
            case .finishAllCompletedTransactions:
                service?.finishAllCompletedTransactions(call.arguments,result: result)
            case .retrievePurchasedProducts:
                service?.retrievePurchasedProducts(call.arguments,result: result)
            case .getAppStoreInitiatedProducts:
                service?.getAppStoreInitiatedProducts(call.arguments,result: result)
        }
    }
    
    
    deinit {
        service?.dispose()
        service = nil
    }
}
