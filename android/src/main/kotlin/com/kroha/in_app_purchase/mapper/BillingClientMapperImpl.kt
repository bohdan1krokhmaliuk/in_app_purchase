package com.kroha.in_app_purchase.mapper

import com.android.billingclient.api.*
import com.kroha.in_app_purchase.errorHandler.*
import java.util.HashMap

class BillingClientMapperImpl : BillingClientMapper {
    override fun toJson(purchase: Purchase): HashMap<String, Any?> {
        val map = HashMap<String, Any?>()

        // part of PurchaseHistory object
        map["sku"] = purchase.skus.first()
        map["skus"] = purchase.skus
        map["date"] = purchase.purchaseTime
        map["quantity"] = purchase.quantity
        map["signature"] = purchase.signature
        map["receipt"] = purchase.originalJson
        map["purchaseToken"] = purchase.purchaseToken
        map["developerPayload"] = purchase.developerPayload

        // additional fields for purchase
        map["transactionId"] = purchase.orderId
        map["packageName"] = purchase.packageName
        map["purchaseState"] = purchase.purchaseState
        map["isAutoRenewing"] = purchase.isAutoRenewing
        map["isAcknowledged"] = purchase.isAcknowledged

        val identifiers = purchase.accountIdentifiers
        if (identifiers != null) {
            map["obfuscatedAccountId"] = identifiers.obfuscatedAccountId
            map["obfuscatedProfileId"] = identifiers.obfuscatedProfileId
        }

        return map
    }

    override fun toJson(record: PurchaseHistoryRecord): HashMap<String, Any> {
        val map = HashMap<String, Any>()

        map["skus"] = record.skus
        map["sku"] = record.skus.first()
        map["quantity"] = record.quantity
        map["signatureAndroid"] = record.signature
        map["purchaseToken"] = record.purchaseToken
        map["transactionDate"] = record.purchaseTime
        map["transactionReceipt"] = record.originalJson
        map["developerPayload"] = record.developerPayload

        return map
    }

    override fun toJson(skuDetails: SkuDetails): HashMap<String, Any> {
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

        map["type"] = skuDetails.type
        map["iconUrl"] = skuDetails.iconUrl
        map["freeTrial"] = skuDetails.freeTrialPeriod
        map["originalLocalizedPrice"] = skuDetails.originalPrice
        map["originalPrice"] = skuDetails.originalPriceAmountMicros / 1000000f

        return map
    }

    override fun toJson(sku: String?, skus: ArrayList<String>?, billingResult: BillingResult): HashMap<String, Any?> {
        val error = ErrorHandler.getBillingResponseError(billingResult.responseCode)
        val map = HashMap<String, Any?>()

        map["message"] = error.message
        map["code"] = error.code
        map["skus"] = skus
        map["sku"] = sku

        return map
    }


}
