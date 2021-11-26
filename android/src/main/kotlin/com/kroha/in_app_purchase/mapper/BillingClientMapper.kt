package com.kroha.in_app_purchase.mapper

import com.android.billingclient.api.*

interface BillingClientMapper {
    fun toJson(purchase: Purchase): HashMap<String, Any?>
    fun toJson(record: PurchaseHistoryRecord): HashMap<String, Any>
    fun toJson(skuDetails: SkuDetails): HashMap<String, Any>
    fun toJson(billingResult: BillingResult): HashMap<String, Any?>
}