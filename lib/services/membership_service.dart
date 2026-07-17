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
}

/// Mocked subscription/billing flow.
///
/// A production build wires this to platform billing (Google Play Billing /
/// StoreKit) or a cross-platform wrapper (e.g. RevenueCat), with entitlement
/// state mirrored server-side. This mock simulates the same shape — a
/// pending purchase that resolves to an entitlement — so the UI, receipts,
/// and paywall logic are already correct and only the transport needs to
/// change.
class MembershipService {
  Future<bool> purchase(MembershipPlan plan) async {
    await Future.delayed(const Duration(milliseconds: 900));
    return true; // Mock: always succeeds. Replace with real store callback.
  }

  Future<bool> restorePurchases() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return false; // Mock: nothing to restore locally.
  }
}
