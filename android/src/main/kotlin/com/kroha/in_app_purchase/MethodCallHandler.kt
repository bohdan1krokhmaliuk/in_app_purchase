package com.kroha.in_app_purchase

import android.app.Activity
import android.app.Application
import android.content.Context
import android.os.Bundle
import com.android.billingclient.api.BillingClient.*
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.*
import io.flutter.plugin.common.MethodChannel

import com.kroha.in_app_purchase.billingClientService.BillingClientService
import com.kroha.in_app_purchase.billingClientService.BillingClientServiceFactory
import com.kroha.in_app_purchase.errorHandler.ErrorHandler
import com.kroha.in_app_purchase.errorHandler.PurchaseError

class MethodCallHandler(
    private val channel: MethodChannel,
    private val errorHandler: ErrorHandler,
    private val applicationContext: Context,
    private val billingServiceFactory: BillingClientServiceFactory
        ): MethodChannel.MethodCallHandler, Application.ActivityLifecycleCallbacks
{
    private var activity: Activity? = null
    private var service: BillingClientService? = null

    companion object {
        private const val skuInvalidMessage = "Sku must be non nullable"
        private const val skusInvalidMessage = "Skus must be non nullable"
        private const val tokenInvalidMessage = "Token must be non nullable"
        private const val oldTokenInvalidMessage = "'oldSkuPurchaseToken' must be specified"
        private const val typeInvalidMessage = "Type var must be one of next values: [subs, inapp]"
        private const val pendingPurchasesMessage = "Please specify if service should enable pending purchases"
    }

    fun setActivity(activity: Activity?) {
        this.activity = activity
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        val isServiceInitialized = service?.isReady ?: false

        if (call.method != Method.initConnection && !isServiceInitialized) {
            return errorHandler.submitPurchaseErrorResult(result, PurchaseError.E_SERVICE_NOT_READY)
        }

        when (call.method) {
            Method.initConnection -> {
                val enablePendingPurchases: Boolean = call.argument("enablePendingPurchases")
                    ?: return errorHandler.submitArgsErrorResult(result, pendingPurchasesMessage)

                service = billingServiceFactory.createBillingClient(applicationContext, channel, errorHandler, enablePendingPurchases)
                service?.initConnection(result)
            }
            Method.endConnection -> service?.endConnection(result)
            Method.consumeAllItems -> service?.consumeAllItems(result)
            Method.getItemsByType -> {
                val type: String? = call.argument("type")
                if( type == null || (type != SkuType.INAPP && type != SkuType.SUBS) ){
                    return errorHandler.submitArgsErrorResult(result, typeInvalidMessage)
                }
                val skuList: ArrayList<String> = call.argument("skus")
                    ?: return errorHandler.submitArgsErrorResult(result, skusInvalidMessage)


                service?.getInAppPurchasesByType(result, skuList, type)
            }
            Method.getAvailableItemsByType -> {
                val type: String? = call.argument("type")
                if( type == null || (type != SkuType.INAPP && type != SkuType.SUBS) ){
                    return errorHandler.submitArgsErrorResult(result, typeInvalidMessage)
                }

                service?.getPurchasedProductsByType(result, type)
            }
            Method.getPurchaseHistoryByType -> {
                val type: String? = call.argument("type")
                if( type == null || (type != SkuType.INAPP && type != SkuType.SUBS) ){
                    return errorHandler.submitArgsErrorResult(result, typeInvalidMessage)
                }

                service?.getPurchaseHistoryByType(result, type)
            }
            Method.buyItemByType -> {
                val sku: String? = call.argument("sku")
                val obfuscatedAccountId: String? = call.argument("obfuscatedAccountId")
                val obfuscatedProfileId: String? = call.argument("obfuscatedProfileId")

                if (sku == null) {
                    return errorHandler.submitArgsErrorResult(result, skuInvalidMessage)
                } else if (activity == null){
                    return errorHandler.submitPurchaseErrorResult(result, PurchaseError.E_ACTIVITY_UNAVAILABLE)
                }

                service?.buyItem(result, activity!!, sku, obfuscatedAccountId, obfuscatedProfileId)
            }
            Method.updateSubscription -> {
                val newSubscriptionSku: String? = call.argument("sku")
                val prorationMode: Int? = call.argument("prorationMode")
                val obfuscatedAccountId: String? = call.argument("obfuscatedAccountId")
                val obfuscatedProfileId: String? = call.argument("obfuscatedProfileId")
                val oldSkuPurchaseToken: String? = call.argument("purchaseToken")

                if (newSubscriptionSku == null) {
                    return errorHandler.submitArgsErrorResult(result, skuInvalidMessage)
                } else if (oldSkuPurchaseToken == null || oldSkuPurchaseToken.isEmpty()){
                    return errorHandler.submitArgsErrorResult(result, oldTokenInvalidMessage)
                } else if (activity == null){
                    return errorHandler.submitPurchaseErrorResult(result, PurchaseError.E_ACTIVITY_UNAVAILABLE)
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
            Method.acknowledgePurchase -> {
                val token: String = call.argument("token")
                    ?: return errorHandler.submitArgsErrorResult(result, tokenInvalidMessage)

                service?.acknowledge(result, token)
            }
            Method.consumeProduct -> {
                val token: String = call.argument("token")
                    ?: return errorHandler.submitArgsErrorResult(result, tokenInvalidMessage)

                service?.consumeProduct(result, token)
            }
            Method.setLogging -> {
                val enable: Boolean = call.argument("enable")
                    ?: return errorHandler.submitArgsErrorResult(result, tokenInvalidMessage)

                service?.setLogging(enable, result)
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
            (applicationContext as Application).unregisterActivityLifecycleCallbacks(this)
            onDetachedFromActivity()
        }
    }

    fun onDetachedFromActivity() {
        service?.endConnection()
        service = null
    }
}