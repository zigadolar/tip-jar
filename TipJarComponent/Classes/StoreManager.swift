//
//  StoreManager.swift
//  TipJarComponent
//
//  Created by Dolar, Ziga on 07/23/2019.
//  Copyright (c) 2019 Dolar, Ziga. All rights reserved.
//

import Foundation
import StoreKit

typealias StoreFetchProductsHandler = ([SKProduct]) -> Void
typealias StorePaymentTransactionHandler = (Bool) -> Void

class StoreManager: NSObject {
    static var productIdentifiers: [String] = [] {
        didSet {
            shared.productIdentifiers = Set(productIdentifiers)
        }
    }

    static let shared: StoreManager = StoreManager(productIds: StoreManager.productIdentifiers)

    var productIdentifiers: Set<String>

    var productRequest: SKProductsRequest?
    var productRequestHandler: StoreFetchProductsHandler?

    var products: [SKProduct] = []

    var paymentTransactionHandlers: [String: StorePaymentTransactionHandler] = [:]

    lazy var persistenceManager: TipPersistenceManager = .shared

    private init(productIds: [String]) {
        self.productIdentifiers = Set(productIds)

        super.init()

        SKPaymentQueue.default().add(self)
    }

    func fetchProducts(_ handler:@escaping StoreFetchProductsHandler) {
        productRequestHandler = handler

        productRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
        productRequest?.delegate = self

        productRequest?.start()
    }

    func purchase(_ product: SKProduct, handler: @escaping StorePaymentTransactionHandler) {
        paymentTransactionHandlers[product.productIdentifier] = handler

        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
}

extension StoreManager: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        productRequestHandler?(response.products)
        products = response.products

        resetRequest()
    }

    func request(_ request: SKRequest, didFailWithError error: Error) {
        productRequestHandler?([])
        resetRequest()
    }

    func resetRequest() {
        productRequest = nil
        productRequestHandler = nil
    }
}

extension StoreManager: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        transactions.forEach { transaction in
            var shouldFinishTransaction = false

            switch transaction.transactionState {
            case .purchased:
                shouldFinishTransaction = true
                completeTransaction(transaction, with: true)
            case .failed:
                completeTransaction(transaction, with: false)
            default:
                debugPrint("other: \(transaction.payment.productIdentifier)")
            }

            if shouldFinishTransaction {
                queue.finishTransaction(transaction)
            }
        }
    }

    private func completeTransaction(_ transaction: SKPaymentTransaction, with success: Bool) {
        if success {
            persistSuccessfulTransaction(transaction)
        }

        guard let handler = paymentTransactionHandlers[transaction.payment.productIdentifier] else {
            return
        }

        handler(success)
    }

    private func persistSuccessfulTransaction(_ transaction: SKPaymentTransaction) {
        if let product = products.first(where: { $0.productIdentifier == transaction.payment.productIdentifier }) {
            debugPrint(product)
            debugPrint(transaction)

            guard let transactionDate = transaction.transactionDate,
                let transactionIdentifier = transaction.transactionIdentifier else {
                    return
            }

            let tip = Tip(price: product.price,
                          priceLocale: product.priceLocale,
                          productIdentifier: product.productIdentifier,
                          transactionIdentifier: transactionIdentifier,
                          transactionDate: transactionDate)

            persistenceManager.persist(tip: tip)
        }
    }
}
