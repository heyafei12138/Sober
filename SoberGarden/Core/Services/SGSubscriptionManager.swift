//
//  SGSubscriptionManager.swift
//  SoberGarden
//

import Foundation
import StoreKit

enum SGSubscriptionProduct: String, CaseIterable {
    case weekly
    case yearly
    case lifetime

    var productID: String {
        switch self {
        case .weekly:
            return "sober.weekly"
        case .yearly:
            return "sober.yearly"
        case .lifetime:
            return "SoberGarden.Lifetime"
        }
    }

    var title: String {
        switch self {
        case .weekly:
            return "Weekly"
        case .yearly:
            return "Yearly"
        case .lifetime:
            return "Lifetime"
        }
    }

    var fallbackPrice: String {
        switch self {
        case .weekly:
            return "$12.99"
        case .yearly:
            return "$124.99"
        case .lifetime:
            return "$139.99"
        }
    }

    var cadence: String {
        switch self {
        case .weekly:
            return "per week"
        case .yearly:
            return "per year"
        case .lifetime:
            return "one time"
        }
    }

    var discount: String {
        switch self {
        case .weekly:
            return "No lock-in"
        case .yearly:
            return "84% OFF"
        case .lifetime:
            return "74% OFF"
        }
    }

    var badge: String {
        switch self {
        case .weekly:
            return "Flexible"
        case .yearly:
            return "Best Value"
        case .lifetime:
            return "Forever"
        }
    }

    var highlight: String {
        switch self {
        case .weekly:
            return "Start small"
        case .yearly:
            return "$2.08/mo"
        case .lifetime:
            return "Pay once"
        }
    }

    static func product(for productID: String) -> SGSubscriptionProduct? {
        allCases.first { $0.productID == productID }
    }
}

enum SGSubscriptionEntitlement: Equatable {
    case unknown
    case free
    case active(plan: SGSubscriptionProduct, expirationDate: Date?)
    case lifetime

    var isPlus: Bool {
        switch self {
        case .active, .lifetime:
            return true
        case .unknown, .free:
            return false
        }
    }
}

enum SGSubscriptionPurchaseResult: Equatable {
    case purchased
    case cancelled
    case pending
    case failed(String)
}

@MainActor
final class SGSubscriptionManager {

    static let shared = SGSubscriptionManager()
    static let entitlementDidChangeNotification = Notification.Name("SGSubscriptionManager.entitlementDidChange")

    private enum CacheKey {
        static let entitlement = "sg.subscription.cachedEntitlement"
        static let productID = "sg.subscription.cachedProductID"
        static let expirationDate = "sg.subscription.cachedExpirationDate"
    }

    private(set) var products: [String: Product] = [:]
    private(set) var entitlement: SGSubscriptionEntitlement = .unknown {
        didSet {
            guard entitlement != oldValue else { return }
            cacheEntitlement()
            NotificationCenter.default.post(name: Self.entitlementDidChangeNotification, object: self)
        }
    }

    var isPlus: Bool {
        entitlement.isPlus
    }

    private var transactionUpdatesTask: Task<Void, Never>?
    private let defaults: UserDefaults

    private init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        entitlement = Self.cachedEntitlement(from: defaults)
    }

    deinit {
        transactionUpdatesTask?.cancel()
    }

    func start() {
        guard transactionUpdatesTask == nil else { return }
        transactionUpdatesTask = observeTransactionUpdates()

        Task {
            await loadProductsIfNeeded()
            await refreshEntitlements()
        }
    }

    func loadProductsIfNeeded() async {
        guard products.isEmpty else { return }

        do {
            let storeProducts = try await Product.products(for: SGSubscriptionProduct.allCases.map(\.productID))
            products = Dictionary(uniqueKeysWithValues: storeProducts.map { ($0.id, $0) })
        } catch {
            debugPrint("Failed to load subscription products: \(error)")
        }
    }

    func displayPrice(for plan: SGSubscriptionProduct) -> String {
        products[plan.productID]?.displayPrice ?? plan.fallbackPrice
    }

    func product(for plan: SGSubscriptionProduct) -> Product? {
        products[plan.productID]
    }

    func purchase(_ plan: SGSubscriptionProduct) async -> SGSubscriptionPurchaseResult {
        await loadProductsIfNeeded()

        guard let product = product(for: plan) else {
            return .failed("This product is not available yet. Check App Store Connect product IDs.")
        }

        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                guard case .verified(let transaction) = verification else {
                    return .failed("The purchase could not be verified.")
                }

                await transaction.finish()
                await refreshEntitlements()
                return .purchased

            case .userCancelled:
                return .cancelled

            case .pending:
                return .pending

            @unknown default:
                return .failed("The purchase could not be completed.")
            }
        } catch {
            return .failed(error.localizedDescription)
        }
    }

    func restorePurchases() async -> SGSubscriptionPurchaseResult {
        do {
            try await AppStore.sync()
            await refreshEntitlements()
            return isPlus ? .purchased : .failed("No active subscription or lifetime purchase was found.")
        } catch {
            return .failed(error.localizedDescription)
        }
    }

    func refreshEntitlements() async {
        var bestEntitlement: SGSubscriptionEntitlement = .free
        var latestSubscriptionExpirationDate: Date?
        var latestSubscriptionPlan: SGSubscriptionProduct?

        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result,
                  transaction.revocationDate == nil,
                  let plan = SGSubscriptionProduct.product(for: transaction.productID) else {
                continue
            }

            if plan == .lifetime {
                bestEntitlement = .lifetime
                break
            }

            if let expirationDate = transaction.expirationDate, expirationDate < Date() {
                continue
            }

            if latestSubscriptionExpirationDate == nil ||
                (transaction.expirationDate ?? .distantFuture) > (latestSubscriptionExpirationDate ?? .distantPast) {
                latestSubscriptionExpirationDate = transaction.expirationDate
                latestSubscriptionPlan = plan
            }
        }

        if bestEntitlement != .lifetime, let latestSubscriptionPlan {
            bestEntitlement = .active(plan: latestSubscriptionPlan, expirationDate: latestSubscriptionExpirationDate)
        }

        entitlement = bestEntitlement
    }

    private func observeTransactionUpdates() -> Task<Void, Never> {
        Task.detached { [weak self] in
            for await result in Transaction.updates {
                guard let self else { return }

                if case .verified(let transaction) = result {
                    await transaction.finish()
                }

                await self.refreshEntitlements()
            }
        }
    }

    private func cacheEntitlement() {
        switch entitlement {
        case .unknown:
            defaults.set("unknown", forKey: CacheKey.entitlement)
            defaults.removeObject(forKey: CacheKey.productID)
            defaults.removeObject(forKey: CacheKey.expirationDate)
        case .free:
            defaults.set("free", forKey: CacheKey.entitlement)
            defaults.removeObject(forKey: CacheKey.productID)
            defaults.removeObject(forKey: CacheKey.expirationDate)
        case .active(let plan, let expirationDate):
            defaults.set("active", forKey: CacheKey.entitlement)
            defaults.set(plan.productID, forKey: CacheKey.productID)
            defaults.set(expirationDate, forKey: CacheKey.expirationDate)
        case .lifetime:
            defaults.set("lifetime", forKey: CacheKey.entitlement)
            defaults.set(SGSubscriptionProduct.lifetime.productID, forKey: CacheKey.productID)
            defaults.removeObject(forKey: CacheKey.expirationDate)
        }
    }

    private static func cachedEntitlement(from defaults: UserDefaults) -> SGSubscriptionEntitlement {
        let rawValue = defaults.string(forKey: CacheKey.entitlement)
        let productID = defaults.string(forKey: CacheKey.productID)
        let expirationDate = defaults.object(forKey: CacheKey.expirationDate) as? Date

        switch rawValue {
        case "active":
            guard let productID,
                  let plan = SGSubscriptionProduct.product(for: productID),
                  plan != .lifetime else {
                return .unknown
            }

            if let expirationDate, expirationDate < Date() {
                return .free
            }
            return .active(plan: plan, expirationDate: expirationDate)

        case "lifetime":
            return .lifetime

        case "free":
            return .free

        default:
            return .unknown
        }
    }
}
