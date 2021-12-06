package com.kroha.in_app_purchase

// Incoming methods
class Method {
    companion object {
        const val initConnection = "init_connection"
        const val endConnection = "end_connection"
        const val enableLogging = "enable_logging"
        const val startPurchase = "start_purchase"
        const val consumeProduct = "consume_product"
        const val getInAppPurchases = "get_in_app_purchases"
        const val acknowledgePurchase = "acknowledge_purchase"
        const val getPurchasedProductsByType = "get_purchased_products"
        const val consumeAllProducts = "consume_all_products"
        const val updateSubscription = "update_subscription"
        const val getPurchaseHistoryByType = "get_purchase_history"
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