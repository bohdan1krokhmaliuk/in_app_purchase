package com.kroha.in_app_purchase

import android.app.Activity
import android.app.Application
import android.content.Context
import android.os.Bundle
import com.android.billingclient.api.*
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.*
import io.flutter.plugin.common.MethodChannel
import java.lang.Error

import com.kroha.in_app_purchase.FlutterEntitiesBuilder.buildPurchaseMap
import com.kroha.in_app_purchase.FlutterEntitiesBuilder.buildSkuDetailsMap
import com.kroha.in_app_purchase.FlutterEntitiesBuilder.buildBillingResultMap
import com.kroha.in_app_purchase.FlutterEntitiesBuilder.buildPurchaseHistoryRecordMap





class AndroidBillingClient: MethodCallHandler, Application.ActivityLifecycleCallbacks {
    private lateinit var channel: MethodChannel
    private lateinit var applicationContext: Context
    private var activity: Activity? = null

    private var billingClient: BillingClient? = null
    private val skus: ArrayList<SkuDetails> = ArrayList()

    companion object {
        private const val initConnection = "initConnection"
        private const val endConnection = "endConnection"
        private const val consumeAllItems = "consumeAllItems"
        private const val getItemsByType = "getItemsByType"
        private const val getAvailableItemsByType = "getAvailableItemsByType"
        private const val getPurchaseHistoryByType = "getPurchaseHistoryByType"
        private const val buyItemByType = "buyItemByType"
        private const val acknowledgePurchase = "acknowledgePurchase"
        private const val consumeProduct = "consumeProduct"

        private const val errorMessage = "IAP not prepared. Check if Google Play service is available."
    }

    private val supportedMethods
        get() = arrayOf(
            initConnection,
            endConnection,
            consumeAllItems,
            getItemsByType,
            getAvailableItemsByType,
            getPurchaseHistoryByType,
            buyItemByType,
            acknowledgePurchase,
            consumeProduct
        )

    fun setup(channel: MethodChannel, applicationContext: Context) {
        this.applicationContext = applicationContext
        this.channel = channel
    }

    fun setActivity(activity: Activity?){
        this.activity = activity
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        if (!supportedMethods.contains(call.method)) {
            return result.notImplemented()
        }

        when (call.method) {
            endConnection -> endConnection(result)
            initConnection -> initConnection(result)
            consumeAllItems -> consumeAllItems(result)
            getItemsByType -> {
                val type: String? = call.argument("type")
                val skuList: ArrayList<String>? = call.argument("skus")

                if(type == null || skuList == null) {
                    return result.error(call.method, "E_WRONG_PARAMS", "type and skuList must be NonNullable for method")
                }

                getItemsByType(result,skuList,type)
            }
            getAvailableItemsByType -> {
                val type: String = call.argument("type")
                    ?: return result.error(call.method, "E_WRONG_PARAMS", "type must be NonNullable for method")

                getItemsByType(result,type)
            }
            getPurchaseHistoryByType -> {
                val type: String = call.argument("type")
                    ?: return result.error(call.method, "E_WRONG_PARAMS", "type must be NonNullable for method")

                getPurchaseHistoryByType(result,type)
            }
            buyItemByType -> {
                val sku: String? = call.argument("sku")
                val type: String? = call.argument("type")
                val prorationMode: Int? = call.argument("prorationMode")
                val obfuscatedAccountId: String? = call.argument("obfuscatedAccountId")
                val obfuscatedProfileId: String? = call.argument("obfuscatedProfileId")
                val oldSku: String? = call.argument("oldSku")
                val purchaseToken: String? = call.argument("purchaseToken")

                if(type == null || sku == null || prorationMode == null) {
                    return result.error(call.method, "E_WRONG_PARAMS", "type and sku must be NonNullable for method")
                }

                buyItemByType(
                    result,
                    sku,
                    type,
                    prorationMode,
                    obfuscatedAccountId,
                    obfuscatedProfileId,
                    oldSku,
                    purchaseToken
                )
            }
            acknowledgePurchase -> {
                val token: String = call.argument("token")
                    ?: return result.error(call.method, "E_WRONG_PARAMS", "token must be NonNullable for method")

                acknowledgePurchase(result,token)
            }
            consumeProduct -> {
                val token: String = call.argument("token")
                    ?: return result.error(call.method, "E_WRONG_PARAMS", "token must be NonNullable for method")

                consumeProduct(result,token)
            }
            else -> result.notImplemented()
        }
    }

    override fun onActivityCreated(activity: Activity, bundle: Bundle?) {}

    override fun onActivitySaveInstanceState(activity: Activity, bundle: Bundle) {}

    override fun onActivityStarted(activity: Activity) {}

    override fun onActivityResumed(activity: Activity) {}

    override fun onActivityPaused(activity: Activity) {}

    override fun onActivityStopped(activity: Activity) {}

    override fun onActivityDestroyed(activity: Activity) {
        if (this.activity == activity) {
            activity.application.unregisterActivityLifecycleCallbacks(this)
            endBillingClientConnection()
        }
    }

    private val purchasesUpdatedListener =
        PurchasesUpdatedListener { billingResult, purchases ->
            if (billingResult.responseCode != BillingClient.BillingResponseCode.OK) {
                val resultMap = buildBillingResultMap(billingResult)
                channel.invokeMethod("purchase-error", resultMap)
                return@PurchasesUpdatedListener
            }
            if (purchases == null) {
                val errorData: Array<String> = ErrorUtils.getBillingResponseData(billingResult.responseCode)
                val resultMap = buildBillingResultMap(billingResult, errorData[0], "purchases returns null")
                channel.invokeMethod("purchase-error", resultMap)
                return@PurchasesUpdatedListener
            }
            for (purchase in purchases) {
                channel.invokeMethod("purchase-updated", buildPurchaseMap(purchase))
            }
        }

    private fun endBillingClientConnection() {
        if (billingClient != null) {
            billingClient!!.endConnection()
            billingClient = null
        }
    }

    private fun initConnection(result: Result) {
        if (billingClient != null) {
            return result.success("Already started. Call endConnection method if you want to start over.")
        }

        billingClient = BillingClient.newBuilder(applicationContext).setListener(purchasesUpdatedListener)
            .enablePendingPurchases()
            .build()

        billingClient!!.startConnection(object : BillingClientStateListener {
            private var isSetUp = false

            override fun onBillingSetupFinished(billingResult: BillingResult) {
                if (isSetUp) return
                val item: HashMap<String, Boolean> = HashMap()
                val isConnected = billingResult.responseCode == BillingClient.BillingResponseCode.OK
                item["connected"] = isConnected
                channel.invokeMethod("connection-updated", item)

                if (isConnected) {
                    result.success(true)
                } else {
                    result.error("initConnection", "responseCode: ${billingResult.responseCode}", billingResult.debugMessage)
                }

                isSetUp = true
            }

            override fun onBillingServiceDisconnected() {
                val item: HashMap<String, Boolean> = HashMap()
                item["connected"] = false
                channel.invokeMethod("connection-updated", item )
                isSetUp = false
            }
        })
    }

    private fun endConnection(result: Result) {
        endBillingClientConnection()
        result.success(true)
    }

    private fun consumeAllItems(result: Result) {
        try {
            if (billingClient == null || !billingClient!!.isReady) {
                return result.error("consumeAllItems", errorMessage, "")
            }

            billingClient!!.queryPurchasesAsync( BillingClient.SkuType.INAPP ) { billingResult, purchases ->
                if (billingResult.responseCode != BillingClient.BillingResponseCode.OK) {
                    val resultMap = ErrorUtils.getBillingResponseData(billingResult.responseCode)
                    result.error(resultMap[0], resultMap[1], billingResult.debugMessage)
                }
                if(purchases.isEmpty()) {
                     result.error("consumeAllItems", "refreshItem", "No purchases found")
                }
                else {
                    val array: ArrayList<String> = ArrayList()
                    for (purchase in purchases) {
                        val consumeParams = ConsumeParams.newBuilder()
                            .setPurchaseToken(purchase.purchaseToken)
                            .build()

                        val listener =
                            ConsumeResponseListener { _, outToken ->
                                array.add(outToken)
                                if (purchases.size == array.size) {
                                    result.success(array)
                                }
                            }

                        billingClient!!.consumeAsync(consumeParams, listener)
                    }
                }
            }

        } catch (err: Error) {
            result.error("consumeAllItems", err.message, "")
        }
    }

    private fun getItemsByType(result: Result, skuList: ArrayList<String>, type: String) {
        if (billingClient == null || !billingClient!!.isReady) {
            return result.error("getItemsByType", errorMessage, "")
        }

        val params = SkuDetailsParams.newBuilder()

        params.setSkusList(skuList).setType(type)

        billingClient!!.querySkuDetailsAsync(params.build(),
            SkuDetailsResponseListener { billingResult, skuDetailsList ->
                val responseCode = billingResult.responseCode
                if (responseCode != BillingClient.BillingResponseCode.OK) {
                    val errorData: Array<String> = ErrorUtils.getBillingResponseData(billingResult.responseCode)
                    result.error("getItemsByType", errorData[0], errorData[1])
                    return@SkuDetailsResponseListener
                }

                val items: ArrayList<HashMap<String, Any>> = ArrayList()
                for (sku in skuDetailsList!!) {
                    if (!skus.contains(sku)) skus.add(sku)
                    items.add(buildSkuDetailsMap(sku))
                }

                result.success(items)
            })
    }

    private fun getItemsByType(result: Result, type: String) {
        if (billingClient == null || !billingClient!!.isReady) {
            return result.error("getItemsByType", errorMessage, "")
        }

        billingClient!!.queryPurchasesAsync(if (type == "subs") BillingClient.SkuType.SUBS else BillingClient.SkuType.INAPP)
        { billingResult, purchases ->
            if (billingResult.responseCode != BillingClient.BillingResponseCode.OK) {
                val resultMap = ErrorUtils.getBillingResponseData(billingResult.responseCode)
                result.error(resultMap[0], resultMap[1], billingResult.debugMessage)
            }
            val items: ArrayList<HashMap<String, Any?>> = ArrayList()
            for (purchase in purchases) {
                items.add(buildPurchaseMap(purchase))
            }
            result.success(items)
        }
    }

    private fun getPurchaseHistoryByType(result: Result, type: String) {
        if (billingClient == null || !billingClient!!.isReady) {
            return result.error("getPurchaseHistoryByType", errorMessage, "")
        }

        billingClient!!.queryPurchaseHistoryAsync(
            if (type == "subs") BillingClient.SkuType.SUBS else BillingClient.SkuType.INAPP,
            PurchaseHistoryResponseListener { billingResult, purchaseHistoryRecordList ->
                if (billingResult.responseCode != BillingClient.BillingResponseCode.OK) {
                    val errorData: Array<String> = ErrorUtils.getBillingResponseData(billingResult.responseCode)
                    result.error("getPurchaseHistoryByType", errorData[0], errorData[1])
                    return@PurchaseHistoryResponseListener
                }

                val items: ArrayList<HashMap<String, Any>> = ArrayList()
                for (record in purchaseHistoryRecordList!!) {
                    items.add(buildPurchaseHistoryRecordMap(record))
                }

                result.success(items)
            }
        )
    }

    private fun buyItemByType(
        result: Result,
        sku: String,
        type: String,
        prorationMode: Int,
        obfuscatedAccountId: String?,
        obfuscatedProfileId: String?,
        oldSku: String?,
        purchaseToken: String?
    ) {
        if (billingClient == null || !billingClient!!.isReady) {
            return result.error("buyItemByType",errorMessage, "")
        }

        var selectedSku: SkuDetails? = null
        for (skuDetail in skus) {
            if (skuDetail.sku == sku) {
                selectedSku = skuDetail
                break
            }
        }

        if (selectedSku == null) {
            val debugMessage =
                "The sku was not found. Please fetch products first by calling getItems"
            return result.error("in_app_purchase", "buyItemByType", debugMessage)
        }

        val builder = BillingFlowParams.newBuilder()

        // Subscription upgrade/downgrade
        if (type == BillingClient.SkuType.SUBS && oldSku != null && oldSku.isNotEmpty() && purchaseToken != null && purchaseToken.isNotEmpty()) {
            val updateParams = BillingFlowParams.SubscriptionUpdateParams.newBuilder()
                .setOldSkuPurchaseToken(purchaseToken)
                .setReplaceSkusProrationMode(prorationMode)
                .build()

            builder.setSubscriptionUpdateParams(updateParams)
        }

        if (obfuscatedAccountId != null) {
            builder.setObfuscatedAccountId(obfuscatedAccountId)
        }
        if (obfuscatedProfileId != null) {
            builder.setObfuscatedProfileId(obfuscatedProfileId)
        }

        builder.setSkuDetails(selectedSku)
        val flowParams = builder.build()

        if (activity != null) {
            billingClient!!.launchBillingFlow(activity!!, flowParams)
        }

        // Releases async invokeMethod on Flutter side
        result.success(null)
    }

    private fun acknowledgePurchase(result: Result, token: String) {
        if (billingClient == null || !billingClient!!.isReady) {
            return result.error("acknowledgePurchase",errorMessage, "")
        }

        val acknowledgePurchaseParams = AcknowledgePurchaseParams.newBuilder()
            .setPurchaseToken(token)
            .build()

        billingClient!!.acknowledgePurchase(acknowledgePurchaseParams)
        { billingResult ->
            if (billingResult.responseCode != BillingClient.BillingResponseCode.OK) {
                val errorData: Array<String> = ErrorUtils.getBillingResponseData(billingResult.responseCode)
                result.error("acknowledgePurchase", errorData[0], errorData[1])
            } else {
                val resultMap = buildBillingResultMap(billingResult)
                result.success(resultMap)
            }
        }
    }

    private fun consumeProduct(result: Result, token: String) {
        if (billingClient == null || !billingClient!!.isReady) {
            return result.error("consumeProduct",errorMessage, "")
        }

        val params = ConsumeParams.newBuilder()
            .setPurchaseToken(token)
            .build()

        billingClient!!.consumeAsync(params) { billingResult, _ ->
            if (billingResult.responseCode != BillingClient.BillingResponseCode.OK) {
                val errorData: Array<String> = ErrorUtils.getBillingResponseData(billingResult.responseCode)
                result.error("consumeProduct", errorData[0], errorData[1])
            } else {
                val resultMap = buildBillingResultMap(billingResult)
                result.success(resultMap)
            }
        }
    }
}