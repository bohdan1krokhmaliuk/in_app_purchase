package com.kroha.in_app_purchase.billingClientService

import android.app.Activity
import com.android.billingclient.api.*
import com.android.billingclient.api.BillingClient.*
import com.kroha.in_app_purchase.OutMethod
import com.kroha.in_app_purchase.errorHandler.*
import com.kroha.in_app_purchase.logger.Logger
import com.kroha.in_app_purchase.mapper.BillingClientMapper
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.*

class BillingClientServiceImpl(
    private val logger: Logger,
    private val client: BillingClient,
    private val channel: MethodChannel,
    private val errorHandler: ErrorHandler,
    private val mapper: BillingClientMapper
): BillingClientService {
    private val inAppPurchases = ArrayList<SkuDetails>()
    override val isReady: Boolean
        get() = client.isReady

    override fun enableLogging(enable: Boolean, result: Result){
        if (enable) logger.enable() else logger.disable()
        result.success(enable)
    }

    override fun initConnection(result: Result) {
        client.startConnection(object : BillingClientStateListener {
            override fun onBillingSetupFinished(billingResult: BillingResult) {
                val isConnected = billingResult.responseCode == BillingResponseCode.OK
                channel.invokeMethod(OutMethod.connectionUpdate, mapOf("connected" to isConnected))

                if (isConnected) {
                    logger.log("[Connection] initialized")
                    return result.success(true)
                }

                logger.log("[Connection] failed initialization")
                errorHandler.submitBillingErrorResult(result, billingResult)
            }

            override fun onBillingServiceDisconnected() {
                logger.log("[Connection] finished")
                channel.invokeMethod(OutMethod.connectionUpdate, mapOf("connected" to false))
            }
        })
    }

    override fun endConnection(result: Result) {
        endConnection()
        result.success(true)
    }

    override fun endConnection() {
        client.endConnection()
        logger.log("[Connection] finished")
    }

    override fun getInAppPurchasesByType(result: Result, skuList: ArrayList<String>, type: String) {
        logger.log("[InAppPurchase] in app purchases requested")
        val params = SkuDetailsParams.newBuilder().setSkusList(skuList).setType(type).build()
        client.querySkuDetailsAsync(params) { billingResult, details ->
            if (billingResult.responseCode != BillingResponseCode.OK) {
                logger.log("[InAppPurchase] failed to fetch in app purchases")
                errorHandler.submitBillingErrorResult(result, billingResult)
                return@querySkuDetailsAsync
            }

            details?.forEach {
                inAppPurchases.removeAll { d -> d.sku == it.sku }
                inAppPurchases.add(it)
                logger.log("[InAppPurchase] sku: ${it.sku}; added in app purchase to cache")
            }

            logger.log("[InAppPurchase] in app purchases fetched successfully")
            val maps = details?.map { d -> mapper.toJson(d) } ?: HashMap<String,Any>()
            result.success(maps)
        }
    }

    override fun getPurchasedProductsByType(result: Result, type: String) {
        logger.log("[Restore] started for $type")
        client.queryPurchasesAsync(type) { billingResult, purchases ->
            if (billingResult.responseCode != BillingResponseCode.OK) {
                logger.log("[Restore] failed for $type")
                errorHandler.submitBillingErrorResult(result, billingResult)
                return@queryPurchasesAsync
            }

            val maps = purchases.map { p -> mapper.toJson(p) }
            logger.log("[Restore] succeed for $type")
            result.success(maps)
        }
    }

    override fun getPurchaseHistoryByType(result: Result, type: String) {
        logger.log("[PurchaseHistory] requested for $type")
        client.queryPurchaseHistoryAsync(type)  { billingResult, historyRecords ->
            if (billingResult.responseCode != BillingResponseCode.OK) {
                logger.log("[PurchaseHistory] failed for $type")
                errorHandler.submitBillingErrorResult(result, billingResult)
                return@queryPurchaseHistoryAsync
            }

            val maps = historyRecords?.map { h -> mapper.toJson(h) } ?: HashMap<String,Any>()
            logger.log("[PurchaseHistory] succeed for $type")
            result.success(maps)
        }
    }

    override fun acknowledge(result: Result, token: String) {
        val acknowledgePurchaseParams = AcknowledgePurchaseParams.newBuilder()
            .setPurchaseToken(token)
            .build()

        logger.log("[FinishPurchase] requested for purchase token $token")
        client.acknowledgePurchase(acknowledgePurchaseParams) { billingResult ->
            if (billingResult.responseCode != BillingResponseCode.OK) {
                logger.log("[Finish purchase] failed for purchase token $token")
                errorHandler.submitBillingErrorResult(result, billingResult)
                return@acknowledgePurchase
            }

            logger.log("[FinishPurchase] succeed for purchase token $token")
            result.success(true)
        }
    }

    override fun buyItem(
        result: Result,
        activity: Activity,
        sku: String,
        obfuscatedAccountId: String?,
        obfuscatedProfileId: String?
    ) {
        val selectedSku: SkuDetails? = inAppPurchases.firstOrNull { d -> d.sku == sku }
        if (selectedSku == null) {
            val debugMessage = "The sku was not found. Please fetch products first by calling getItems"
            return errorHandler.submitArgsErrorResult(result, debugMessage)
        }

        logger.log("[Purchase] sku: $sku; started")
        val builder = BillingFlowParams.newBuilder()
        if (obfuscatedAccountId != null) {
            builder.setObfuscatedAccountId(obfuscatedAccountId)
            logger.log("[Purchase] sku: $sku; account set ($obfuscatedAccountId)")
        }
        if (obfuscatedProfileId != null) {
            builder.setObfuscatedProfileId(obfuscatedProfileId)
            logger.log("[Purchase] sku: $sku; profile set ($obfuscatedProfileId)")
        }
        builder.setSkuDetails(selectedSku)

        logger.log("[Purchase] sku: $sku; launched billing flow")
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
        val selectedSku: SkuDetails? = inAppPurchases.firstOrNull { d -> d.sku == newSubscriptionSku }
        if (selectedSku == null) {
            val debugMessage = "The sku was not found. Please fetch products first by calling getItems"
            return errorHandler.submitArgsErrorResult(result, debugMessage)
        } else if (selectedSku.type != SkuType.SUBS){
            val debugMessage = "Selected sku is not a subscription"
            return errorHandler.submitArgsErrorResult(result, debugMessage)
        }

        logger.log("[Purchase] sku: $newSubscriptionSku; old token: $oldSkuPurchaseToken subscription update started")
        val updateParams = BillingFlowParams.SubscriptionUpdateParams.newBuilder()
            .setOldSkuPurchaseToken(oldSkuPurchaseToken)
            .setReplaceSkusProrationMode(prorationMode ?: 0)
            .build()

        val builder = BillingFlowParams.newBuilder()
        if (obfuscatedAccountId != null) {
            builder.setObfuscatedAccountId(obfuscatedAccountId)
            logger.log("[Purchase] sku: $newSubscriptionSku; account set ($obfuscatedAccountId)")
        }
        if (obfuscatedProfileId != null) {
            builder.setObfuscatedProfileId(obfuscatedProfileId)
            logger.log("[Purchase] sku: $newSubscriptionSku; profile set ($obfuscatedProfileId)")
        }
        builder.setSubscriptionUpdateParams(updateParams)
        builder.setSkuDetails(selectedSku)

        logger.log("[Purchase] sku: $newSubscriptionSku; launched billing flow for subscription update")
        client.launchBillingFlow(activity, builder.build())
        result.success(null)
    }

    override fun consumeProduct(result: Result, token: String) {
        val params = ConsumeParams.newBuilder()
            .setPurchaseToken(token)
            .build()

        logger.log("[Consume] requested for purchase token $token")
        client.consumeAsync(params) { billingResult, outToken ->
            if (billingResult.responseCode != BillingResponseCode.OK) {
                logger.log("[Consume] failed for purchase token $token")
                errorHandler.submitBillingErrorResult(result, billingResult)
                return@consumeAsync
            }

            logger.log("[Consume] succeed for purchase token $token")
            result.success(outToken)
        }
    }

    override fun consumeAllItems(result: Result) {
        logger.log("[Consume] started for all products")
        client.queryPurchasesAsync(SkuType.INAPP) { billingResult, purchases ->
            if (billingResult.responseCode != BillingResponseCode.OK) {
                errorHandler.submitBillingErrorResult(result, billingResult)
                logger.log("[Consume] failed")
                return@queryPurchasesAsync
            }

            if (purchases.isEmpty()) {
                errorHandler.submitPurchaseErrorResult(result, PurchaseError.E_CONSUMED_ALL)
                logger.log("[Consume] no consumable purchases")
                return@queryPurchasesAsync
            }

            val array: ArrayList<String> = ArrayList()
            for (purchase in purchases) {
                val consumeParams = ConsumeParams.newBuilder()
                    .setPurchaseToken(purchase.purchaseToken)
                    .build()

                logger.log("[Consume] skus: ${purchase.skus}; consume requested")
                client.consumeAsync(consumeParams) { consumeResult, token ->
                    if (consumeResult.responseCode != BillingResponseCode.OK){
                        logger.log("[Consume] skus: ${purchase.skus}; succeed")
                    }
                    else {
                        logger.log("[Consume] skus: ${purchase.skus}; failed")
                    }

                    array.add(token)
                    if (purchases.size == array.size) {
                        logger.log("[Consume] all purchases consumption finished")
                        result.success(array)
                    }
                }
            }
        }
    }
}