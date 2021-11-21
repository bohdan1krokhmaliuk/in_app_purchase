//
//  InAppPurchasesService.swift
//  in_app_purchase
//
//  Created by Bohdan Krokhmaliuk on 19.11.2021.
//

import Foundation
import StoreKit

protocol InAppPurchasesService {
    func initConnection(result: @escaping FlutterResult)
    func endConnection(result: @escaping FlutterResult)
    func fetchInAppPurchases(_ args: Any?, result: @escaping FlutterResult)
    func buyProduct(_ args: Any?, result: @escaping FlutterResult)
    func requestReceipt(_ args: Any?, result: @escaping FlutterResult)
    func getPendingTransactions(_ args: Any?, result: @escaping FlutterResult)
    func finishTransaction(_ args: Any?, result: @escaping FlutterResult)
    func finishAllCompletedTransactions(_ args: Any?, result: @escaping FlutterResult)
    func retrievePurchasedProducts(_ args: Any?, result: @escaping FlutterResult)
    func getAppStoreInitiatedProducts(_ args: Any?, result: @escaping FlutterResult)
    func dispose()
}

class InAppPurchasesServiceImpl : NSObject, InAppPurchasesService, SKPaymentTransactionObserver, SKProductsRequestDelegate {
    init(channel: FlutterMethodChannel) {
        self.channel = channel
    }
    
    
    private let channel: FlutterMethodChannel
    private let receiptService: ReceiptService = ReceiptServiceImpl()
    
    private var productsCache = [SKProduct]()
    private var appStoreInitiatedProducts = [SKProduct]()
    
    
    private var restoreResult: FlutterResult?
    private var refreshReceiptCallback: ((String?, FlutterError?) -> ())?
    private var fetchInAppPurchsesRequestResult = [SKProductsRequest: FlutterResult]()
    
    func initConnection(result: @escaping FlutterResult) {
        SKPaymentQueue.default().add(self)
        result(SKPaymentQueue.canMakePayments())
    }
    
    func endConnection(result: @escaping FlutterResult) {
        SKPaymentQueue.default().remove(self)
        result("Billing client ended")
    }
    
    func fetchInAppPurchases(_ args: Any?, result: @escaping FlutterResult) {
        guard let argsMap = args as? Dictionary<String, Any> else {
            return buildFailedResult(result, "Invalid or missing arguments!")
        }
        
        guard let identifiers = argsMap["skus"] as? Array<String> else {
            return buildFailedResult(result, "Invalid or missing arguments!")
        };
        
        let identifiersSet = Set(identifiers)
        
        let request = SKProductsRequest(productIdentifiers: identifiersSet)
        fetchInAppPurchsesRequestResult[request] = result
        request.delegate = self
        request.start()
    }

    func buyProduct(_ args: Any?, result: @escaping FlutterResult) {
        guard let argsMap = args as? [String: Any?] else {
            return buildFailedResult(result, "Invalid or missing arguments!")
        }
        guard let identifier = argsMap["sku"] as? String else {
            return buildFailedResult(result, "Invalid or missing identifier argument!")
        };
        let quantity = argsMap["quantity"] as? NSNumber
        
        guard let product = productsCache.first(where: {$0.productIdentifier == identifier}) else {
            let error = [
                "code": "E_DEVELOPER_ERROR",
                "message": "Invalid product ID.",
                "debugMessage":"Invalid product ID."
            ]
            return channel.invokeMethod("purchase-error", arguments: error)
        }
        
        let payment = SKMutablePayment(product: product)
        payment.applicationUsername = argsMap["forUser"] as? String
        payment.quantity = quantity?.intValue ?? 1
        
        // Adds discount
        if #available(iOS 12.2, *) {
            if let discountMap = argsMap["withOffer"] as? [String: Any?] {
                let keyIdentifier = discountMap["keyIdentifier"] as? String
                let offerIdentifier = discountMap["identifier"] as? String
                let timeStamp = discountMap["timestamp"] as? NSNumber
                let signature = discountMap["signature"] as? String
                let uuidString = discountMap["nonce"] as? String
                let uuid = UUID(uuidString: uuidString!)
                
                if offerIdentifier != nil && keyIdentifier != nil && signature != nil && timeStamp != nil && uuid != nil {
                    let discount = SKPaymentDiscount(
                        identifier: offerIdentifier!,
                        keyIdentifier: keyIdentifier!,
                        nonce: uuid!,
                        signature: signature!,
                        timestamp: timeStamp!
                    )
                    payment.paymentDiscount = discount
                }
            }
        }
        
        SKPaymentQueue.default().add(payment)
        
        result(nil)
    }
    
    func requestReceipt(_ args: Any?, result: @escaping FlutterResult){
        receiptService.requestReceiptData() { (receipt, error) -> () in
            if receipt != nil{
                return result(receipt)
            }
            else {
                result(error)
            }
        }
    }
    
    func getPendingTransactions(_ args: Any?, result: @escaping FlutterResult){
        receiptService.requestReceiptData() { (receipt, error) -> () in
            if receipt != nil {
                var transactionsDataArray = [[String: Any?]]()
                for transaction in SKPaymentQueue.default().transactions {
                    transactionsDataArray.append(IAPConvertor.convertSKPaymentTransaction(transaction, receipt!))
                }
                
                return result(transactionsDataArray)
            }
            else {
                result(error)
            }
        }
    }
    
    /// Finishes all transaction with provided identifier
    /// in case transaction is in .purchasing state - returns an error
    /// if transaction is finished returns success result
    /// if transaction is not in queue any more returns success result
    func finishTransaction(_ args: Any?, result: @escaping FlutterResult){
        guard let argsMap = args as? [String: Any?] else {
            return buildFailedResult(result, "Invalid or missing arguments!")
        }
        guard let identifier = argsMap["transactionIdentifier"] as? String else {
            return buildFailedResult(result, "Invalid or missing identifier argument!")
        };
        
        let queue = SKPaymentQueue.default()
        for transaction in queue.transactions{
            if transaction.transactionIdentifier == identifier {
                if transaction.transactionState == .purchasing {
                    return buildFailedResult(result, "Can finish purchasing transaction")
                }
                
                queue.finishTransaction(transaction)
            }
        }
        
        // TODO: check if needed
        let dict: [String: Any] = [
            "debugMessage": "finishTransaction",
            "message":"finished",
            "code": identifier
        ]
        
        result(dict)
    }
    
    /// Finishes all transaction with not .purchasing state
    func finishAllCompletedTransactions(_ args: Any?, result: @escaping FlutterResult){
        let queue = SKPaymentQueue.default()
        for transaction in queue.transactions{
            if transaction.transactionState != .purchasing{
                queue.finishTransaction(transaction)
            }
        }
        
        result(true);
    }
    
    /// Requests all of the made purchases for user if provided.
    /// Flutter result is finished in one of the following callbacks
    /// success: func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue);
    /// failed: func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error);
    ///
    /// You can't make another request untill previos finished
    func retrievePurchasedProducts(_ args: Any?, result: @escaping FlutterResult){
        if restoreResult != nil {
            return buildFailedResult(result, "Request already processing!")
        }
        guard let argsMap = args as? [String: Any?] else {
            return buildFailedResult(result, "Invalid or missing arguments!")
        }
        
        if let userHash = argsMap["forUser"] as? String {
            SKPaymentQueue.default().restoreCompletedTransactions(withApplicationUsername: userHash)
            restoreResult = result
            return
        }
        
        SKPaymentQueue.default().restoreCompletedTransactions()
        restoreResult = result
    }
    
    func getAppStoreInitiatedProducts(_ args: Any?, result: @escaping FlutterResult){
        var array = [[String: Any?]]()
        
        for product in appStoreInitiatedProducts {
            array.append(IAPConvertor.convertSKProduct(product))
        }
        
        result(array)
    }
    
    private func buildFailedResult(_ result: @escaping FlutterResult, _ message: String, _ error: Error? = nil) {
        return result(FlutterError(code: "in_app_purchase_failed", message: message, details: error?.localizedDescription))
    }
    
    private func buildError(_ error: Error) -> FlutterError {
        let nsError = error as NSError
        return FlutterError(
            code: standardErrorCode(nsError.code),
            message: englishErrorCodeDescription( nsError.code),
            details: nil
        )
    }
    
    // TODO: deinit?
    func dispose() {
        SKPaymentQueue.default().remove(self)
    }
    
    
    private func standardErrorCode(_ code: NSInteger) -> String {
        let codes = [
          "E_UNKNOWN",
          "E_SERVICE_ERROR",
          "E_USER_CANCELLED",
          "E_USER_ERROR",
          "E_USER_ERROR",
          "E_ITEM_UNAVAILABLE",
          "E_REMOTE_ERROR",
          "E_NETWORK_ERROR",
          "E_SERVICE_ERROR"
        ];
        
        if code >= 0 && code < codes.count {
            return codes[code]
        }
        
        return codes[0]
    }
    
    private func englishErrorCodeDescription(_ code: NSInteger) -> String{
        let descriptions = [
            "An unknown or unexpected error has occured. Please try again later.",
            "Unable to process the transaction: your device is not allowed to make purchases.",
            "Cancelled.",
            "Oops! Payment information invalid. Did you enter your password correctly?",
            "Payment is not allowed on this device. If you are the one authorized to make purchases on this device, you can turn payments on in Settings.",
            "Sorry, but this product is currently not available in the store.",
            "Unable to make purchase: Cloud service permission denied.",
            "Unable to process transaction: Your internet connection isn't stable! Try again later.",
            "Unable to process transaction: Cloud service revoked."
        ];
            
        if code >= 0 && code < descriptions.count {
            return descriptions[code]
        }
        else {
            return String.localizedStringWithFormat("%@ (Error code: %d)", descriptions[0], code)
        }
    }
    
    // MARK: - SKPaymentTransactionObserver
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
                case .purchasing:
                    NSLog("\n\n Purchase Started !! \n\n")
                case .purchased:
                    NSLog("\n\n\n\n\n Purchase Successful !! \n\n\n\n\n.")
                    processPurchase(transaction)
                case .restored:
                    NSLog("Restored")
                    queue.finishTransaction(transaction)
                case .deferred:
                    NSLog("Deferred (awaiting approval via parental controls, etc.)")
                case .failed:
                    queue.finishTransaction(transaction)
                    let nsError = transaction.error! as NSError
                    let err = [
                        "debugMessage" : "SKPaymentTransactionStateFailed",
                        "code": standardErrorCode(nsError.code),
                        "message": englishErrorCodeDescription(nsError.code)
                    ]
                
                    self.channel.invokeMethod("purchase-error", arguments: err)
                    NSLog("\n\n\n\n\n\n Purchase Failed  !! \n\n\n\n\n");
                @unknown default:
                    NSLog("Runned into unknown transaction state")
            }
        }
    }
    
    func processPurchase(_ transaction: SKPaymentTransaction) {
        receiptService.requestReceiptData(){ (receipt, error) -> () in
            if receipt != nil {
                self.channel.invokeMethod(
                    "purchase-updated", arguments: IAPConvertor.convertSKPaymentTransaction(transaction, receipt!)
                )
            }
        }
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        NSLog("\n\n\n  paymentQueueRestoreCompletedTransactionsFinished  \n\n.");
        receiptService.requestReceiptData(){ (receipt, error) -> () in
            if let result = self.restoreResult {
                if error != nil {
                    result(error)
                }
                else if receipt != nil {
                    var transactionMaps = [[String: Any?]]()
                    for transaction in queue.transactions {
                        if transaction.transactionState == .restored || transaction.transactionState == .purchased {
                            transactionMaps.append(IAPConvertor.convertSKPaymentTransaction(transaction, receipt!))
                            queue.finishTransaction(transaction)
                        }
                    }
                }
            }
            self.restoreResult = nil
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        if restoreResult != nil {
            restoreResult!(buildError(error))
            restoreResult = nil
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, shouldAddStorePayment payment: SKPayment, for product: SKProduct) -> Bool {
        appStoreInitiatedProducts.append(product)
        channel.invokeMethod("iap-promoted-product", arguments: product.productIdentifier)
        return false
    }
    
    // MARK: - Store kit delegate
    func request(_ request: SKRequest, didFailWithError error: Error) {
        if request is SKProductsRequest {
            let productRequest = request as! SKProductsRequest
            if let result = fetchInAppPurchsesRequestResult[productRequest] {
                fetchInAppPurchsesRequestResult.removeValue(forKey: productRequest)
                result(buildError(error))
            }
        }
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if let result = fetchInAppPurchsesRequestResult[request]{
            fetchInAppPurchsesRequestResult.removeValue(forKey: request)
            for product in response.products {
                cacheProduct(product)
            }
            
            var items = [[String: Any?]]()
            for product in productsCache {
                items.append(IAPConvertor.convertSKProduct(product))
            }
            
            // TODO: APPEND response.invalidProductsIdentifiers? to result obj???
            result(items)
        }
    }
    
    
    private func cacheProduct(_ product: SKProduct){
        NSLog("\n  Add new object : %@", product.productIdentifier);
        productsCache.removeAll(where: {$0.productIdentifier == product.productIdentifier})
        productsCache.append(product)
    }
}
