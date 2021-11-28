package com.kroha.in_app_purchase

// Incoming methods
class Method {
    companion object {
        const val initConnection = "init_connection"
        const val endConnection = "end_connection"
        const val enableLogging = "enable_logging"
        const val getInAppPurchases = "get_in_app_purchases"
        const val getPurchasedProductsByType = "get_purchased_products"

        const val consumeAllItems = "consumeAllItems"
        const val getPurchaseHistoryByType = "getPurchaseHistoryByType"

        const val buyItemByType = "buyItemByType"
        const val updateSubscription = "updateSubscription"
        const val acknowledgePurchase = "acknowledgePurchase"
        const val consumeProduct = "consumeProduct"

    }
}

// Incoming methods
class OutMethod {
    companion object {
        const val purchaseError = "purchase-error"
        const val purchaseUpdate = "purchase-updated"
        const val connectionUpdate = "connection-updated"
    }
}