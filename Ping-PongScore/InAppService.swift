//
//  Service.swift
//  Ping-PongScore
//
//  Created by 김은지 on 1/9/24.
//

import Foundation
import StoreKit
import Combine
import SwiftUI

// [SKProduct,SKProduct,SKProduct].makeProductItems

extension Sequence where Element : SKProduct {
    func makeProductItems() -> [ProductItem] {
        self.map{ ProductItem(skProduct: $0) }
    }
}


class InAppService: NSObject, ObservableObject {
    
    static let shared = InAppService()
    
    let productIds = ["com.EggCompany.pingpongBoard.LV1"]
    
    @Published var isLoading : Bool = false
    
    @Published var iapProducts = [SKProduct]() {
        didSet {
            print("iapProducts: \(iapProducts)")
        }
    }
    
    lazy var productItems : AnyPublisher<[ProductItem], Never> = $iapProducts
        .receive(on: DispatchQueue.main)
        .map{
            $0.makeProductItems()
        }.eraseToAnyPublisher()
    
    /// 애플 상품요청 리퀘스트
    fileprivate var productsRequest = SKProductsRequest()
    
    //MARK: - 인앱 구매 초기 설정
    func initIAP() {
        print(#fileID, #function, #line, "- ")
        productsRequest = SKProductsRequest(productIdentifiers: Set(productIds))
        productsRequest.delegate = self
        productsRequest.start()
        
        if SKPaymentQueue.canMakePayments() {
            SKPaymentQueue.default().add(self)
        }
    }
    
    /// 인앱결제 완료
    func finalizeIAP() {
        print(#fileID, #function, #line, "- <# 주석 #>")
        SKPaymentQueue.default().remove(self)
    }
    
    /// 구매 복구
    func restorePurchase() {
        print(#fileID, #function, #line, "- <# 주석 #>")
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    /// 포인트 충전
        func removeAD(_ product: ProductItem) {
            print(#fileID, "- pointCharge() called / product: \(product)")
            
            
            if SKPaymentQueue.canMakePayments() {
                print(#fileID, " - 구매가능")
                
//                self.isLoading = true
//                
                if let skProductToBePaid = product.skProduct {
                    let payment = SKPayment(product: skProductToBePaid)
                    SKPaymentQueue.default().add(payment)

                    
                    print(#fileID, " 상품 구매 큐에 추가됨 : \(skProductToBePaid)")
                }
                
            } else {
                print(#fileID, " - 구매불가")
            }
        } // pointCharge
    
}

extension InAppService: SKProductsRequestDelegate {
    
    // 앱스토어에 요청한 정보 들어옴
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print(#fileID, #function, #line, "- request: \(request), response: \(response), response.products.count: \(response.products.count)")
        
        /// 애플에서 받은 등록되어있는 구매가능한 제품들
        let skProducts = response.products
        
        self.iapProducts = skProducts
        
        skProducts.forEach { aSKProduct in
            print(#fileID, "- aSKProduct.productIdentifier : ", aSKProduct.productIdentifier)
            let numberFormatter = NumberFormatter()
            numberFormatter.formatterBehavior = .behavior10_4
            numberFormatter.numberStyle = .currency
            numberFormatter.locale = aSKProduct.priceLocale
            let price1Str = numberFormatter.string(from: aSKProduct.price)
            print(#fileID, " - aSKProduct - price1Str : ", price1Str)
        }
    }
    
}

extension SKProduct {
    
    func showPrice() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.formatterBehavior = .behavior10_4
        numberFormatter.numberStyle = .currency
        numberFormatter.locale = self.priceLocale
        guard let price1Str = numberFormatter.string(from: self.price) else { return "" }
        
        return price1Str
    }
    
}

extension InAppService: SKPaymentTransactionObserver {
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        print(#fileID, #function, #line, "- 끝났다")
        withAnimation() {
           isLoading = false
       }
        
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, shouldAddStorePayment payment: SKPayment, for product: SKProduct) -> Bool {
        print(#fileID, #function, #line, "- 결제할거다")
        withAnimation {
            isLoading = true
        }
        
        return true
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        print(#fileID, #function, #line, "- 추가 트랜잭션 발생")
        
        for transaction in transactions {
                   print(#fileID, " - paymentQueue - updatedTransactions")
                   print(#fileID, " - Product ID: \(transaction.payment.productIdentifier)")
                   print(#fileID, " - Transaction ID: \(transaction.transactionIdentifier ?? "")")

                   switch transaction.transactionState {

                   case SKPaymentTransactionState.deferred:
//       //                _hud?.hide(animated: true)
//                       self.isLoading = false
                       print(#fileID, " - SKPaymentTransactionState Deferred")
                       break;
                       
                   case SKPaymentTransactionState.purchasing:
                       print(#fileID, " - SKPaymentTransactionState Purchasing")
                       withAnimation {
                              isLoading = true
                          }
                       break;
                       
                   case SKPaymentTransactionState.purchased:
//                       self.isLoading = false
       //                _hud?.hide(animated: true)
                       print(#fileID, " - SKPaymentTransactionState Purchased")
       //                self.boughtPoint(transaction)

                       #warning("결제 트랜젝션으로 구매영수증 가져오기")

                       /// 영수증
//                       if let receipt = self.getReceiptFromPaymentTransaction(transaction) {
//                           print("receipt: \(receipt)")
//                           #warning("TODO - 결제에 대한 api 쏘기")
//       //                    self.verifyReceiptAndPointCharge(transaction, receipt)
//                           
//                           // 만약 잘 되었다면
//                           SKPaymentQueue.default().finishTransaction(transaction)
//                       }
                       
                       // 만약 잘 되었다면
                      SKPaymentQueue.default().finishTransaction(transaction)
                       withAnimation {
                              isLoading = false
                          }
//
                       #warning("큐 날리기 - 트랜젝션 종료")
       //                SKPaymentQueue.default().finishTransaction(transaction)
                       
                       break

                   case SKPaymentTransactionState.failed:
       //                _hud?.hide(animated: true)
//                       self.isLoading = false
                       
                       
                       print(#fileID, " - SKPaymentTransactionState Failed: \(transaction.error?.localizedDescription ?? "")")
                       print(#fileID, " - Description: \(transaction.error.debugDescription)")
                       print(#fileID, " - Identifier: \(transaction.transactionIdentifier ?? "")")

                       if let _error = transaction.error as NSError? {
                           if _error.domain == SKErrorDomain {
                               switch _error.code {
                               case SKError.paymentCancelled.rawValue:
                                   print(#fileID, " - user cancelled the request")
                               default:

                                   break
                               }
                           }
                       }

                       #warning("큐 날리기 - 트랜젝션 종료")
                       SKPaymentQueue.default().finishTransaction(transaction)
                       withAnimation {
                              isLoading = false
                          }
                       break
                   case SKPaymentTransactionState.restored:
//                       self.isLoading = false
       //                _hud?.hide(animated: true)
                       print(#fileID, " - SKPaymentTransactionState Restored")
                       self.restorePurchase()

                       #warning("큐 날리기 - 트랜젝션 종료")
                       SKPaymentQueue.default().finishTransaction(transaction)
                       withAnimation {
                              isLoading = false
                          }
                       break
                   }
               }
        
    }
    
    
    
    
}
