package com.kroha.in_app_purchase.logger

interface Logger {
    fun enable()
    fun disable()
    fun log(message: String)
}