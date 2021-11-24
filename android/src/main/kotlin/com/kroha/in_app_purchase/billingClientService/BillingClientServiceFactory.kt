package com.kroha.in_app_purchase.billingClientService

import android.content.Context
import com.android.billingclient.api.BillingClient
import com.kroha.in_app_purchase.PurchasesUpdatedListenerImpl
import io.flutter.plugin.common.MethodChannel

class BillingClientServiceFactory {
    fun createBillingClient(
        context: Context,
        channel: MethodChannel,
        enablePendingPurchases: Boolean
    ): BillingClientService {
        val builder = BillingClient.newBuilder(context)
        if (enablePendingPurchases) builder.enablePendingPurchases()
        val billingClient = builder.setListener(PurchasesUpdatedListenerImpl(channel)).build()

        return BillingClientServiceImpl(billingClient, channel)
    }
}