package com.kroha.in_app_purchase.errorHandler

interface IPurchaseError {
    val code: String
    val message: String
}

enum class PurchaseError: IPurchaseError {
    // Billing Service errors
    E_BILLING_UNAVAILABLE  {
        override val code: String = "E_BILLING_UNAVAILABLE"
        override val message: String = "Billing API version is not supported for the type requested."
    },
    E_DEVELOPER_ERROR {
        override val code: String = "E_DEVELOPER_ERROR"
        override val message: String = "Invalid arguments provided to the API. " +
                "This error can also indicate that the application was not correctly signed " +
                "or properly set up for In-app Billing in Google Play, or does not have the " +
                "necessary permissions in its manifest."
    },
    E_ERROR {
        override val code: String = "E_ERROR"
        override val message: String = "Fatal error during the API action."
    },
    E_FEATURE_NOT_SUPPORTED {
        override val code: String = "E_FEATURE_NOT_SUPPORTED"
        override val message: String = "Requested feature is not supported by Play Store on the " +
                "current device."
    },
    E_ITEM_ALREADY_OWNED {
        override val code: String = "E_ITEM_ALREADY_OWNED"
        override val message: String = "Failure to purchase since item is already owned."
    },
    E_ITEM_NOT_OWNED {
        override val code: String = "E_ITEM_NOT_OWNED"
        override val message: String = "Failure to consume since item is not owned."
    },
    E_ITEM_UNAVAILABLE {
        override val code: String = "E_ITEM_UNAVAILABLE"
        override val message: String = "Requested product is not available for purchase."
    },
    E_SERVICE_DISCONNECTED {
        override val code: String = "E_SERVICE_DISCONNECTED"
        override val message: String = "Play Store service is not connected now - potentially transient state."
    },
    E_SERVICE_TIMEOUT {
        override val code: String = "E_SERVICE_TIMEOUT"
        override val message: String = "The request has reached the maximum timeout before Google Play responds."
    },
    E_SERVICE_UNAVAILABLE {
        override val code: String = "E_SERVICE_UNAVAILABLE"
        override val message: String = "Network connection is down."
    },
    E_USER_CANCELED {
        override val code: String = "E_USER_CANCELED"
        override val message: String = "User pressed back or canceled a dialog."
    },

    // Own errors
    E_MISSING_ARGUMENT {
        override val code: String = "E_MISSING_ARGUMENT"
        override val message: String = "Missing argument or not correct argument type."
    },
    E_SERVICE_NOT_READY {
        override val code: String = "E_SERVICE_NOT_READY"
        override val message: String = "Please initialize the service before use."
    },
    E_ACTIVITY_UNAVAILABLE {
        override val code: String = "E_ACTIVITY_UNAVAILABLE"
        override val message: String = "Activity is not available to call the method."
    },
    E_CONSUMED_ALL {
        override val code: String = "E_CONSUMED_ALL"
        override val message: String = "No items to consume available."
    },
    E_UNKNOWN {
        override val code: String = "E_UNKNOWN"
        override val message: String = "Unknown error."
    }
}