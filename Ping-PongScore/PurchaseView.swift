//
//  SwiftUIView.swift
//  Ping-PongScore
//
//  Created by 김은지 on 1/9/24.
//

import SwiftUI
import StoreKit


// DTO
struct ProductItem : Identifiable {
    
    var id: UUID = UUID()
    
    var skProduct : SKProduct? = nil
    
    var title: String {
        return skProduct?.productIdentifier ?? ""
    }
    
    var price: String {
        return skProduct?.showPrice() ?? ""
    }
    
    init(skProduct: SKProduct? = nil) {
        self.skProduct = skProduct
    }
}


struct PurchaseView: View {
    
    @Binding var moveToPurchaseView: Bool
    
    @State var successPurchased: Bool = false
    @State var productItems : [ProductItem] = []
    @State var isLoading: Bool = false
    var body: some View {
        ZStack{
            
            List(productItems, id: \.id) { aProductItem in
                VStack(alignment: .leading) {
                    Text(aProductItem.title)
                    Text(aProductItem.price)
                }.onTapGesture {
                    InAppService.shared.removeAD(aProductItem)
                }
            }.zIndex(1)
            
            if isLoading {
                Color.gray.opacity(0.3).ignoresSafeArea()
                    .overlay(alignment: .center, content: {
                        ProgressView()
                    }).zIndex(2)
            }
            
        }
        .onReceive(InAppService.shared.productItems, perform: {productItems in
            self.productItems = productItems
        })
        .onReceive(InAppService.shared.$isLoading, perform: { isLoading in
            self.isLoading = isLoading
        })
        .onReceive(InAppService.shared.$successPurchased, perform: { successPurchased in
            self.successPurchased = successPurchased
            if successPurchased {
                // 구매 성공 시 PurchaseView 닫기
                self.moveToPurchaseView = false
            }
        })
    }
    
}

#Preview {
    PurchaseView(moveToPurchaseView: .constant(true))
}
