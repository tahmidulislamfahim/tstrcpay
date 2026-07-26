import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../../core/services/revenue_cat_service.dart';

class RevenueCatController extends GetxController {
  final RevenueCatService _service = RevenueCatService();

  late TextEditingController apiKeyController;
  late TextEditingController customUserIdController;

  final isInitialized = false.obs;
  final isLoading = false.obs;
  final isLoggedIn = false.obs;
  final appUserId = ''.obs;
  final activeEntitlements = <String>[].obs;
  final activeEntitlementsDetails = <EntitlementInfo>[].obs;
  bool get hasActiveSubscription => activeEntitlementsDetails.isNotEmpty;
  final currentOffering = Rxn<Offering>();
  final allOfferings = <Offering>[].obs;
  final logs = <String>[].obs;
  final rawCustomerInfoSummary = ''.obs;

  @override
  void onInit() {
    super.onInit();
    String? androidKey = dotenv.env['REVENUECAT_ANDROID_KEY']?.trim();
    String? iosKey = dotenv.env['REVENUECAT_IOS_KEY']?.trim();
    String? defaultKey = dotenv.env['REVENUECAT_API_KEY']?.trim();

    bool isValid(String? k) => k != null && k.isNotEmpty && !k.contains('YOUR_REVENUECAT');

    String apiKeyFromEnv = '';
    if (Platform.isAndroid && isValid(androidKey)) {
      apiKeyFromEnv = androidKey!;
    } else if (Platform.isIOS && isValid(iosKey)) {
      apiKeyFromEnv = iosKey!;
    } else if (isValid(defaultKey)) {
      apiKeyFromEnv = defaultKey!;
    }

    apiKeyController = TextEditingController(text: apiKeyFromEnv);
    customUserIdController = TextEditingController();
    
    // Initialize SDK on app launch
    initializeSdk();
  }

  @override
  void onClose() {
    apiKeyController.dispose();
    customUserIdController.dispose();
    super.onClose();
  }

  void addLog(String message, {bool isError = false}) {
    final now = DateTime.now();
    final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
    final prefix = isError ? '[ERROR]' : '[INFO]';
    logs.insert(0, '$timeStr $prefix $message');
  }

  void clearLogs() {
    logs.clear();
    addLog('Logs cleared.');
  }

  /// Initialize RevenueCat SDK
  Future<void> initializeSdk() async {
    final key = apiKeyController.text.trim();
    if (key.isEmpty) {
      EasyLoading.showError('API Key cannot be empty');
      return;
    }

    try {
      isLoading.value = true;
      EasyLoading.show(status: 'Initializing SDK...');
      addLog('Initializing RevenueCat SDK with key: ${key.substring(0, key.length > 8 ? 8 : key.length)}...');

      await _service.initSDK(key);
      isInitialized.value = true;

      // Listen for customer info updates
      _service.addCustomerInfoUpdateListener((customerInfo) {
        _updateCustomerState(customerInfo);
        addLog('Real-time CustomerInfo updated');
      });

      // Refresh customer & offering data
      await refreshData();

      EasyLoading.showSuccess('RevenueCat SDK Initialized!');
      addLog('SDK successfully initialized.');
    } catch (e) {
      isInitialized.value = false;
      addLog('Initialization Failed: $e', isError: true);
      EasyLoading.showError('SDK Init Failed: ${e.toString().split('\n').first}');
    } finally {
      isLoading.value = false;
      EasyLoading.dismiss();
    }
  }

  /// Refresh both Customer Info and Offerings
  Future<void> refreshData() async {
    if (!isInitialized.value) return;
    await fetchCustomerInfo();
    await fetchOfferings();
  }

  /// Fetch Customer Information
  Future<void> fetchCustomerInfo() async {
    try {
      final info = await _service.getCustomerInfo();
      final id = await _service.getAppUserId();
      appUserId.value = id;
      _updateCustomerState(info);
      addLog('Fetched Customer Info for user: $id');
    } catch (e) {
      addLog('Failed to fetch CustomerInfo: $e', isError: true);
    }
  }

  void _updateCustomerState(CustomerInfo info) {
    activeEntitlements.assignAll(info.entitlements.active.keys.toList());
    activeEntitlementsDetails.assignAll(info.entitlements.active.values.toList());
    final activeCount = info.entitlements.active.length;
    final allCount = info.entitlements.all.length;
    rawCustomerInfoSummary.value = 'Active Entitlements: $activeCount / Total: $allCount\n'
        'Active Keys: ${activeEntitlements.join(', ')}\n'
        'Management URL: ${info.managementURL ?? "None"}';
  }

  /// Fetch Offerings from RevenueCat
  Future<void> fetchOfferings() async {
    try {
      addLog('Fetching offerings...');
      final offerings = await _service.getOfferings();
      currentOffering.value = offerings.current;
      
      final list = <Offering>[];
      if (offerings.current != null) list.add(offerings.current!);
      offerings.all.forEach((key, offering) {
        if (!list.contains(offering)) {
          list.add(offering);
        }
      });
      allOfferings.assignAll(list);

      if (offerings.current != null) {
        addLog('Current offering: "${offerings.current!.identifier}" with ${offerings.current!.availablePackages.length} package(s)');
      } else {
        addLog('No current offering found in RevenueCat dashboard.');
      }
    } catch (e) {
      addLog('Failed to fetch offerings: $e', isError: true);
    }
  }

  /// Buy a specific Package
  Future<void> buyPackage(Package package) async {
    try {
      EasyLoading.show(status: 'Processing Purchase...');
      addLog('Initiating purchase for package: ${package.identifier} (${package.storeProduct.identifier})...');

      final customerInfo = await _service.purchasePackage(package);
      _updateCustomerState(customerInfo);
      
      addLog('Purchase completed successfully for ${package.identifier}!');
      EasyLoading.showSuccess('Purchase Successful!');
    } catch (e) {
      addLog('Purchase Failed or Cancelled: $e', isError: true);
      EasyLoading.showError('Purchase failed or cancelled');
    } finally {
      EasyLoading.dismiss();
    }
  }

  /// Restore Purchases
  Future<void> restorePurchases() async {
    try {
      EasyLoading.show(status: 'Restoring Purchases...');
      addLog('Restoring purchases...');

      final customerInfo = await _service.restorePurchases();
      _updateCustomerState(customerInfo);

      addLog('Restored purchases. Active entitlements count: ${customerInfo.entitlements.active.length}');
      EasyLoading.showSuccess('Purchases Restored!');
    } catch (e) {
      addLog('Restore Purchases Failed: $e', isError: true);
      EasyLoading.showError('Restore failed: ${e.toString().split('\n').first}');
    } finally {
      EasyLoading.dismiss();
    }
  }

  /// Switch or Log In User ID
  Future<void> logInUser() async {
    final userId = customUserIdController.text.trim();
    if (userId.isEmpty) {
      EasyLoading.showError('Please enter a Customer ID');
      return;
    }

    try {
      EasyLoading.show(status: 'Logging in user...');
      addLog('Logging in as customer: $userId...');

      final result = await _service.logIn(userId);
      appUserId.value = userId;
      _updateCustomerState(result.customerInfo);

      isLoggedIn.value = true;
      addLog('Logged in as customer "$userId". New RevenueCat user created: ${result.created}');

      // Automatically fetch offerings for this logged in customer
      await fetchOfferings();

      EasyLoading.showSuccess('Welcome, $userId!');
    } catch (e) {
      addLog('Login Failed: $e', isError: true);
      EasyLoading.showError('Login failed: ${e.toString().split('\n').first}');
    } finally {
      EasyLoading.dismiss();
    }
  }

  /// Log Out current user
  Future<void> logOutUser() async {
    try {
      EasyLoading.show(status: 'Logging out...');
      addLog('Logging out current customer...');

      final customerInfo = await _service.logOut();
      appUserId.value = '';
      isLoggedIn.value = false;
      _updateCustomerState(customerInfo);

      addLog('Logged out. Please log in with a Customer ID to view subscriptions.');
      EasyLoading.showSuccess('Logged Out');
    } catch (e) {
      addLog('Logout Failed: $e', isError: true);
      EasyLoading.showError('Logout failed');
    } finally {
      EasyLoading.dismiss();
    }
  }

  /// Present RevenueCat Paywall UI
  Future<void> presentPaywallUI() async {
    try {
      addLog('Presenting RevenueCat Paywall UI...');
      final result = await _service.presentPaywall(offering: currentOffering.value);
      addLog('Paywall UI closed with result: ${result.name}');
      await fetchCustomerInfo();
    } catch (e) {
      addLog('Present Paywall Error: $e', isError: true);
      EasyLoading.showError('Paywall Error: ${e.toString().split('\n').first}');
    }
  }
}
