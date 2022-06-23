package com.in_app_purchase.billing.billingClientService

import android.content.Context
import com.android.billingclient.api.BillingClient
import com.in_app_purchase.billing.errorHandler.ErrorHandler
import com.in_app_purchase.billing.logger.LoggerImpl
import com.in_app_purchase.billing.mapper.BillingClientMapperImpl
import io.flutter.plugin.common.MethodChannel

class BillingClientServiceFactory {
    fun createBillingClient(
        context: Context,
        channel: MethodChannel,
        errorHandler: ErrorHandler,
        enablePendingPurchases: Boolean
    ): BillingClientService {
        val logger = LoggerImpl()
        val mapper = BillingClientMapperImpl()
        val listener = PurchasesUpdatedListenerImpl(logger, channel, mapper)

        val builder = BillingClient.newBuilder(context)
        if (enablePendingPurchases) builder.enablePendingPurchases()
        val billingClient = builder.setListener(listener).build()

        return BillingClientServiceImpl(logger, billingClient, channel, errorHandler, mapper)
    }
}