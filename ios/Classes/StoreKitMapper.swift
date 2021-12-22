//
//  InAppPurchasesConvertor.swift
//  in_app_purchase
//
//  Created by Bohdan Krokhmaliuk on 19.11.2021.
//

import Foundation
import StoreKit

protocol StoreKitMapper {
    @available(iOS 12.2, *)
    func toJson(_ discount: SKProductDiscount) -> [String: Any?]
    func toJson(_ transaction: SKPaymentTransaction) -> [String: Any?]
    func toJson(_ transaction: SKPaymentTransaction, _ receipt: String) -> [String: Any?]
    func toJson(_ product: SKProduct) -> [String: Any?]
}

struct StoreKitMapperImpl : StoreKitMapper {
    func toJson(_ product: SKProduct) -> [String: Any?] {
        let formatter = NumberFormatter();
        formatter.numberStyle = .currency
        formatter.locale = product.priceLocale
        let localizedPrice = formatter.string(from: product.price)
        
        var periodUnitIOS: UInt?
        var periodNumberIOS: Int?
        var subscriptionGroupId: String?
        var discounts = [[String: Any?]]()
        var introductoryDiscount: [String: Any?]?
        if #available(iOS 12.2, *){
            if let introductory = product.introductoryPrice {
                introductoryDiscount = toJson(introductory)
            }
            periodNumberIOS = product.subscriptionPeriod?.numberOfUnits
            periodUnitIOS = product.subscriptionPeriod?.unit.rawValue
            discounts = product.discounts.map({return toJson($0)})
            subscriptionGroupId = product.subscriptionGroupIdentifier
        }
        
        // TODO: check decimal on flutter side
        return [
            "sku": product.productIdentifier,
            "price": product.price,
            "localizedPrice": localizedPrice,
            "title": product.localizedTitle,
            "description": product.description,
            "currency": product.priceLocale.currencyCode,
            "subscriptionPeriodUnit": periodUnitIOS,
            "subscriptionPeriodNumber": periodNumberIOS,
            "introductoryDiscount": introductoryDiscount,
            "subscriptionGroupId": subscriptionGroupId,
            "discounts": discounts,
        ]
    }
    
    @available(iOS 12.2, *)
    func toJson(_ discount: SKProductDiscount) -> [String: Any?] {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = discount.priceLocale
        let localizedPrice = formatter.string(from: discount.price)
        
        return  [
            "price": discount.price,
            "type": discount.type.rawValue,
            "localizedPrice": localizedPrice,
            "identifier": discount.identifier,
            "numberOfPeriods": discount.numberOfPeriods,
            "paymentMode": discount.paymentMode.rawValue,
            "currency": discount.priceLocale.currencyCode,
            "periodUnit": discount.subscriptionPeriod.unit.rawValue,
            "numberOfUnits": discount.subscriptionPeriod.numberOfUnits
        ]
    }
    
    func toJson(_ transaction: SKPaymentTransaction) -> [String: Any?] {
        return transactionToJson(transaction, nil)
    }
    
    func toJson(_ transaction: SKPaymentTransaction, _ receipt: String) -> [String: Any?] {
        return transactionToJson(transaction, receipt)
    }
    
    private func transactionToJson(_ transaction: SKPaymentTransaction, _ receipt: String?) -> [String: Any?] {
        var date: NSNumber?
        var originalDate: NSNumber?
        
        if transaction.transactionDate != nil {
            date = NSNumber(value: lround(transaction.transactionDate!.timeIntervalSince1970 * 1000))
        }
        if transaction.original?.transactionDate != nil {
            originalDate = NSNumber(value: lround(transaction.original!.transactionDate!.timeIntervalSince1970 * 1000))
        }
        
        return [
            "date": date,
            "receipt": receipt,
            "quantity": transaction.payment.quantity,
            "sku": transaction.payment.productIdentifier,
            "transactionId": transaction.transactionIdentifier,
            "applicationUsername": transaction.payment.applicationUsername,
            "transactionStateIOS": NSNumber(value: transaction.transactionState.rawValue),
            "originalTransactionDate": originalDate,
            "originalTransactionIdentifier": transaction.original?.transactionIdentifier,
        ]
    }
}
