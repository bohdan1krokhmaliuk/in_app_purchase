package com.kroha.in_app_purchase

import com.android.billingclient.api.BillingClient.*
import com.android.billingclient.api.BillingResult
import com.android.billingclient.api.Purchase
import com.android.billingclient.api.PurchasesUpdatedListener
import io.flutter.plugin.common.MethodChannel

class PurchasesUpdatedListenerImpl(private val channel: MethodChannel) : PurchasesUpdatedListener {
    override fun onPurchasesUpdated(result: BillingResult, purchases: MutableList<Purchase>?) {
        if (result.responseCode != BillingResponseCode.USER_CANCELED){
            // TODO: add as separate result if needed
        }
        else if (result.responseCode != BillingResponseCode.OK) {
            val resultMap = FlutterEntitiesBuilder.buildBillingResultMap(result)
            return channel.invokeMethod("purchase-error", resultMap)
        }

        purchases?.forEach { purchase ->
            channel.invokeMethod("purchase-updated", FlutterEntitiesBuilder.buildPurchaseMap(purchase)
        )}
    }
}