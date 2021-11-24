package com.kroha.in_app_purchase

import android.app.Activity
import android.app.Application
import android.content.Context
import android.os.Bundle
import com.android.billingclient.api.*
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.*
import io.flutter.plugin.common.MethodChannel

import com.kroha.in_app_purchase.FlutterEntitiesBuilder.buildBillingResultMap
import com.kroha.in_app_purchase.billingClientService.BillingClientService
import com.kroha.in_app_purchase.billingClientService.BillingClientServiceFactory

class MethodCallHandler(
        private val channel: MethodChannel,
        private val applicationContext: Context,
        private val billingServiceFactory: BillingClientServiceFactory
        ): MethodChannel.MethodCallHandler, Application.ActivityLifecycleCallbacks
{
    private var activity: Activity? = null
    private var service: BillingClientService? = null


    companion object {
        private const val initConnection = "initConnection"
        private const val endConnection = "endConnection"
        private const val consumeAllItems = "consumeAllItems"
        private const val getItemsByType = "getItemsByType"
        private const val getAvailableItemsByType = "getAvailableItemsByType"
        private const val getPurchaseHistoryByType = "getPurchaseHistoryByType"
        private const val buyItemByType = "buyItemByType"
        private const val updateSubscription = "updateSubscription"
        private const val acknowledgePurchase = "acknowledgePurchase"
        private const val consumeProduct = "consumeProduct"
    }

    fun setActivity(activity: Activity?) {
        this.activity = activity
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        val isServiceInitialized = service?.isReady ?: false

        if (call.method != initConnection && !isServiceInitialized) {
            val message = "IAP not prepared. Check if Google Play service is available."
            return result.error("serviceNotInitialized", message, "")
        }

        when (call.method) {
            initConnection -> {
                val enablePendingPurchases: Boolean = call.argument("enablePendingPurchases")
                    ?: return result.error(call.method, "E_WRONG_PARAMS", "type and skuList must be NonNullable for method")
                service = billingServiceFactory.createBillingClient(applicationContext, channel, enablePendingPurchases)
                service?.initConnection(result)
            }
            endConnection -> service?.endConnection(result)
            consumeAllItems -> service?.consumeAllItems(result)
            getItemsByType -> {
                val type: String? = call.argument("type")
                val skuList: ArrayList<String>? = call.argument("skus")

                if(type == null || skuList == null) {
                    return result.error(call.method, "E_WRONG_PARAMS", "type and skuList must be NonNullable for method")
                }

                service?.getInAppPurchasesByType(result, skuList, type)
            }
            getAvailableItemsByType -> {
                val type: String = call.argument("type")
                    ?: return result.error(call.method, "E_WRONG_PARAMS", "type must be NonNullable for method")

                service?.getPurchasedProductsByType(result,type)
            }
            getPurchaseHistoryByType -> {
                val type: String = call.argument("type")
                    ?: return result.error(call.method, "E_WRONG_PARAMS", "type must be NonNullable for method")

                service?.getPurchaseHistoryByType(result,type)
            }
            buyItemByType -> {
                val sku: String? = call.argument("sku")
                val obfuscatedAccountId: String? = call.argument("obfuscatedAccountId")
                val obfuscatedProfileId: String? = call.argument("obfuscatedProfileId")

                if (sku == null) {
                    return result.error(call.method, "E_WRONG_PARAMS", "type and sku must be NonNullable for method")
                } else if (activity == null){
                    return result.error(call.method, "E_ACTIVITY_UNAVAILABLE", "Purhcase can not be requested as activity not available")
                }

                service?.buyItem(result, activity!!, sku, obfuscatedAccountId, obfuscatedProfileId)
            }
            updateSubscription -> {
                val newSubscriptionSku: String? = call.argument("sku")
                val prorationMode: Int? = call.argument("prorationMode")
                val obfuscatedAccountId: String? = call.argument("obfuscatedAccountId")
                val obfuscatedProfileId: String? = call.argument("obfuscatedProfileId")
                val oldSkuPurchaseToken: String? = call.argument("purchaseToken")

                if (newSubscriptionSku == null) {
                    return result.error(call.method, "E_WRONG_PARAMS", "type and sku must be NonNullable for method")
                } else if (oldSkuPurchaseToken == null || oldSkuPurchaseToken.isEmpty()){
                    val debugMessage = "'oldSkuPurchaseToken' must be specified"
                    return result.error(call.method, "updateSubscription", debugMessage)
                } else if (activity == null){
                    return result.error(call.method, "E_ACTIVITY_UNAVAILABLE", "Purhcase can not be requested as activity not available")
                }


                service?.updateSubscription(
                    result,
                    activity!!,
                    newSubscriptionSku,
                    oldSkuPurchaseToken,
                    prorationMode,
                    obfuscatedAccountId,
                    obfuscatedProfileId
                )
            }
            acknowledgePurchase -> {
                val token: String = call.argument("token")
                    ?: return result.error(call.method, "E_WRONG_PARAMS", "token must be NonNullable for method")

                service?.acknowledgePurchase(result, token)
            }
            consumeProduct -> {
                val token: String = call.argument("token")
                    ?: return result.error(call.method, "E_WRONG_PARAMS", "token must be NonNullable for method")

                service?.consumeProduct(result, token)
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
        if (this.activity == activity && applicationContext != null) {
            (applicationContext as Application).unregisterActivityLifecycleCallbacks(this)
            onDetachedFromActivity()
        }
    }

    fun onDetachedFromActivity() {
        service?.endConnection()
        service = null
    }
}