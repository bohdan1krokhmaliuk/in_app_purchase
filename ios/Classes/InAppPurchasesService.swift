//
//  InAppPurchasesService.swift
//  in_app_purchase
//
//  Created by Bohdan Krokhmaliuk on 19.11.2021.
//

// TODO: Implement logger

import Foundation
import StoreKit

protocol InAppPurchasesService {
    func initConnection(result: @escaping FlutterResult)
    func endConnection(result: @escaping FlutterResult)
    
    func requestReceipt(result: @escaping FlutterResult)
    func getPendingTransactions(result: @escaping FlutterResult)
    func getCachedInAppPurchases(result: @escaping FlutterResult)
    func getAppStoreInitiatedInAppPurchases(result: @escaping FlutterResult)
    func finishAllCompletedTransactions(result: @escaping FlutterResult)
    
    func buyProduct(_ args: [String: Any?], result: @escaping FlutterResult)
    func finishTransaction(_ args: [String: Any?], result: @escaping FlutterResult)
    func fetchInAppPurchases(_ args: [String: Any?], result: @escaping FlutterResult)
    func retrievePurchasedProducts(_ args: [String: Any?], result: @escaping FlutterResult)
}

class InAppPurchasesServiceImpl : NSObject, InAppPurchasesService {
    init (channel: FlutterMethodChannel) {
        self.channel = channel
        self.mapper = StoreKitMapperImpl()
        self.errorHandler = ErrorHandlerImpl()
        self.receiptService = ReceiptServiceImpl()
    }
    
    private let mapper: StoreKitMapper
    private let errorHandler: ErrorHandler
    private let channel: FlutterMethodChannel
    private let receiptService: ReceiptService
    
    private var inAppPurchasesCache = [SKProduct]()
    private var appStoreInitiatedProducts = [SKProduct]()
    
    private var restoreResult: FlutterResult?
    private var fetchInAppPurchsesRequestResult = [SKProductsRequest: FlutterResult]()
    
    private var queue: SKPaymentQueue {
        return SKPaymentQueue.default()
    }
    
    func initConnection(result: @escaping FlutterResult) {
        queue.add(self)
        result(SKPaymentQueue.canMakePayments())
    }
    
    func endConnection(result: @escaping FlutterResult) {
        queue.remove(self)
        result(true)
    }
    
    func fetchInAppPurchases(_ args: [String: Any?], result: @escaping FlutterResult) {
        guard let identifiers = args["skus"] as? Array<String> else {
            return result(errorHandler.buildArgumentError("fetchInAppPurchases: 'skus' must be provided"))
        };
        
        let identifiersSet = Set(identifiers)
        
        let request = SKProductsRequest(productIdentifiers: identifiersSet)
        fetchInAppPurchsesRequestResult[request] = result
        request.delegate = self
        request.start()
    }
    
    func getCachedInAppPurchases(result: @escaping FlutterResult) {
        result(inAppPurchasesCache.map(mapper.toJson))
    }

    func buyProduct(_ args: [String: Any?], result: @escaping FlutterResult) {
        guard let identifier = args["sku"] as? String else {
            return result(errorHandler.buildArgumentError("buyProduct: 'sku' must be provided"))
        }
        
        guard let product = inAppPurchasesCache.first(where: {$0.productIdentifier == identifier}) else {
            return result(errorHandler.buildStandardFlutterError(PurchaseError.noSuchInAppPurchase))
        }
    
        let payment = SKMutablePayment(product: product)
        payment.applicationUsername = args["forUser"] as? String
        payment.quantity = (args["quantity"] as? NSNumber)?.intValue ?? 1
        
        // Adds discount
        if #available(iOS 12.2, *) {
            if let discountMap = args["withOffer"] as? [String: Any?] {
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
        
        queue.add(payment)
        result(nil)
    }
    
    func requestReceipt(result: @escaping FlutterResult) {
        receiptService.requestReceiptData() {(receipt, error) -> () in result(receipt ?? error)}
    }
    
    func getPendingTransactions(result: @escaping FlutterResult){
        receiptService.requestReceiptData() {(receipt, error) -> () in
            if receipt != nil {
                let transactionsMap = self.queue.transactions.map({self.mapper.toJson($0, receipt!)})
                return result(transactionsMap)
            }
            
            result(error)
        }
    }
    
    /// Finishes all transaction with provided transaction identifier or sku
    /// in case transaction is in .purchasing state - returns an error
    /// if transaction is finished returns success result
    /// if transaction is not in queue any more returns success result
    func finishTransaction(_ args: [String: Any?], result: @escaping FlutterResult) {
        let identifier = args["transactionIdentifier"] as? String
        let sku = args["sku"] as? String
        
        if (sku == nil && identifier == nil) || (sku != nil && identifier != nil) {
            return result(errorHandler.buildArgumentError(
                "finishTransaction: only 'sku' or only 'transactionIdentifier' must be provided"
            ))
        }
        
        for transaction in queue.transactions {
            if transaction.transactionIdentifier == identifier || transaction.payment.productIdentifier == sku {
                if transaction.transactionState == .purchasing {
                    return result(errorHandler.buildStandardFlutterError(PurchaseError.finishTransactionError))
                }
                
                queue.finishTransaction(transaction)
            }
        }
        
        result(true)
    }
    
    /// Finishes all transaction with not .purchasing state
    func finishAllCompletedTransactions(result: @escaping FlutterResult) {
        for transaction in queue.transactions {
            if transaction.transactionState != .purchasing {
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
    func retrievePurchasedProducts(_ args: [String: Any?], result: @escaping FlutterResult) {
        if restoreResult != nil {
            return result(errorHandler.buildStandardFlutterError(PurchaseError.requestAlreadyProcessing))
        }
        
        if let userHash = args["forUser"] as? String {
            queue.restoreCompletedTransactions(withApplicationUsername: userHash)
        }
        else {
            queue.restoreCompletedTransactions()
        }
        
        restoreResult = result
    }
    
    func getAppStoreInitiatedInAppPurchases(result: @escaping FlutterResult) {
        let products = appStoreInitiatedProducts.map(mapper.toJson)
        result(products)
    }
    
    deinit {
        queue.remove(self)
    }
}

// MARK: - SKPaymentTransactionObserver
extension InAppPurchasesServiceImpl: SKPaymentTransactionObserver {
    private func processPurchase(_ transaction: SKPaymentTransaction) {
        appStoreInitiatedProducts.removeAll(where: {$0.productIdentifier == transaction.payment.productIdentifier})
        receiptService.requestReceiptData() {(receipt, error) -> () in
            if receipt != nil {
                let transacition = self.mapper.toJson(transaction, receipt!)
                self.channel.invokeMethod("purchase-updated", arguments: transacition)
            }
        }
    }
    
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
                case .deferred:
                    NSLog("Deferred (awaiting approval via parental controls, etc.)")
                case .failed:
                    queue.finishTransaction(transaction)
                    let error = transaction.error! as NSError
                    let errorMap = errorHandler.buildSKErrorMap(error, "SKPaymentTransactionStateFailed")
                
                    self.channel.invokeMethod("purchase-error", arguments: errorMap)
                    NSLog("\n\n\n\n\n\n Purchase Failed  !! \n\n\n\n\n");
                @unknown default:
                    NSLog("Runned into unknown transaction state")
            }
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, shouldAddStorePayment payment: SKPayment, for product: SKProduct) -> Bool {
        appStoreInitiatedProducts.append(product)
        channel.invokeMethod("iap-promoted-product", arguments: product.productIdentifier)
        return false
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        NSLog("\n\n\n  paymentQueueRestoreCompletedTransactionsFinished  \n\n.");
        receiptService.requestReceiptData() {(receipt, error) -> () in
            if receipt != nil {
                var transactionMaps = [[String: Any?]]()
                queue.transactions.forEach({(transaction) -> () in
                    if transaction.transactionState == .restored {
                        transactionMaps.append(self.mapper.toJson(transaction, receipt!))
                        queue.finishTransaction(transaction)
                    }
                })

                self.restoreResult?(transactionMaps)
            }
            else if error != nil {
                self.restoreResult?(error)
            }

            self.restoreResult = nil
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        queue.transactions.forEach({(transaction) -> Void in
            if transaction.transactionState == .restored {
                queue.finishTransaction(transaction)
            }
        })
        
        restoreResult?(errorHandler.buildSKError(error as NSError))
        restoreResult = nil
    }
}

// MARK: - SKProductsRequestDelegate
extension InAppPurchasesServiceImpl: SKProductsRequestDelegate {
    func request(_ request: SKRequest, didFailWithError error: Error) {
        if request is SKProductsRequest {
            let productRequest = request as! SKProductsRequest
            if let result = fetchInAppPurchsesRequestResult[productRequest] {
                fetchInAppPurchsesRequestResult.removeValue(forKey: productRequest)
                result(errorHandler.buildSKError(error as NSError))
            }
        }
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if let result = fetchInAppPurchsesRequestResult[request] {
            fetchInAppPurchsesRequestResult.removeValue(forKey: request)
            response.products.forEach(cacheInAppPurchase)
            
            // TODO: APPEND response.invalidProductsIdentifiers? to result obj???
            result(inAppPurchasesCache.map(mapper.toJson))
        }
    }
    
    private func cacheInAppPurchase(_ product: SKProduct){
        NSLog("\n  Add new object : %@", product.productIdentifier);
        inAppPurchasesCache.removeAll(where: {$0.productIdentifier == product.productIdentifier})
        inAppPurchasesCache.append(product)
    }
}
