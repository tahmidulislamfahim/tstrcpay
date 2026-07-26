import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

class RevenueCatService {
  static final RevenueCatService _instance = RevenueCatService._internal();
  factory RevenueCatService() => _instance;
  RevenueCatService._internal();

  bool _isConfigured = false;
  bool get isConfigured => _isConfigured;

  /// Initialize RevenueCat SDK with provided API Key
  Future<void> initSDK(String apiKey, {String? appUserID}) async {
    if (kDebugMode) {
      await Purchases.setLogLevel(LogLevel.debug);
    }

    final configuration = PurchasesConfiguration(apiKey);
    if (appUserID != null && appUserID.trim().isNotEmpty) {
      configuration.appUserID = appUserID.trim();
    }

    await Purchases.configure(configuration);
    _isConfigured = true;
  }

  /// Get Current Customer Info
  Future<CustomerInfo> getCustomerInfo() async {
    _checkConfigured();
    return await Purchases.getCustomerInfo();
  }

  /// Get Current App User ID
  Future<String> getAppUserId() async {
    _checkConfigured();
    return await Purchases.appUserID;
  }

  /// Fetch Available Offerings from RevenueCat Dashboard
  Future<Offerings> getOfferings() async {
    _checkConfigured();
    return await Purchases.getOfferings();
  }

  /// Purchase a Package
  Future<CustomerInfo> purchasePackage(Package package) async {
    _checkConfigured();
    final result = await Purchases.purchase(PurchaseParams.package(package));
    return result.customerInfo;
  }

  /// Restore Previous Purchases
  Future<CustomerInfo> restorePurchases() async {
    _checkConfigured();
    return await Purchases.restorePurchases();
  }

  /// Log In as custom User ID
  Future<LogInResult> logIn(String appUserID) async {
    _checkConfigured();
    return await Purchases.logIn(appUserID);
  }

  /// Log Out current user
  Future<CustomerInfo> logOut() async {
    _checkConfigured();
    return await Purchases.logOut();
  }

  /// Listen for Customer Info real-time updates
  void addCustomerInfoUpdateListener(Function(CustomerInfo) listener) {
    Purchases.addCustomerInfoUpdateListener(listener);
  }

  /// Present RevenueCat Paywall UI
  Future<PaywallResult> presentPaywall({Offering? offering}) async {
    _checkConfigured();
    if (offering != null) {
      return await RevenueCatUI.presentPaywall(offering: offering);
    }
    return await RevenueCatUI.presentPaywall();
  }

  /// Present RevenueCat Paywall UI if user lacks specific Entitlement
  Future<PaywallResult> presentPaywallIfNeeded(String requiredEntitlementIdentifier) async {
    _checkConfigured();
    return await RevenueCatUI.presentPaywallIfNeeded(requiredEntitlementIdentifier);
  }

  void _checkConfigured() {
    if (!_isConfigured) {
      throw Exception('RevenueCat SDK is not initialized yet. Call initSDK first.');
    }
  }
}
