package com.in_app_purchase.billing.errorHandler

import com.android.billingclient.api.BillingClient
import com.android.billingclient.api.BillingResult
import io.flutter.plugin.common.MethodChannel.Result

interface ErrorHandler {
    companion object{
        fun getBillingResponseError(responseCode: Int): PurchaseError {
            return when (responseCode) {
                BillingClient.BillingResponseCode.FEATURE_NOT_SUPPORTED -> PurchaseError.E_FEATURE_NOT_SUPPORTED
                BillingClient.BillingResponseCode.SERVICE_DISCONNECTED -> PurchaseError.E_SERVICE_DISCONNECTED
                BillingClient.BillingResponseCode.SERVICE_UNAVAILABLE -> PurchaseError.E_SERVICE_UNAVAILABLE
                BillingClient.BillingResponseCode.BILLING_UNAVAILABLE -> PurchaseError.E_BILLING_UNAVAILABLE
                BillingClient.BillingResponseCode.ITEM_ALREADY_OWNED -> PurchaseError.E_ITEM_ALREADY_OWNED
                BillingClient.BillingResponseCode.ITEM_UNAVAILABLE -> PurchaseError.E_ITEM_UNAVAILABLE
                BillingClient.BillingResponseCode.SERVICE_TIMEOUT -> PurchaseError.E_SERVICE_TIMEOUT
                BillingClient.BillingResponseCode.ITEM_NOT_OWNED -> PurchaseError.E_ITEM_NOT_OWNED
                BillingClient.BillingResponseCode.DEVELOPER_ERROR -> PurchaseError.E_DEVELOPER_ERROR
                BillingClient.BillingResponseCode.USER_CANCELED -> PurchaseError.E_USER_CANCELED
                BillingClient.BillingResponseCode.ERROR -> PurchaseError.E_ERROR
                else -> PurchaseError.E_UNKNOWN
            }
        }
    }

    fun submitArgsErrorResult(result: Result, message: String?)
    fun submitPurchaseErrorResult(result: Result, error: PurchaseError)
    fun submitBillingErrorResult(result: Result, billingResult: BillingResult)
}