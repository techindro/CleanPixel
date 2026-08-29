import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class PurchaseService {
  // RevenueCat Project API Key
  static const String _apiKeyAndroid = "sk_zqLkKtrQaqjbngcxsjgFuhaVZcxcs";
  static const String _apiKeyIOS = "sk_zqLkKtrQaqjbngcxsjgFuhaVZcxcs";
  static const String entitlementId = "pro_access";

  static bool _isInitialized = false;

  static Future<void> init() async {
    if (_isInitialized) return;

    try {
      await Purchases.setLogLevel(LogLevel.debug);

      PurchasesConfiguration configuration;
      if (Platform.isAndroid) {
        configuration = PurchasesConfiguration(_apiKeyAndroid);
      } else {
        configuration = PurchasesConfiguration(_apiKeyIOS);
      }

      await Purchases.configure(configuration);
      _isInitialized = true;
      debugPrint("RevenueCat v2 SDK successfully initialized.");
    } catch (e) {
      debugPrint("RevenueCat init graceful handle: $e");
    }
  }

  static Future<bool> isUserPro() async {
    try {
      if (!_isInitialized) await init();
      final customerInfo = await Purchases.getCustomerInfo();
      return customerInfo.entitlements.all[entitlementId]?.isActive ?? false;
    } catch (e) {
      debugPrint("Pro verification status: $e");
      return false;
    }
  }

  static Future<Offerings?> fetchOfferings() async {
    try {
      if (!_isInitialized) await init();
      return await Purchases.getOfferings();
    } catch (e) {
      debugPrint("Offerings fetch: $e");
      return null;
    }
  }

  static Future<bool> purchasePackage(Package package) async {
    try {
      if (!_isInitialized) await init();
      final customerInfo = await Purchases.purchasePackage(package);
      return customerInfo.entitlements.all[entitlementId]?.isActive ?? false;
    } catch (e) {
      debugPrint("Transaction status: $e");
      return false;
    }
  }

  static Future<bool> restorePurchases() async {
    try {
      if (!_isInitialized) await init();
      final customerInfo = await Purchases.restorePurchases();
      return customerInfo.entitlements.all[entitlementId]?.isActive ?? false;
    } catch (e) {
      debugPrint("Restore transaction: $e");
      return false;
    }
  }
}
