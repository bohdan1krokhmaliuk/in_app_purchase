package com.in_app_purchase.billing.mapper

import com.android.billingclient.api.*

interface BillingClientMapper {
    fun toJson(purchase: Purchase): HashMap<String, Any?>
    fun toJson(record: PurchaseHistoryRecord): HashMap<String, Any>
    fun toJson(skuDetails: SkuDetails): HashMap<String, Any>
    fun toJson(sku: String?, skus: ArrayList<String>?, billingResult: BillingResult): HashMap<String, Any?>
}