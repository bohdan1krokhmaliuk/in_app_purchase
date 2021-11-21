package com.kroha.in_app_purchase

import android.util.Log
import com.android.billingclient.api.BillingClient

object ErrorUtils {
    private const val E_UNKNOWN = "E_UNKNOWN"
    private const val E_USER_CANCELLED = "E_USER_CANCELLED"
    private const val E_ITEM_UNAVAILABLE = "E_ITEM_UNAVAILABLE"
    private const val E_NETWORK_ERROR = "E_NETWORK_ERROR"
    private const val E_SERVICE_ERROR = "E_SERVICE_ERROR"
    private const val E_ALREADY_OWNED = "E_ALREADY_OWNED"
    private const val E_DEVELOPER_ERROR = "E_DEVELOPER_ERROR"

    fun getBillingResponseData(responseCode: Int): Array<String> {
        var errorData: Array<String> = arrayOf("","")
        when (responseCode) {
            BillingClient.BillingResponseCode.FEATURE_NOT_SUPPORTED -> {
                errorData[0] = E_SERVICE_ERROR
                errorData[1] = "This feature is not available on your device."
            }
            BillingClient.BillingResponseCode.SERVICE_DISCONNECTED -> {
                errorData[0] = E_NETWORK_ERROR
                errorData[1] = "The service is disconnected (check your internet connection.)"
            }
            BillingClient.BillingResponseCode.OK -> {
                errorData[0] = "OK"
                errorData[1] = ""
            }
            BillingClient.BillingResponseCode.USER_CANCELED -> {
                errorData[0] = E_USER_CANCELLED
                errorData[1] = "Payment is Cancelled."
            }
            BillingClient.BillingResponseCode.SERVICE_UNAVAILABLE -> {
                errorData[0] = E_SERVICE_ERROR
                errorData[1] =
                    "The service is unreachable. This may be your internet connection, or the Play Store may be down."
            }
            BillingClient.BillingResponseCode.BILLING_UNAVAILABLE -> {
                errorData[0] = E_SERVICE_ERROR
                errorData[1] =
                    "Billing is unavailable. This may be a problem with your device, or the Play Store may be down."
            }
            BillingClient.BillingResponseCode.ITEM_UNAVAILABLE -> {
                errorData[0] = E_ITEM_UNAVAILABLE
                errorData[1] = "That item is unavailable."
            }
            BillingClient.BillingResponseCode.DEVELOPER_ERROR -> {
                errorData[0] = E_DEVELOPER_ERROR
                errorData[1] = "Google is indicating that we have some issue connecting to payment."
            }
            BillingClient.BillingResponseCode.ERROR -> {
                errorData[0] = E_UNKNOWN
                errorData[1] = "An unknown or unexpected error has occured. Please try again later."
            }
            BillingClient.BillingResponseCode.ITEM_ALREADY_OWNED -> {
                errorData[0] = E_ALREADY_OWNED
                errorData[1] = "You already own this item."
            }
            else -> {
                errorData[0] = E_UNKNOWN
                errorData[1] = "Purchase failed with code: $responseCode"
            }
        }

        Log.e("Billing response", "Error Code : $responseCode")
        return errorData
    }
}
