package com.kroha.in_app_purchase.billingClientService

import android.app.Activity
import com.android.billingclient.api.*
import com.android.billingclient.api.BillingClient.*
import com.kroha.in_app_purchase.ErrorUtils
import com.kroha.in_app_purchase.mapper.BillingClientMapper
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.*

class BillingClientServiceImpl(
    private val client: BillingClient,
    private val channel: MethodChannel,
    private val mapper: BillingClientMapper
): BillingClientService {
    private val cachedSkuDetails = ArrayList<SkuDetails>()
    override val isReady: Boolean
        get() = client.isReady

    override fun initConnection(result: Result) {
        client.startConnection(object : BillingClientStateListener {
            override fun onBillingSetupFinished(billingResult: BillingResult) {
                val isConnected = billingResult.responseCode == BillingResponseCode.OK
                channel.invokeMethod("connection-updated", mapOf("connected" to isConnected))

                if (isConnected) {
                    result.success(true)
                } else {
                    result.error("initConnection", "responseCode: ${billingResult.responseCode}", billingResult.debugMessage)
                }
            }

            override fun onBillingServiceDisconnected() {
                channel.invokeMethod("connection-updated", mapOf("connected" to false))
            }
        })
    }

    override fun endConnection(result: Result) {
        endConnection()
        result.success(true)
    }

    override fun endConnection() {
        client.endConnection()
    }

    override fun consumeAllItems(result: Result) {
        client.queryPurchasesAsync(SkuType.INAPP) { billingResult, purchases ->
            if (billingResult.responseCode != BillingResponseCode.OK) {
                val resultMap = ErrorUtils.getBillingResponseData(billingResult.responseCode)
                result.error(resultMap[0], resultMap[1], billingResult.debugMessage)
                return@queryPurchasesAsync
            }

            if (purchases.isEmpty()) {
                result.error("consumeAllItems", "refreshItem", "No purchases found")
                return@queryPurchasesAsync
            }

            val array: ArrayList<String> = ArrayList()
            for (purchase in purchases) {
                val consumeParams = ConsumeParams.newBuilder()
                    .setPurchaseToken(purchase.purchaseToken)
                    .build()

                client.consumeAsync(consumeParams) { _, token ->
                    array.add(token)
                    if (purchases.size == array.size) result.success(array)
                }
            }
        }
    }

    override fun getInAppPurchasesByType(result: Result, skuList: ArrayList<String>, type: String) {
        val params = SkuDetailsParams.newBuilder().setSkusList(skuList).setType(type).build()
        client.querySkuDetailsAsync(params) { billingResult, details ->
            if (billingResult.responseCode != BillingResponseCode.OK) {
                val errorData = ErrorUtils.getBillingResponseData(billingResult.responseCode)
                result.error("getItemsByType", errorData[0], errorData[1])
                return@querySkuDetailsAsync
            }

            details?.forEach {
                cachedSkuDetails.removeAll { d -> d.sku == it.sku }
                cachedSkuDetails.add(it)
            }

            val maps = details?.map { d -> mapper.toJson(d) } ?: HashMap<String,Any>()
            result.success(maps)
        }
    }

    override fun getPurchasedProductsByType(result: Result, type: String) {
        client.queryPurchasesAsync(type) { billingResult, purchases ->
            if (billingResult.responseCode != BillingResponseCode.OK) {
                val resultMap = ErrorUtils.getBillingResponseData(billingResult.responseCode)
                result.error(resultMap[0], resultMap[1], billingResult.debugMessage)
                return@queryPurchasesAsync
            }

            val maps = purchases.map { p -> mapper.toJson(p) }
            result.success(maps)
        }
    }

    override fun getPurchaseHistoryByType(result: Result, type: String) {
        client.queryPurchaseHistoryAsync(type)  { billingResult, historyRecords ->
            if (billingResult.responseCode != BillingResponseCode.OK) {
                val errorData: Array<String> = ErrorUtils.getBillingResponseData(billingResult.responseCode)
                result.error("getPurchaseHistoryByType", errorData[0], errorData[1])
                return@queryPurchaseHistoryAsync
            }

            val maps = historyRecords?.map { h -> mapper.toJson(h) } ?: HashMap<String,Any>()
            result.success(maps)
        }
    }

    override fun acknowledgePurchase(result: Result, token: String) {
        val acknowledgePurchaseParams = AcknowledgePurchaseParams.newBuilder()
            .setPurchaseToken(token)
            .build()

        client.acknowledgePurchase(acknowledgePurchaseParams) { billingResult ->
            if (billingResult.responseCode != BillingResponseCode.OK) {
                val errorData: Array<String> = ErrorUtils.getBillingResponseData(billingResult.responseCode)
                result.error("acknowledgePurchase", errorData[0], errorData[1])
                return@acknowledgePurchase
            }

            result.success(true)
        }
    }

    override fun consumeProduct(result: Result, token: String) {
        val params = ConsumeParams.newBuilder()
            .setPurchaseToken(token)
            .build()

        client.consumeAsync(params) { billingResult, outToken ->
            if (billingResult.responseCode != BillingResponseCode.OK) {
                val errorData: Array<String> = ErrorUtils.getBillingResponseData(billingResult.responseCode)
                result.error("consumeProduct", errorData[0], errorData[1])
                return@consumeAsync
            }

            result.success(outToken)
        }
    }

    override fun buyItem(
        result: Result,
        activity: Activity,
        sku: String,
        obfuscatedAccountId: String?,
        obfuscatedProfileId: String?
    ) {
        val selectedSku: SkuDetails? = cachedSkuDetails.firstOrNull { d -> d.sku == sku }
        if (selectedSku == null) {
            val debugMessage = "The sku was not found. Please fetch products first by calling getItems"
            return result.error("in_app_purchase", "buyItemByType", debugMessage)
        }

        val builder = BillingFlowParams.newBuilder()
        if (obfuscatedAccountId != null) builder.setObfuscatedAccountId(obfuscatedAccountId)
        if (obfuscatedProfileId != null) builder.setObfuscatedProfileId(obfuscatedProfileId)
        builder.setSkuDetails(selectedSku)

        client.launchBillingFlow(activity, builder.build())
        result.success(null)
    }


    override fun updateSubscription(
        result: Result,
        activity: Activity,
        newSubscriptionSku: String,
        oldSkuPurchaseToken: String,
        prorationMode: Int?,
        obfuscatedAccountId: String?,
        obfuscatedProfileId: String?
    ) {
        val selectedSku: SkuDetails? = cachedSkuDetails.firstOrNull { d -> d.sku == newSubscriptionSku }
        if (selectedSku == null) {
            val debugMessage = "The sku was not found. Please fetch products first by calling getItems"
            return result.error("in_app_purchase", "updateSubscription", debugMessage)
        } else if (selectedSku.type != SkuType.SUBS){
            val debugMessage = "Selected sku is not a subscription"
            return result.error("in_app_purchase", "updateSubscription", debugMessage)
        }

        val updateParams = BillingFlowParams.SubscriptionUpdateParams.newBuilder()
            .setOldSkuPurchaseToken(oldSkuPurchaseToken)
            .setReplaceSkusProrationMode(prorationMode ?: 0)
            .build()

        val builder = BillingFlowParams.newBuilder()
        if (obfuscatedAccountId != null) builder.setObfuscatedAccountId(obfuscatedAccountId)
        if (obfuscatedProfileId != null) builder.setObfuscatedProfileId(obfuscatedProfileId)
        builder.setSubscriptionUpdateParams(updateParams)
        builder.setSkuDetails(selectedSku)

        client.launchBillingFlow(activity, builder.build())
        result.success(null)
    }
}