package com.in_app_purchase.billing.logger

interface Logger {
    fun enable()
    fun disable()
    fun log(message: String)
}