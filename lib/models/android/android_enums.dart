extension AndroidInAppPurchaseTypeExt on AndroidInAppPurchaseType {
  String get rawValue {
    switch (this) {
      case AndroidInAppPurchaseType.subscription:
        return 'subs';
      case AndroidInAppPurchaseType.oneTime:
        return 'inapp';
    }
  }
}

enum AndroidInAppPurchaseType { subscription, oneTime }

extension AndroidProrationModeExt on AndroidProrationMode {
  int get rawValue {
    switch (this) {
      case AndroidProrationMode.deffered:
        return 4;
      case AndroidProrationMode.immediateAndChargeFullPrice:
        return 5;
      case AndroidProrationMode.immediateAndChargeProratedPrice:
        return 2;
      case AndroidProrationMode.immediateWithTimeProration:
        return 1;
      case AndroidProrationMode.immediateWithoutProration:
        return 3;
      case AndroidProrationMode.unknownSubscriptionUpgradeDowngradePolicy:
        return 0;
    }
  }
}

/// A list of valid values for ProrationMode parameter
/// https://developer.android.com/reference/com/android/billingclient/api/BillingFlowParams.ProrationMode
enum AndroidProrationMode {
  /// Replacement takes effect when the old plan expires, and the new price will be charged at the same time.
  /// https://developer.android.com/reference/com/android/billingclient/api/BillingFlowParams.ProrationMode#DEFERRED
  deffered,

  /// Replacement takes effect immediately, and the user is charged full price of new plan and is given a full billing cycle of subscription, plus remaining prorated time from the old plan
  /// https://developer.android.com/reference/com/android/billingclient/api/BillingFlowParams.ProrationMode#DEFERRED
  immediateAndChargeFullPrice,

  /// Replacement takes effect immediately, and the billing cycle remains the same. The price for the remaining period will be charged. This option is only available for subscription upgrade.
  /// https://developer.android.com/reference/com/android/billingclient/api/BillingFlowParams.ProrationMode#immediate_and_charge_prorated_price
  immediateAndChargeProratedPrice,

  /// Replacement takes effect immediately, and the new price will be charged on next recurrence time. The billing cycle stays the same.
  /// https://developer.android.com/reference/com/android/billingclient/api/BillingFlowParams.ProrationMode#immediate_without_proration
  immediateWithoutProration,

  /// Replacement takes effect immediately, and the remaining time will be prorated and credited to the user. This is the current default behavior.
  /// https://developer.android.com/reference/com/android/billingclient/api/BillingFlowParams.ProrationMode#immediate_with_time_proration
  immediateWithTimeProration,

  /// https://developer.android.com/reference/com/android/billingclient/api/BillingFlowParams.ProrationMode#unknown_subscription_upgrade_downgrade_policy
  unknownSubscriptionUpgradeDowngradePolicy,
}
