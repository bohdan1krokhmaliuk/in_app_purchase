package com.kroha.in_app_purchase

import com.android.billingclient.api.*
import java.util.HashMap


object FlutterEntitiesBuilder {
    fun buildPurchaseMap(purchase: Purchase): HashMap<String, Any?> {
        val map = HashMap<String, Any?>()

        // part of PurchaseHistory object
        map["productId"] = purchase.sku
        map["signatureAndroid"] = purchase.signature
        map["purchaseToken"] = purchase.purchaseToken
        map["transactionDate"] = purchase.purchaseTime
        map["transactionReceipt"] = purchase.originalJson

        // additional fields for purchase
        map["orderId"] = purchase.orderId
        map["transactionId"] = purchase.orderId
        map["autoRenewingAndroid"] = purchase.isAutoRenewing
        map["isAcknowledgedAndroid"] = purchase.isAcknowledged
        map["purchaseStateAndroid"] = purchase.purchaseState

        val identifiers = purchase.accountIdentifiers
        if (identifiers != null) {
            map["obfuscatedAccountId"] = identifiers.obfuscatedAccountId
            map["obfuscatedProfileId"] = identifiers.obfuscatedProfileId
        }

        return map
    }

    fun buildPurchaseHistoryRecordMap(record: PurchaseHistoryRecord): HashMap<String, Any> {
        val map = HashMap<String, Any>()
        map["productId"] = record.sku
        map["signatureAndroid"] = record.signature
        map["purchaseToken"] = record.purchaseToken
        map["transactionDate"] = record.purchaseTime
        map["transactionReceipt"] = record.originalJson
        return map
    }

    fun buildSkuDetailsMap(skuDetails: SkuDetails): HashMap<String, Any> {
        val map = HashMap<String, Any>()
        map["productId"] = skuDetails.sku
        map["price"] = (skuDetails.priceAmountMicros / 1000000f).toString()
        map["currency"] = skuDetails.priceCurrencyCode
        map["type"] = skuDetails.type
        map["localizedPrice"] = skuDetails.price
        map["title"] = skuDetails.title
        map["description"] = skuDetails.description
        map["introductoryPrice"] = skuDetails.introductoryPrice
        map["subscriptionPeriodAndroid"] = skuDetails.subscriptionPeriod
        map["freeTrialPeriodAndroid"] = skuDetails.freeTrialPeriod
        map["introductoryPriceCyclesAndroid"] = skuDetails.introductoryPriceCycles
        map["introductoryPricePeriodAndroid"] = skuDetails.introductoryPricePeriod
        map["iconUrl"] = skuDetails.iconUrl
        map["originalJson"] = skuDetails.originalJson
        map["originalPrice"] = skuDetails.originalPriceAmountMicros / 1000000f
        return map
    }

    fun buildBillingResultMap(billingResult: BillingResult): HashMap<String, Any> {
        val errorData: Array<String> = ErrorUtils.getBillingResponseData(billingResult.responseCode)
        return buildBillingResultMap(billingResult, errorData[0], errorData[1])
    }

    fun buildBillingResultMap(
        billingResult: BillingResult,
        errorCode: String,
        message: String
    ): HashMap<String, Any> {
        val map = HashMap<String, Any>()
        map["responseCode"] = billingResult.responseCode
        map["debugMessage"] = billingResult.debugMessage
        map["message"] = message
        map["code"] = errorCode
        return map
    }
}
