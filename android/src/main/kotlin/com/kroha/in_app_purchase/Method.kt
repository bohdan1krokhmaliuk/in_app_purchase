package com.kroha.in_app_purchase

// Incoming methods
class Method {
    companion object {
        const val initConnection = "initConnection"
        const val endConnection = "endConnection"
        const val consumeAllItems = "consumeAllItems"
        const val getItemsByType = "getItemsByType"
        const val getAvailableItemsByType = "getAvailableItemsByType"
        const val getPurchaseHistoryByType = "getPurchaseHistoryByType"
        const val buyItemByType = "buyItemByType"
        const val updateSubscription = "updateSubscription"
        const val acknowledgePurchase = "acknowledgePurchase"
        const val consumeProduct = "consumeProduct"
        const val setLogging = "setLogging"
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