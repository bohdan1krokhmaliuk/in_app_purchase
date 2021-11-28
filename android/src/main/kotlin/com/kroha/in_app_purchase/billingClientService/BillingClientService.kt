package com.kroha.in_app_purchase.billingClientService

import android.app.Activity
import io.flutter.plugin.common.MethodChannel.Result

interface BillingClientService {
    val isReady: Boolean

    fun initConnection(result: Result)
    fun endConnection(result: Result)
    fun endConnection()

    fun setLogging(enabled: Boolean, result: Result)
    fun consumeAllItems(result: Result)
    fun getInAppPurchasesByType(result: Result, skuList: ArrayList<String>, type: String)
    fun getPurchasedProductsByType(result: Result, type: String)
    fun getPurchaseHistoryByType(result: Result, type: String)
    fun acknowledge(result: Result, token: String)
    fun consumeProduct(result: Result, token: String)

    fun buyItem(
        result: Result,
        activity: Activity,
        sku: String,
        obfuscatedAccountId: String?,
        obfuscatedProfileId: String?
    )

    fun updateSubscription(
        result: Result,
        activity: Activity,
        newSubscriptionSku: String,
        oldSkuPurchaseToken: String,
        prorationMode: Int?,
        obfuscatedAccountId: String?,
        obfuscatedProfileId: String?
    )
}

