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
    case startPurchase = "start_purchase"
    case finishTransaction = "finish_transaction"
    case requestReceipt = "request_receipt"
    case getAppStoreInitiatedProducts = "app_store_initiated_purchases"
    case getCachedInAppPurchases = "cached_in_app_purchases"
    case getPendingTransactions = "get_pending_transactions"
    case finishAllCompletedTransactions = "finish_completed_transactions"
}

/// Outgoing methods
enum OutMethod: String {
    case promotedProduct = "iap-promoted-product"
    case purchaseUpdate = "purchase-updated"
    case purchaseError = "purchase-error"
}
