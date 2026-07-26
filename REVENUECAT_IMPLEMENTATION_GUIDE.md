# Complete RevenueCat Implementation Guide (Flutter + GetX)

This guide provides a step-by-step walkthrough for implementing and testing **RevenueCat In-App Purchases & Subscriptions** in a Flutter mobile application, following the feature-driven architecture specified in `GEMINI.md`.

---

## ❓ 1. Why No Credit Card Entry UI (RevenueCat vs. Stripe)?

Developers coming from web payment integrations (like Stripe or PayPal) often look for text fields to enter credit card numbers, CVVs, and expiry dates. In mobile apps, **you do NOT build credit card entry forms**.

### Key Differences:

| Feature | Stripe (Web Payments) | RevenueCat / Mobile In-App Purchases |
| :--- | :--- | :--- |
| **Payment Gateway** | Custom web form connected to Stripe API | Native **Google Play Billing** (Android) & **Apple StoreKit** (iOS) |
| **Card Data Entry** | User manually types credit card numbers | **No card fields in your app**. User pays via card/Apple Pay/Google Pay attached to their Google/Apple account |
| **Security & PCI Compliance** | Your app must manage PCI compliance | **100% handled by Apple & Google**. App never touches card details |
| **Store Guideline Requirement** | Prohibited for digital features on iOS/Android | **Mandatory** by Apple & Google guidelines for digital goods/subscriptions |
| **Customer Tracking** | Stripe Customer ID | RevenueCat `App User ID` linked to store receipts |

### How RevenueCat Identifies Customers:
1. When your user logs into your app, you pass your backend customer ID to RevenueCat via `Purchases.logIn(customerId)`.
2. When the user taps **Buy Package**, Google Play or Apple App Store pops up their **official native payment drawer**.
3. Upon payment completion, Google/Apple returns an encrypted store receipt token to RevenueCat.
4. RevenueCat validates the receipt and binds the active **Entitlement** (e.g. `pro` / `premium`) directly to that Customer ID.

---

## 🏗️ 2. Architecture & Project Structure

The codebase is organized into modular layers:

```text
lib/
├── app.dart                                # GetMaterialApp configuration & EasyLoading builder
├── main.dart                               # Entry point, dotenv loader, EasyLoading styling
├── core/
│   ├── binding/
│   │   └── controller_binder.dart          # Dependency injection (GetX)
│   ├── common/
│   │   └── style/
│   │       └── global_text_style.dart      # Inter typography tokens
│   ├── constants/
│   │   └── app_color.dart                  # Dark theme color palette
│   └── services/
│       └── revenue_cat_service.dart        # RevenueCat Purchases SDK wrapper service
├── features/
│   └── revenue_cat_test/
│       ├── controller/
│       │   └── revenue_cat_controller.dart # Reactive GetX business logic
│       ├── screen/
│       │   └── revenue_cat_test_screen.dart# Smart dashboard & paywall view
│       └── widgets/
│           ├── active_subscription_card.dart# Active subscription card (shown when user is subscribed)
│           ├── log_viewer.dart             # Real-time console trace log viewer
│           ├── package_card.dart           # Subscription package card (Monthly, Yearly, Lifetime)
│           ├── status_card.dart            # SDK connection status & API key configuration
│           └── user_identity_card.dart     # Customer Login & Customer Account header
└── routes/
    └── app_routes.dart                     # Named routing table
```

---

## 🚀 3. Step-by-Step Implementation Guide

### Step 1: Add Dependencies in `pubspec.yaml`

Add the RevenueCat Flutter SDKs, GetX state management, dotenv, and EasyLoading overlay:

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  purchases_flutter: ^10.4.3
  purchases_ui_flutter: ^10.4.3
  get: ^4.7.3
  flutter_dotenv: ^6.0.1
  flutter_easyloading: ^3.0.5

flutter:
  uses-material-design: true
  assets:
    - .env
```

Run command:
```bash
flutter pub get
```

---

### Step 2: Configure Android (`FlutterFragmentActivity`)

RevenueCat's native UI plugin (`purchases_ui_flutter`) requires native Android Fragments. Change `MainActivity` from `FlutterActivity` to `FlutterFragmentActivity`:

**File**: `android/app/src/main/kotlin/com/example/tstrcpay/MainActivity.kt`

```kotlin
package com.example.tstrcpay

import io.flutter.embedding.android.FlutterFragmentActivity

class MainActivity : FlutterFragmentActivity()
```

---

### Step 3: Set Up `.env` File & `.gitignore`

1. Create `.env` file at the root of your project:

```env
REVENUECAT_API_KEY=test_dZLsiRHsSYebDLltmUUKuQTwFSZ
```

2. Add `.env` to `.gitignore` so your API key is never committed to source control:

```gitignore
/android/app/release
.agents
.env
```

---

### Step 4: Build Core RevenueCat Service

Create a singleton service to encapsulate all direct RevenueCat SDK interactions:

**File**: `lib/core/services/revenue_cat_service.dart`

```dart
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

class RevenueCatService {
  static final RevenueCatService _instance = RevenueCatService._internal();
  factory RevenueCatService() => _instance;
  RevenueCatService._internal();

  bool _isConfigured = false;
  bool get isConfigured => _isConfigured;

  /// Initialize SDK with API key
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

  /// Fetch Customer Information
  Future<CustomerInfo> getCustomerInfo() async {
    return await Purchases.getCustomerInfo();
  }

  /// Fetch Offerings from RevenueCat Dashboard
  Future<Offerings> getOfferings() async {
    return await Purchases.getOfferings();
  }

  /// Purchase a Package
  Future<CustomerInfo> purchasePackage(Package package) async {
    final result = await Purchases.purchase(PurchaseParams.package(package));
    return result.customerInfo;
  }

  /// Restore Purchases
  Future<CustomerInfo> restorePurchases() async {
    return await Purchases.restorePurchases();
  }

  /// Log In as custom Customer ID
  Future<LogInResult> logIn(String appUserID) async {
    return await Purchases.logIn(appUserID);
  }

  /// Log Out current customer
  Future<CustomerInfo> logOut() async {
    return await Purchases.logOut();
  }

  /// Listen for real-time CustomerInfo updates
  void addCustomerInfoUpdateListener(Function(CustomerInfo) listener) {
    Purchases.addCustomerInfoUpdateListener(listener);
  }

  /// Present RevenueCat Paywall UI
  Future<PaywallResult> presentPaywall({Offering? offering}) async {
    if (offering != null) {
      return await RevenueCatUI.presentPaywall(offering: offering);
    }
    return await RevenueCatUI.presentPaywall();
  }
}
```

---

### Step 5: Implement GetX State Controller

Manage application reactive states (`isLoggedIn`, `hasActiveSubscription`, `activeEntitlements`, `offerings`, `logs`):

**File**: `lib/features/revenue_cat_test/controller/revenue_cat_controller.dart`

```dart
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
  final logs = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    final apiKeyFromEnv = dotenv.env['REVENUECAT_API_KEY']?.trim() ?? '';
    apiKeyController = TextEditingController(text: apiKeyFromEnv);
    customUserIdController = TextEditingController();
    initializeSdk();
  }

  Future<void> initializeSdk() async {
    final key = apiKeyController.text.trim();
    if (key.isEmpty) return;

    try {
      isLoading.value = true;
      await _service.initSDK(key);
      isInitialized.value = true;

      _service.addCustomerInfoUpdateListener((customerInfo) {
        _updateCustomerState(customerInfo);
      });
    } catch (e) {
      isInitialized.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  void _updateCustomerState(CustomerInfo info) {
    activeEntitlements.assignAll(info.entitlements.active.keys.toList());
    activeEntitlementsDetails.assignAll(info.entitlements.active.values.toList());
  }

  Future<void> logInUser() async {
    final userId = customUserIdController.text.trim();
    if (userId.isEmpty) return;

    try {
      EasyLoading.show(status: 'Logging in...');
      final result = await _service.logIn(userId);
      appUserId.value = userId;
      _updateCustomerState(result.customerInfo);
      isLoggedIn.value = true;
      await fetchOfferings();
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<void> logOutUser() async {
    final customerInfo = await _service.logOut();
    appUserId.value = '';
    isLoggedIn.value = false;
    _updateCustomerState(customerInfo);
  }

  Future<void> fetchOfferings() async {
    final offerings = await _service.getOfferings();
    currentOffering.value = offerings.current;
  }

  Future<void> buyPackage(Package package) async {
    try {
      EasyLoading.show(status: 'Processing Purchase...');
      final customerInfo = await _service.purchasePackage(package);
      _updateCustomerState(customerInfo);
      EasyLoading.showSuccess('Purchase Successful!');
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<void> restorePurchases() async {
    try {
      EasyLoading.show(status: 'Restoring Purchases...');
      final customerInfo = await _service.restorePurchases();
      _updateCustomerState(customerInfo);
      EasyLoading.showSuccess('Purchases Restored!');
    } finally {
      EasyLoading.dismiss();
    }
  }
}
```

---

### Step 6: Smart UI Flow (Login -> Subscription Visibility)

The UI dynamically adapts based on customer state:

1. **Step 1 (Customer Login)**: Prompts user to enter Customer ID (`UserIdentityCard`).
2. **Step 2 (Active Subscription View)**: If customer has an active purchase, display `ActiveSubscriptionCard` (`PRO ACTIVE` status).
3. **Step 3 (Paywall / Offerings Catalog View)**: If customer has no active purchase, display available subscription packages (`PackageCard`) with **Buy Package** buttons.

---

### Step 7: Main Entry Point (`main.dart`)

Load environment variables and initialize dependencies before running app:

**File**: `lib/main.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'app.dart';
import 'core/constants/app_color.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  _configEasyLoading();
  runApp(const MyApp());
}

void _configEasyLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2500)
    ..loadingStyle = EasyLoadingStyle.custom
    ..backgroundColor = AppColor.cardDark
    ..indicatorColor = AppColor.accentPurpleLight
    ..textColor = AppColor.white;
}
```

---

## 🧪 4. Testing Purchases

1. **RevenueCat Test API Key (`test_...`)**:
   - Pops up RevenueCat's built-in **Test Store Purchase Dialog**.
   - Select **"Test valid purchase"** to simulate successful purchase and grant entitlement.
   - Select **"Test failed purchase"** to simulate payment failure.

2. **Google Play Store Sandbox (Android)**:
   - Add tester email under **Google Play Console -> License Testing**.
   - Run build on Android device/emulator. Google Play pops up **"Test Card (Always approves)"**.

## 🛠️ 5. Next Steps: Google Play & App Store Console Setup

### 🤖 1. Google Play Console Setup

#### Upload an Initial Build (Crucial Step):
- Build your app (AAB/APK) with billing permission (`com.android.vending.BILLING`).
- Upload it to the Internal Testing track in Play Console. *(Google will not enable billing APIs for your app until an initial build exists in a test track)*.

#### Create In-App Products / Subscriptions:
- Go to **Monetize → Products** (In-app products or Subscriptions) and create your products.
- Copy the Product IDs—you'll need to add these matching IDs into RevenueCat's Product Catalog.

#### Link Google Cloud Credentials to RevenueCat:
- In **Google Cloud Console**, enable the **Google Play Android Developer API** and **Cloud Pub/Sub API**.
- Create a **Service Account**, generate a **JSON key file**, and download it.
- In **Google Play Console → Users & Permissions**, invite that service account email with permissions to *View app information*, *View financial data*, and *Manage orders & subscriptions*.
- Upload the downloaded JSON key file to RevenueCat under **Apps & providers → Google Play Store**.

---

### 🍎 2. Apple App Store Connect Setup

#### Create the App Listing:
- Go to **App Store Connect** and create your app using your exact Bundle Identifier.

#### Configure In-App Purchases / Subscriptions:
- Navigate to **In-App Purchases** or **Subscriptions** and create your items.
- Set up subscription groups, duration, and prices.

#### Link RevenueCat to App Store Connect:
- Generate an **In-App Purchase Key** (`.p8` file) or **Shared Secret** from App Store Connect.
- In RevenueCat, go to **Apps & providers → App Store**, enter your Bundle ID, and upload the credentials/key.

---

### 🔄 3. Update Your Flutter Code

Once store items and API keys are set up:

1. Map your native store Product IDs inside RevenueCat’s Product Catalog under the App Store and Play Store platform tabs.
2. Switch your Flutter app configuration code from the `test_` API key to your actual platform keys:

```dart
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

Future<void> initPlatformState() async {
  await Purchases.setLogLevel(LogLevel.debug);

  PurchasesConfiguration? configuration;

  if (Platform.isAndroid) {
    final androidKey = dotenv.env['REVENUECAT_ANDROID_KEY'] ?? dotenv.env['REVENUECAT_API_KEY'];
    if (androidKey != null) {
      configuration = PurchasesConfiguration(androidKey);
    }
  } else if (Platform.isIOS) {
    final iosKey = dotenv.env['REVENUECAT_IOS_KEY'] ?? dotenv.env['REVENUECAT_API_KEY'];
    if (iosKey != null) {
      configuration = PurchasesConfiguration(iosKey);
    }
  }

  if (configuration != null) {
    await Purchases.configure(configuration);
  }
}
```

3. Add test emails in **Google Play License Testing** and **Apple Sandbox Testers** to perform real test purchases on physical devices without getting charged.


