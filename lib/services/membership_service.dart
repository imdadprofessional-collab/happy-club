import 'dart:async';

import 'package:in_app_purchase/in_app_purchase.dart';

enum MembershipStatus { none, trialActive, monthly, yearly, expired }

extension MembershipStatusX on MembershipStatus {
  bool get isActive =>
      this != MembershipStatus.none && this != MembershipStatus.expired;
}

enum MembershipPlan { trial, monthly, yearly }

extension MembershipPlanX on MembershipPlan {
  String get title {
    switch (this) {
      case MembershipPlan.trial:
        return 'First Month';
      case MembershipPlan.monthly:
        return 'Monthly';
      case MembershipPlan.yearly:
        return 'Yearly';
    }
  }

  String get priceLabel {
    switch (this) {
      case MembershipPlan.trial:
        return '\$1.00';
      case MembershipPlan.monthly:
        return '\$4.99 / month';
      case MembershipPlan.yearly:
        return '\$39.99 / year';
    }
  }

  /// The Play Console / App Store Connect product ID backing this plan.
  ///
  /// `trial` and `monthly` share a product: the trial is the $1
  /// introductory-price phase of the monthly subscription's base plan,
  /// configured in Play Console (Monetize > Products > Subscriptions >
  /// "happy_club_monthly" > base plan offer), not a separate product.
  /// Google grants the intro price automatically to eligible accounts —
  /// no separate client-side handling is needed.
  String get productId {
    switch (this) {
      case MembershipPlan.trial:
      case MembershipPlan.monthly:
        return 'happy_club_monthly';
      case MembershipPlan.yearly:
        return 'happy_club_yearly';
    }
  }
}

/// Real Google Play Billing / StoreKit subscription flow via the
/// cross-platform `in_app_purchase` plugin.
///
/// Product IDs must be created in Play Console (Monetize > Products >
/// Subscriptions) — see productId above — before purchases will succeed.
/// This performs client-side entitlement only; for production-grade fraud
/// resistance, mirror `PurchaseDetails.verificationData` to a backend
/// (e.g. a Cloud Function) and verify against the Play Developer API /
/// App Store Server API before granting entitlement server-side.
class MembershipService {
  static const Set<String> _productIds = {'happy_club_monthly', 'happy_club_yearly'};

  StreamSubscription<List<PurchaseDetails>>? _purchaseSub;
  final Map<String, ProductDetails> _products = {};

  Completer<bool>? _pendingPurchase;
  String? _pendingProductId;

  Completer<bool>? _pendingRestore;
  bool _restoredAny = false;

  /// Store-provided [ProductDetails] for a plan, once [loadProducts] has
  /// run — use this for live pricing/currency instead of the hardcoded
  /// [MembershipPlanX.priceLabel] fallback when available.
  ProductDetails? productFor(MembershipPlan plan) => _products[plan.productId];

  /// Billing is unavailable (and every call below resolves to a safe
  /// no-op/false) on hosts with no store — desktop, `flutter test`'s host
  /// runner, or a device signed out of Play/App Store — not just when the
  /// plugin genuinely reports unavailable.
  Future<bool> _ensureReady() async {
    try {
      _purchaseSub ??= InAppPurchase.instance.purchaseStream.listen(
        _onPurchaseUpdate,
        onError: (_) {},
      );
      return await InAppPurchase.instance.isAvailable();
    } catch (_) {
      return false;
    }
  }

  Future<bool> loadProducts() async {
    if (!await _ensureReady()) return false;
    try {
      final response = await InAppPurchase.instance.queryProductDetails(
        _productIds,
      );
      for (final product in response.productDetails) {
        _products[product.id] = product;
      }
      return response.notFoundIDs.isEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<bool> purchase(MembershipPlan plan) async {
    if (!await _ensureReady()) return false;
    if (_products.isEmpty) await loadProducts();

    final product = _products[plan.productId];
    if (product == null) return false;

    final completer = Completer<bool>();
    _pendingPurchase = completer;
    _pendingProductId = product.id;

    try {
      final started = await InAppPurchase.instance.buyNonConsumable(
        purchaseParam: PurchaseParam(productDetails: product),
      );
      if (!started) {
        _pendingPurchase = null;
        _pendingProductId = null;
        return false;
      }
    } catch (_) {
      _pendingPurchase = null;
      _pendingProductId = null;
      return false;
    }
    return completer.future;
  }

  Future<bool> restorePurchases() async {
    if (!await _ensureReady()) return false;

    final completer = Completer<bool>();
    _pendingRestore = completer;
    _restoredAny = false;

    try {
      await InAppPurchase.instance.restorePurchases();
    } catch (_) {
      _pendingRestore = null;
      return false;
    }

    // The store replays past purchases asynchronously through
    // purchaseStream; give it a window to arrive before giving up.
    Timer(const Duration(seconds: 5), () {
      if (!completer.isCompleted) completer.complete(_restoredAny);
    });
    return completer.future;
  }

  void _onPurchaseUpdate(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      switch (purchase.status) {
        case PurchaseStatus.pending:
          continue;
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          if (purchase.status == PurchaseStatus.restored) {
            _restoredAny = true;
            if (_pendingRestore != null && !_pendingRestore!.isCompleted) {
              _pendingRestore!.complete(true);
            }
          }
          if (purchase.productID == _pendingProductId) {
            _pendingPurchase?.complete(true);
            _pendingPurchase = null;
            _pendingProductId = null;
          }
        case PurchaseStatus.error:
        case PurchaseStatus.canceled:
          if (purchase.productID == _pendingProductId) {
            _pendingPurchase?.complete(false);
            _pendingPurchase = null;
            _pendingProductId = null;
          }
      }
      if (purchase.pendingCompletePurchase) {
        InAppPurchase.instance.completePurchase(purchase);
      }
    }
  }

  void dispose() {
    _purchaseSub?.cancel();
  }
}
