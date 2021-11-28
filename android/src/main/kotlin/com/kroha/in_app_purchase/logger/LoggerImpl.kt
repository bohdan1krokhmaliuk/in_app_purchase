package com.kroha.in_app_purchase.logger

import android.util.Log

class LoggerImpl: Logger {
    var isEnabled = false

    override fun enable() {
        isEnabled = true
    }

    override fun disable() {
        isEnabled = false
    }

    override fun log(message: String) {
        if (isEnabled) {
            Log.d(null, message)
        }
    }

}