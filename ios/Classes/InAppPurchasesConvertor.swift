//
//  InAppPurchasesConvertor.swift
//  in_app_purchase
//
//  Created by Bohdan Krokhmaliuk on 19.11.2021.
//

import Foundation
import StoreKit

struct IAPConvertor {
    static func convertSKPaymentTransaction(_ transaction: SKPaymentTransaction, _ receipt: String?) -> [String: Any?] {
        var date: NSNumber?
        var originalDate: NSNumber?
        
        if transaction.transactionDate != nil {
            date = NSNumber(value: lround(transaction.transactionDate!.timeIntervalSince1970 * 1000))
        }
        if transaction.original?.transactionDate != nil{
            originalDate = NSNumber(value: lround(transaction.original!.transactionDate!.timeIntervalSince1970 * 1000))
        }
            
        return [
            "transactionDate": date,
            "transactionReceipt": receipt,
            "originalTransactionDateIOS": originalDate,
            "transactionId": transaction.transactionIdentifier,
            "productId": transaction.payment.productIdentifier,
            "transactionStateIOS": NSNumber(value: transaction.transactionState.rawValue),
            "originalTransactionIdentifierIOS": transaction.original?.transactionIdentifier,
        ]
    }
    
    static func convertSKProduct(_ product: SKProduct) -> [String: Any?] {
        let formatter = NumberFormatter();
        formatter.numberStyle = .currency
        formatter.locale = product.priceLocale
        let localizedPrice = formatter.string(from: product.price)
    
        
        var periodUnitIOS: String?
        var periodNumberIOS: String?
        var introductoryDiscount: [String: Any?]?
        if #available(iOS 11.2, *){
            periodNumberIOS = String.localizedStringWithFormat("%lu", product.subscriptionPeriod?.numberOfUnits ?? 0)
            introductoryDiscount = convertDiscount(product.introductoryPrice!)
            switch product.subscriptionPeriod?.unit {
                case .day:
                    periodUnitIOS = "DAY"
                case .week:
                    periodUnitIOS = "WEEK"
                case .month:
                    periodUnitIOS = "MONTH"
                case .year:
                    periodUnitIOS = "YEAR"
                case .none:
                    periodUnitIOS = ""
                @unknown default:
                    periodUnitIOS = ""
            }
        }
        
        var discounts: [[String: Any?]]?
        if #available(iOS 12.2, *){
            discounts = convertDiscounts(product.discounts)
        }
        
        // TODO: check decimal on flutter side
        return [
            "productId": product.productIdentifier,
            "price": product.price,
            "currency": product.priceLocale.currencyCode,
            "title": product.localizedTitle,
            "description": product.description,
            "localizedPrice": localizedPrice,
            "subscriptionPeriodNumberIOS": periodNumberIOS,
            "subscriptionPeriodUnitIOS": periodUnitIOS,
            "introductoryDiscount": introductoryDiscount,
            "discounts": discounts,
            
        ]
    }
    
    @available(iOS 11.2, *)
    static func convertDiscounts(_ discounts: [SKProductDiscount]) -> [[String: Any?]] {
        var mappedDiscounts = [[String: Any?]]()
        discounts.forEach({mappedDiscounts.append(convertDiscount($0))})
        
        return mappedDiscounts
    }
    
    @available(iOS 11.2, *)
    static func convertDiscount(_ discount: SKProductDiscount) -> [String: Any?]{
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = discount.priceLocale
        
        let localizedPrice = formatter.string(from: discount.price)
        var numberOfPeriods: NSNumber?
        
        var paymentMode: String?
        switch discount.paymentMode {
            case .freeTrial:
                paymentMode = "FREETRIAL"
                numberOfPeriods = NSNumber(value:discount.subscriptionPeriod.numberOfUnits)
            case .payAsYouGo:
                paymentMode = "PAYASYOUGO"
                numberOfPeriods = NSNumber(value: discount.numberOfPeriods)
            case .payUpFront:
                paymentMode = "PAYUPFRONT"
                numberOfPeriods = NSNumber(value:discount.subscriptionPeriod.numberOfUnits)
            @unknown default:
                paymentMode = ""
                numberOfPeriods = NSNumber(value:discount.subscriptionPeriod.numberOfUnits)
        }
        
        var subscriptionPeriods: String?
        switch discount.subscriptionPeriod.unit {
            case .day:
                subscriptionPeriods = "DAY"
            case .week:
                subscriptionPeriods = "WEEK"
            case .month:
                subscriptionPeriods = "MONTH"
            case .year:
                subscriptionPeriods = "YEAR"
            @unknown default:
                subscriptionPeriods = ""
        }
        
        var discountType: String?
        var discountIdentifier: String?
        if #available(iOS 12.2, *){
            discountIdentifier = discount.identifier
            switch discount.type {
                case .introductory:
                    discountType = "INTRODUCTORY"
                case .subscription:
                    discountType = "SUBSCRIPTION"
                @unknown default:
                    discountType = ""
            }
        }
        
        
        return  [
            "identifier": discountIdentifier,
            "type": discountType,
            "numberOfPeriods": numberOfPeriods,
            "price": discount.price,
            "localizedPrice": localizedPrice,
            "paymentMode": paymentMode,
            "subscriptionPeriod": subscriptionPeriods
        ]
    }
    
}
