//
//  Method.swift
//  in_app_purchase
//
//  Created by Bohdan Krokhmaliuk on 28.11.2021.
//

import Foundation

/// Incoming methods
enum Method: String {
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
    case setLogging = "setLogging"
}

/// Outgoing methods
enum OutMethod: String {
    case promotedProduct = "iap-promoted-product"
    case purchaseUpdate = "purchase-updated"
    case purchaseError = "purchase-error"
}
