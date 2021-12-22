package com.kroha.in_app_purchase.billingClientService

import com.android.billingclient.api.BillingClient.*
import com.android.billingclient.api.BillingResult
import com.android.billingclient.api.Purchase
import com.android.billingclient.api.PurchasesUpdatedListener
import com.kroha.in_app_purchase.OutMethod
import com.kroha.in_app_purchase.logger.Logger
import com.kroha.in_app_purchase.mapper.BillingClientMapperImpl
import io.flutter.plugin.common.MethodChannel

class PurchasesUpdatedListenerImpl(
    private val logger: Logger,
    private val channel: MethodChannel,
    private val mapper: BillingClientMapperImpl
    ) : PurchasesUpdatedListener {
    override fun onPurchasesUpdated(result: BillingResult, purchases: MutableList<Purchase>?) {
        if (result.responseCode != BillingResponseCode.OK) {
            if (purchases.isNullOrEmpty()) {
                logger.log("[Purchase] purchase failed, purchases not available")
                val error = mapper.toJson(null,null, result)
                return channel.invokeMethod(OutMethod.purchaseError, error)
            }

            return purchases?.forEach { purchase ->
                if (purchase.purchaseState == Purchase.PurchaseState.PURCHASED) {
                    processSuccessfulPurchase(purchase)
                } else {
                    logger.log("[Purchase] skus: ${purchase.skus}; purchase failed")
                    val errorMap = mapper.toJson(purchase.skus.first(), purchase.skus, result)
                    channel.invokeMethod(OutMethod.purchaseError, errorMap)
                }
            }
        }

        purchases?.forEach { purchase ->
            processSuccessfulPurchase(purchase)
        }
    }

    fun processSuccessfulPurchase(purchase: Purchase){
        logger.log("[Purchase] skus: ${purchase.skus}; purchase successful")
        channel.invokeMethod(OutMethod.purchaseUpdate, mapper.toJson(purchase))
    }
}