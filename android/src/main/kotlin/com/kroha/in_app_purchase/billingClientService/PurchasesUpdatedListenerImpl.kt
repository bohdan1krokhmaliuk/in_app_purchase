package com.kroha.in_app_purchase.billingClientService

import com.android.billingclient.api.BillingClient.*
import com.android.billingclient.api.BillingResult
import com.android.billingclient.api.Purchase
import com.android.billingclient.api.PurchasesUpdatedListener
import com.kroha.in_app_purchase.mapper.BillingClientMapperImpl
import io.flutter.plugin.common.MethodChannel

class PurchasesUpdatedListenerImpl(private val channel: MethodChannel, private val mapper: BillingClientMapperImpl) : PurchasesUpdatedListener {
    override fun onPurchasesUpdated(result: BillingResult, purchases: MutableList<Purchase>?) {
        if (result.responseCode != BillingResponseCode.OK) {
            return channel.invokeMethod("purchase-error", mapper.toJson(result))
        }

        purchases?.forEach { purchase ->
            channel.invokeMethod("purchase-updated", mapper.toJson(purchase))
        }
    }
}