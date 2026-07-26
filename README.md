# TstRCPay — RevenueCat Flutter Integration App

`TstRCPay` is a production-ready Flutter application built to test and demonstrate **RevenueCat In-App Purchases & Subscriptions** following a clean, feature-driven architecture using **GetX** and custom design tokens as defined in `GEMINI.md`.

---

## 📂 Comprehensive Directory & File Guide

Below is a detailed breakdown explaining the purpose and responsibility of **every single file** in this project:

```text
tstrcpay/
├── .env                                       # Environment configuration storing RevenueCat API keys
├── .gitignore                                  # Git exclusion file (protects .env and build files)
├── pubspec.yaml                               # Flutter dependencies & assets configuration
├── REVENUECAT_IMPLEMENTATION_GUIDE.md          # Full implementation & Google/Apple Console setup guide
├── android/
│   └── app/src/main/
│       ├── AndroidManifest.xml                # Android manifest declaring Billing & Internet permissions
│       └── kotlin/com/example/tstrcpay/
│           └── MainActivity.kt                # FlutterFragmentActivity for RevenueCat UI support
└── lib/
    ├── app.dart                               # Root GetMaterialApp configuration & theme
    ├── main.dart                              # Application entry point & dotenv loader
    ├── routes/
    │   └── app_routes.dart                    # Application route definitions & GetPage configuration
    ├── core/
    │   ├── binding/
    │   │   └── controller_binder.dart         # GetX dependency binder (Controller lazyPut)
    │   ├── common/
    │   │   └── style/
    │   │       └── global_text_style.dart     # Centralized Inter typography style helper
    │   ├── constants/
    │   │   └── app_color.dart                 # Design system color tokens & palette
    │   └── services/
    │       └── revenue_cat_service.dart       # Wrapper service interfacing with Purchases SDK
    └── features/
        └── revenue_cat_test/
            ├── controller/
            │   └── revenue_cat_controller.dart# GetX reactive state management & business logic
            ├── screen/
            │   └── revenue_cat_test_screen.dart# Main dashboard view
            └── widgets/
                ├── active_subscription_card.dart# Card shown when customer holds an active subscription
                ├── log_viewer.dart            # Interactive real-time console trace log viewer
                ├── package_card.dart          # Subscription package card (Monthly, Yearly, Lifetime)
                ├── status_card.dart           # SDK connection status & API key configuration card
                └── user_identity_card.dart    # Customer ID login form & active customer header
```

---

## 🛠️ Detailed File Explanations

### 1. Root Configuration Files

- 📄 **[.env](file:///Users/labib/Desktop/Fahim_Workspace/tstrcpay/.env)**  
  Stores sensitive API keys safely outside source code (`REVENUECAT_API_KEY`, `REVENUECAT_ANDROID_KEY`, `REVENUECAT_IOS_KEY`).

- 📄 **[.gitignore](file:///Users/labib/Desktop/Fahim_Workspace/tstrcpay/.gitignore)**  
  Excludes temporary build files, IDE settings, `.agents`, and `.env` to prevent committing secrets to version control.

- 📄 **[pubspec.yaml](file:///Users/labib/Desktop/Fahim_Workspace/tstrcpay/pubspec.yaml)**  
  Declares Flutter package dependencies (`purchases_flutter`, `purchases_ui_flutter`, `get`, `flutter_dotenv`, `flutter_easyloading`) and includes `.env` under assets.

- 📄 **[REVENUECAT_IMPLEMENTATION_GUIDE.md](file:///Users/labib/Desktop/Fahim_Workspace/tstrcpay/REVENUECAT_IMPLEMENTATION_GUIDE.md)**  
  A step-by-step developer guide explaining mobile in-app purchase mechanics, Google Play Console setup, App Store Connect setup, and why mobile apps do not use credit card entry UIs (like Stripe).

---

### 2. Application Core (`lib/`)

- 📄 **[lib/main.dart](file:///Users/labib/Desktop/Fahim_Workspace/tstrcpay/lib/main.dart)**  
  The main entry point of the Flutter application. Initializes `WidgetsFlutterBinding`, loads `.env` variables asynchronously using `flutter_dotenv`, configures global `EasyLoading` toast settings, and launches `MyApp`.

- 📄 **[lib/app.dart](file:///Users/labib/Desktop/Fahim_Workspace/tstrcpay/lib/app.dart)**  
  Configures `GetMaterialApp`, specifies the dark theme scheme (`AppColor.bgDark`), registers global controller bindings (`ControllerBinder`), defines initial routes (`AppRoutes.revenueCatTestScreen`), and wraps the app with `EasyLoading.init()`.

- 📄 **[lib/routes/app_routes.dart](file:///Users/labib/Desktop/Fahim_Workspace/tstrcpay/lib/routes/app_routes.dart)**  
  Centralized navigation route constants and `GetPage` definitions mapping string routes (e.g. `/revenue_cat_test`) to their respective screen views and bindings.

---

### 3. Core Architecture Module (`lib/core/`)

- 📄 **[lib/core/binding/controller_binder.dart](file:///Users/labib/Desktop/Fahim_Workspace/tstrcpay/lib/core/binding/controller_binder.dart)**  
  Implements GetX `Bindings`. Lazily registers `RevenueCatController` (`fenix: true`) so business logic remains accessible and persistent throughout the app lifecycle.

- 📄 **[lib/core/constants/app_color.dart](file:///Users/labib/Desktop/Fahim_Workspace/tstrcpay/lib/core/constants/app_color.dart)**  
  Contains all project design color tokens (`primaryBlue`, `primaryFontColor`, `secondaryTextColor`, `bgDark`, `cardDark`, `accentPurple`, `successGreen`, `warningAmber`, `errorRed`). Prevents raw hex values in UI widgets.

- 📄 **[lib/core/common/style/global_text_style.dart](file:///Users/labib/Desktop/Fahim_Workspace/tstrcpay/lib/core/common/style/global_text_style.dart)**  
  Provides a standardized `AppTextStyle.getTextStyle(...)` typography factory defaulting to the `Inter` font family with custom size, weight, and color overrides.

- 📄 **[lib/core/services/revenue_cat_service.dart](file:///Users/labib/Desktop/Fahim_Workspace/tstrcpay/lib/core/services/revenue_cat_service.dart)**  
  Low-level singleton service directly calling RevenueCat SDK APIs (`Purchases.configure`, `getCustomerInfo`, `getOfferings`, `purchasePackage`, `restorePurchases`, `logIn`, `logOut`, and `RevenueCatUI.presentPaywall`).

---

### 4. Feature Domain Module (`lib/features/revenue_cat_test/`)

#### 🎮 Controller (`controller/`)
- 📄 **[lib/features/revenue_cat_test/controller/revenue_cat_controller.dart](file:///Users/labib/Desktop/Fahim_Workspace/tstrcpay/lib/features/revenue_cat_test/controller/revenue_cat_controller.dart)**  
  GetX `GetxController` managing all reactive state (`isLoggedIn`, `hasActiveSubscription`, `appUserId`, `activeEntitlements`, `currentOffering`, `logs`). Contains action methods for logging in customer IDs, purchasing packages, restoring purchases, and prepending trace logs.

#### 🖥️ Main Screen (`screen/`)
- 📄 **[lib/features/revenue_cat_test/screen/revenue_cat_test_screen.dart](file:///Users/labib/Desktop/Fahim_Workspace/tstrcpay/lib/features/revenue_cat_test/screen/revenue_cat_test_screen.dart)**  
  The main dashboard screen. Dynamically renders Customer Login, Active Subscription view, or Paywall Offerings catalog depending on user authentication & subscription state.

#### 🧩 Widgets (`widgets/`)
- 📄 **[lib/features/revenue_cat_test/widgets/status_card.dart](file:///Users/labib/Desktop/Fahim_Workspace/tstrcpay/lib/features/revenue_cat_test/widgets/status_card.dart)**  
  Renders SDK connection status pill (`CONNECTED` / `DISCONNECTED`), editable API key input, and active entitlement metric counter.

- 📄 **[lib/features/revenue_cat_test/widgets/user_identity_card.dart](file:///Users/labib/Desktop/Fahim_Workspace/tstrcpay/lib/features/revenue_cat_test/widgets/user_identity_card.dart)**  
  Serves as the **Step 1 Customer Login** form when logged out, and as the **Active Customer Account** header bar with a "Switch" button when logged in.

- 📄 **[lib/features/revenue_cat_test/widgets/package_card.dart](file:///Users/labib/Desktop/Fahim_Workspace/tstrcpay/lib/features/revenue_cat_test/widgets/package_card.dart)**  
  Renders individual subscription packages (Monthly $9.99, Yearly $79.98, Lifetime $99.99) with localized price strings, package badges, store product IDs, and "Buy Package" buttons.

- 📄 **[lib/features/revenue_cat_test/widgets/active_subscription_card.dart](file:///Users/labib/Desktop/Fahim_Workspace/tstrcpay/lib/features/revenue_cat_test/widgets/active_subscription_card.dart)**  
  Renders when a customer holds an active subscription (`PRO ACTIVE` status), displaying entitlement details, product ID, purchase/expiration dates, and a "Re-verify Purchase" button.

- 📄 **[lib/features/revenue_cat_test/widgets/log_viewer.dart](file:///Users/labib/Desktop/Fahim_Workspace/tstrcpay/lib/features/revenue_cat_test/widgets/log_viewer.dart)**  
  An interactive real-time console trace log viewer displaying timestamped API payloads, success messages, and error trace logs.

---

### 5. Android Platform Configuration (`android/`)

- 📄 **[android/app/src/main/AndroidManifest.xml](file:///Users/labib/Desktop/Fahim_Workspace/tstrcpay/android/app/src/main/AndroidManifest.xml)**  
  Declares necessary Android permissions:
  - `com.android.vending.BILLING` (Mandatory for Google Play In-App Purchases).
  - `android.permission.INTERNET` (Network communication).
  - `android.permission.ACCESS_NETWORK_STATE` (Network connectivity checks).

- 📄 **[android/app/src/main/kotlin/.../MainActivity.kt](file:///Users/labib/Desktop/Fahim_Workspace/tstrcpay/android/app/src/main/kotlin/com/example/tstrcpay/MainActivity.kt)**  
  Extends `FlutterFragmentActivity` instead of `FlutterActivity` to allow RevenueCat UI native Android Fragment paywall sheets to render properly.

---

### 6. iOS Platform Configuration (`ios/`)

- 📄 **[ios/Runner/Info.plist](file:///Users/labib/Desktop/Fahim_Workspace/tstrcpay/ios/Runner/Info.plist)**  
  Unlike Android, iOS does **not** require explicit XML permission tags in `Info.plist` for StoreKit In-App Purchases. Instead, Apple requires enabling the **In-App Purchase** capability in Xcode:
  1. Open `ios/Runner.xcworkspace` in Xcode.
  2. Go to **Runner** target -> **Signing & Capabilities**.
  3. Click **+ Capability** and select **In-App Purchase**.

---

## ⚡ How to Run

1. Ensure Flutter SDK (`^3.11.5` or higher) is installed.
2. Fetch dependencies:
   ```bash
   flutter pub get
   ```
3. Run on Android Emulator, iOS Simulator, or physical device:
   ```bash
   flutter run
   ```
