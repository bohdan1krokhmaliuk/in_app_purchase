package com.kroha.in_app_purchase

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodChannel

class InAppPurchasePlugin: FlutterPlugin, ActivityAware {
  private lateinit var channel : MethodChannel
  private lateinit var billingClient: AndroidBillingClient

  companion object {
    private const val channelId = "in_app_purchase"
  }

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, channelId)
    billingClient = AndroidBillingClient()
    billingClient.setup(channel, flutterPluginBinding.applicationContext)

    channel.setMethodCallHandler(billingClient)
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    billingClient.setActivity(binding.activity)
  }

  override fun onDetachedFromActivityForConfigChanges() {
    onDetachedFromActivity()
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    onAttachedToActivity(binding)
  }

  override fun onDetachedFromActivity() {
    billingClient.setActivity(null)
  }
}
