package com.in_app_purchase.billing

import com.in_app_purchase.billing.billingClientService.BillingClientServiceFactory
import com.in_app_purchase.billing.errorHandler.ErrorHandlerImpl
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodChannel

class InAppPurchasePlugin: FlutterPlugin, ActivityAware {
  private lateinit var channel : MethodChannel
  private lateinit var handler: MethodCallHandler
  private val channelId = "in_app_purchase"

  override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(binding.binaryMessenger, channelId)
    handler = MethodCallHandler(channel, ErrorHandlerImpl(), binding.applicationContext, BillingClientServiceFactory())
    channel.setMethodCallHandler(handler)
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    handler.setActivity(binding.activity)
  }

  override fun onDetachedFromActivityForConfigChanges() {
    handler.setActivity(null)
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    onAttachedToActivity(binding)
  }

  override fun onDetachedFromActivity() {
    handler.setActivity(null)
    handler.onDetachedFromActivity()
  }
}
