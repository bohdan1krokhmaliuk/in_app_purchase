//
//  Method.swift
//  in_app_purchase
//
//  Created by Bohdan Krokhmaliuk on 28.11.2021.
//

import Foundation

/// Incoming methods
enum Method: String {
    case initConnection = "init_connection"
    case endConnection = "end_connection"
    case setLogging = "enable_logging"
    case getInAppPurchases = "get_in_app_purchases"
    case getPurchasedProducts = "get_purchased_products"
    
    case buyProduct = "buyProduct"
    case requestReceipt = "requestReceipt"
    case getPendingTransactions = "getPendingTransactions"
    case finishTransaction = "finishTransaction"
    case finishAllCompletedTransactions = "clearTransactions"
    case getAppStoreInitiatedProducts = "getAppStoreInitiatedProducts"
    case getCachedInAppPurchases = "getCachedInAppPurchases"
    
}

/// Outgoing methods
enum OutMethod: String {
    case promotedProduct = "iap-promoted-product"
    case purchaseUpdate = "purchase-updated"
    case purchaseError = "purchase-error"
}
