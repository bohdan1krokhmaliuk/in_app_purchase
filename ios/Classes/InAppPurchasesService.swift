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
    func enableLogging(_ args: [String: Any?], result: @escaping FlutterResult)
    
    func requestReceipt(result: @escaping FlutterResult)
    func getPendingTransactions(result: @escaping FlutterResult)
    func getCachedInAppPurchases(result: @escaping FlutterResult)
    func finishAllCompletedTransactions(result: @escaping FlutterResult)
    func getAppStoreInitiatedInAppPurchases(result: @escaping FlutterResult)
    
    func startPurchase(_ args: [String: Any?], result: @escaping FlutterResult)
    func finishTransaction(_ args: [String: Any?], result: @escaping FlutterResult)
    func getInAppPurchases(_ args: [String: Any?], result: @escaping FlutterResult)
    func getPurchasedProducts(_ args: [String: Any?], result: @escaping FlutterResult)
}

class InAppPurchasesServiceImpl : NSObject, InAppPurchasesService {
    init (channel: FlutterMethodChannel) {
        self.channel = channel
        self.logger = LoggerImpl()
        self.mapper = StoreKitMapperImpl()
        self.errorHandler = ErrorHandlerImpl()
        self.receiptService = ReceiptServiceImpl()
    }
    
    private let logger: Logger
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
    
    func enableLogging(_ args: [String: Any?], result: @escaping FlutterResult) {
        guard let enable = args["enable"] as? Bool else {
            return result(errorHandler.buildArgumentError("set logging: enable property not provided"))
        };
        enable ? logger.enable() : logger.disable()
        result(enable)
    }
    
    func initConnection(result: @escaping FlutterResult) {
        queue.add(self)
        logger.log("[Connection] initialized")
        result(SKPaymentQueue.canMakePayments())
    }
    
    func endConnection(result: @escaping FlutterResult) {
        queue.remove(self)
        logger.log("[Connection] finished")
        result(true)
    }
    
    func getInAppPurchases(_ args: [String: Any?], result: @escaping FlutterResult) {
        guard let identifiers = args["skus"] as? Array<String> else {
            return result(errorHandler.buildArgumentError("fetchInAppPurchases: 'skus' must be provided"))
        };
        
        let identifiersSet = Set(identifiers)
        let request = SKProductsRequest(productIdentifiers: identifiersSet)
        fetchInAppPurchsesRequestResult[request] = result
        request.delegate = self
        
        logger.log("[InAppPurchase] requested in app purchases")
        request.start()
    }
    
    func getCachedInAppPurchases(result: @escaping FlutterResult) {
        result(inAppPurchasesCache.map(mapper.toJson))
    }

    func startPurchase(_ args: [String: Any?], result: @escaping FlutterResult) {
        guard let sku = args["sku"] as? String else {
            return result(errorHandler.buildArgumentError("start_purchase: 'sku' must be provided"))
        }
        
        guard let product = inAppPurchasesCache.first(where: {$0.productIdentifier == sku}) else {
            return result(errorHandler.buildStandardFlutterError(PurchaseError.noSuchInAppPurchase))
        }
    
        logger.log("[Purchase] sku: \(sku); started")
        let payment = SKMutablePayment(product: product)
        if let user = args["user"] as? String {
            payment.applicationUsername = user
            logger.log("[Purchase] sku: \(sku); User set (\(user))")
        }
        
        if let quantity = (args["quantity"] as? NSNumber)?.intValue {
            payment.quantity = quantity
            logger.log("[Purchase] sku: \(sku); Quantity set (\(quantity)")
        }
        
        // Adds discount
        if #available(iOS 12.2, *) {
            let offer = args["offer"] as? [String: Any?]
            if
                let keyIdentifier = offer?["key_identifier"] as? String,
                let offerIdentifier = offer?["identifier"] as? String,
                let timeStamp = offer?["timestamp"] as? NSNumber,
                let signature = offer?["signature"] as? String,
                let uuidString = offer?["nonce"] as? String,
                let uuid = UUID(uuidString: uuidString)
            {
                let discount = SKPaymentDiscount(
                    identifier: offerIdentifier,
                    keyIdentifier: keyIdentifier,
                    nonce: uuid,
                    signature: signature,
                    timestamp: timeStamp
                )
                payment.paymentDiscount = discount
                logger.log("[Purchase] sku: \(sku); Discount set (\(offerIdentifier)")
            }
        }
        
        logger.log("[Purchase] sku: \(sku); Requested purchase")
        queue.add(payment)
        result(nil)
    }
    
    func requestReceipt(result: @escaping FlutterResult) {
        logger.log("[Receipt] requested")
        receiptService.requestReceiptData() {(receipt, error) -> () in
            if receipt != nil {
                self.logger.log("[Receipt] receipt request succeed")
            } else {
                self.logger.log("[Receipt] receipt request failed")
            }
            
            result(receipt ?? error)
        }
    }
    
    func getPendingTransactions(result: @escaping FlutterResult) {
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
        let identifier = args["transaction_id"] as? String
        let sku = args["sku"] as? String
        
        if (sku == nil && identifier == nil) || (sku != nil && identifier != nil) {
            return result(errorHandler.buildArgumentError(
                "finishTransaction: only 'sku' or only 'transactionIdentifier' must be provided"
            ))
        }
        
        for transaction in queue.transactions {
            let currentId = transaction.transactionIdentifier
            let currentSku = transaction.payment.productIdentifier
            if currentId == identifier || currentSku == sku {
                if transaction.transactionState == .purchasing {
                    logger.log("[FinishPurchase] sku: \(currentSku); Transaction state: purchasing; finish failed")
                    return result(errorHandler.buildStandardFlutterError(PurchaseError.finishTransactionError))
                }
                
                queue.finishTransaction(transaction)
                logger.log("[FinishPurchase] sku: \(currentSku); succeed")
            }
        }
        
        result(true)
    }
    
    /// Finishes all transaction with not .purchasing state
    func finishAllCompletedTransactions(result: @escaping FlutterResult) {
        for transaction in queue.transactions {
            if transaction.transactionState != .purchasing {
                queue.finishTransaction(transaction)
                logger.log("[FinishPurchase] sku: \(transaction.payment.productIdentifier); succeed")
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
    func getPurchasedProducts(_ args: [String: Any?], result: @escaping FlutterResult) {
        if restoreResult != nil {
            return result(errorHandler.buildStandardFlutterError(PurchaseError.requestAlreadyProcessing))
        }
        
        restoreResult = result
        
        if let user = args["user"] as? String {
            logger.log("[Restore] started for user (\(user))")
            queue.restoreCompletedTransactions(withApplicationUsername: user)
        }
        else {
            logger.log("[Restore] started")
            queue.restoreCompletedTransactions()
        }
    }
    
    func getAppStoreInitiatedInAppPurchases(result: @escaping FlutterResult) {
        let products = appStoreInitiatedProducts.map(mapper.toJson)
        result(products)
    }
    
    deinit {
        logger.log("[Connection] finished")
        queue.remove(self)
    }
}

// MARK: - Transcation processing
extension InAppPurchasesServiceImpl {
    private func processPurchased(_ transaction: SKPaymentTransaction) {
        // No need to keep processed payments in app store initiated products
        appStoreInitiatedProducts.removeAll(where: {$0.productIdentifier == transaction.payment.productIdentifier})
        receiptService.requestReceiptData() {(receipt, error) -> () in
            if receipt != nil {
                let transactionMap = self.mapper.toJson(transaction, receipt!)
                self.channel.invokeMethod(OutMethod.purchaseUpdate.rawValue, arguments: transactionMap)
            }
        }
    }
    
    private func processErrored(_ transaction: SKPaymentTransaction) {
        queue.finishTransaction(transaction)
        let error = transaction.error! as NSError
        let errorMap = errorHandler.buildTransactionError(transaction.payment.productIdentifier, error, nil)
        self.channel.invokeMethod(OutMethod.purchaseError.rawValue, arguments: errorMap)
    }
    
    private func processTransaction(_ transaction: SKPaymentTransaction) {
        let transactionMap = self.mapper.toJson(transaction)
        self.channel.invokeMethod(OutMethod.purchaseUpdate.rawValue, arguments: transactionMap)
    }
}

// MARK: - SKPaymentTransactionObserver
extension InAppPurchasesServiceImpl: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            let sku = transaction.payment.productIdentifier
            switch transaction.transactionState {
            case .purchasing:
                logger.log("[Purchase] sku: \(sku); Transaction state: purchasing")
                processTransaction(transaction)
            case .deferred:
                logger.log("[Purchase] sku: \(sku); Transaction state: deffered")
                processTransaction(transaction)
            case .purchased:
                logger.log("[Purchase] sku: \(sku); Transaction state: purchased")
                processPurchased(transaction)
            case .failed:
                logger.log("[Purchase] sku: \(sku); Transaction state: failed")
                processErrored(transaction)
            case .restored:
                logger.log("[Purchase] sku: \(sku); Transaction state: restored")
            @unknown default:
                logger.log("[Purchase] sku: \(sku); Transaction state: unknown (\(transaction.transactionState))")
            }
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, shouldAddStorePayment payment: SKPayment, for product: SKProduct) -> Bool {
        logger.log("[AppStoreInitiated] sku: \(product.productIdentifier)")
        cacheInAppPurchase(product)
        appStoreInitiatedProducts.append(product)
        channel.invokeMethod(OutMethod.promotedProduct.rawValue, arguments: mapper.toJson(product))
        return false
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        logger.log("[Restore] succeed")
        receiptService.requestReceiptData() {(receipt, error) -> () in
            if receipt != nil {
                var transactionMaps = [[String: Any?]]()
                queue.transactions.forEach({(transaction) -> () in
                    if transaction.transactionState == .restored {
                        transactionMaps.append(self.mapper.toJson(transaction, receipt!))
                        queue.finishTransaction(transaction)
                        self.logger.log("[FinishPurchase] sku: \(transaction.payment.productIdentifier) restored transaction finished")
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
        logger.log("[Restore] failed")
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
                logger.log("[InAppPurchase] request failed")
                result(errorHandler.buildSKError(error as NSError))
            }
        }
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if let result = fetchInAppPurchsesRequestResult[request] {
            fetchInAppPurchsesRequestResult.removeValue(forKey: request)
            response.products.forEach(cacheInAppPurchase)
            
            if !response.invalidProductIdentifiers.isEmpty {
                logger.log("[InAppPurchase] invalid skus: \(response.invalidProductIdentifiers)")
            }
            
            logger.log("[InAppPurchase] request succeed")
            result(inAppPurchasesCache.map(mapper.toJson))
        }
    }
    
    private func cacheInAppPurchase(_ product: SKProduct){
        logger.log("[InAppPurchase] sku: \(product.productIdentifier); added in app purchase to cache")
        inAppPurchasesCache.removeAll(where: {$0.productIdentifier == product.productIdentifier})
        inAppPurchasesCache.append(product)
    }
}
