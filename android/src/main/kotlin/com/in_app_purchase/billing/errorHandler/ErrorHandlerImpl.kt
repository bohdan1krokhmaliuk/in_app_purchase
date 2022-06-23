package com.in_app_purchase.billing.errorHandler

import com.android.billingclient.api.BillingResult
import io.flutter.plugin.common.MethodChannel.Result

class ErrorHandlerImpl : ErrorHandler {
    override fun submitArgsErrorResult(result: Result, message: String?) {
        val error = PurchaseError.E_MISSING_ARGUMENT
        return result.error(error.code, message ?: error.message, null)
    }

    override fun submitBillingErrorResult(result: Result, billingResult: BillingResult) {
        val error = ErrorHandler.getBillingResponseError(billingResult.responseCode)
        return result.error(error.code, error.message, billingResult.debugMessage)
    }

    override fun submitPurchaseErrorResult(result: Result, error: PurchaseError) {
        return result.error(error.code, error.message, null)
    }
}