package com.kroha.in_app_purchase

import com.android.billingclient.api.*
import java.util.HashMap

object FlutterEntitiesBuilder {
    fun buildPurchaseMap(purchase: Purchase): HashMap<String, Any?> {
        val map = HashMap<String, Any?>()

        // part of PurchaseHistory object
        map["skus"] = purchase.skus
        map["date"] = purchase.purchaseTime
        map["quantity"] = purchase.quantity
        map["signature"] = purchase.signature
        map["receipt"] = purchase.originalJson
        map["purchaseToken"] = purchase.purchaseToken

        // additional fields for purchase
        map["transactionId"] = purchase.orderId
        map["packageName"] = purchase.packageName
        map["purchaseState"] = purchase.purchaseState
        map["isAutoRenewing"] = purchase.isAutoRenewing
        map["isAcknowledged"] = purchase.isAcknowledged
        map["developerPayload"] = purchase.developerPayload



        val identifiers = purchase.accountIdentifiers
        if (identifiers != null) {
            map["obfuscatedAccountId"] = identifiers.obfuscatedAccountId
            map["obfuscatedProfileId"] = identifiers.obfuscatedProfileId
        }

        return map
    }

    fun buildPurchaseHistoryRecordMap(record: PurchaseHistoryRecord): HashMap<String, Any> {
        // TODO?
        val map = HashMap<String, Any>()
        map["sku"] = record.sku
        map["signatureAndroid"] = record.signature
        map["purchaseToken"] = record.purchaseToken
        map["transactionDate"] = record.purchaseTime
        map["transactionReceipt"] = record.originalJson
        return map
    }

    fun buildSkuDetailsMap(skuDetails: SkuDetails): HashMap<String, Any> {
        val map = HashMap<String, Any>()

        map["sku"] = skuDetails.sku
        map["price"] = (skuDetails.priceAmountMicros / 1000000f).toString()
        map["currency"] = skuDetails.priceCurrencyCode
        map["localizedPrice"] = skuDetails.price
        map["title"] = skuDetails.title
        map["description"] = skuDetails.description
        map["subscriptionPeriod"] = skuDetails.subscriptionPeriod

        if (skuDetails.type == BillingClient.SkuType.SUBS && skuDetails.introductoryPriceCycles != 0) {
            val discountMap = HashMap<String, Any>()
            discountMap["currency"] = skuDetails.priceCurrencyCode
            discountMap["period"] = skuDetails.introductoryPricePeriod
            discountMap["localizedPrice"] = skuDetails.introductoryPrice
            discountMap["numberOfPeriods"] = skuDetails.introductoryPriceCycles
            discountMap["price"] = (skuDetails.introductoryPriceAmountMicros / 1000000f).toString()
            map["introductoryDiscount"] = discountMap
        }

        map["freeTrial"] = skuDetails.freeTrialPeriod
        map["iconUrl"] = skuDetails.iconUrl
        map["originalLocalizedPrice"] = skuDetails.originalPrice
        map["originalPrice"] = skuDetails.originalPriceAmountMicros / 1000000f

        // TODO: kill if not needed
        map["type"] = skuDetails.type

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
