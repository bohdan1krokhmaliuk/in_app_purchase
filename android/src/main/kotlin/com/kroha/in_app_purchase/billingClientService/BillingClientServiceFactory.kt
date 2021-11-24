package com.kroha.in_app_purchase.billingClientService

import android.content.Context
import com.android.billingclient.api.BillingClient
import com.kroha.in_app_purchase.mapper.BillingClientMapperImpl
import io.flutter.plugin.common.MethodChannel

class BillingClientServiceFactory {
    fun createBillingClient(
        context: Context,
        channel: MethodChannel,
        enablePendingPurchases: Boolean
    ): BillingClientService {
        val mapper = BillingClientMapperImpl()
        val listener = PurchasesUpdatedListenerImpl(channel, mapper)

        val builder = BillingClient.newBuilder(context)
        if (enablePendingPurchases) builder.enablePendingPurchases()
        val billingClient = builder.setListener(listener).build()

        return BillingClientServiceImpl(billingClient, channel, mapper)
    }
}