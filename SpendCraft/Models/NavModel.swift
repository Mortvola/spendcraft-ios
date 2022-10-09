//
//  NavModel.swift
//  SpendCraft
//
//  Created by Richard Shields on 10/7/22.
//

import Foundation
import Combine
import Framework

final class NavModel: ObservableObject, Codable {
    @Published var selectedCategory: SpendCraft.Category?
    @Published var selectedAccount: Account?
    
    private lazy var decoder = JSONDecoder()
    private lazy var encoder = JSONEncoder()
    
    enum CodingKeys: String, CodingKey {
        case selectedCategory
        case selectedAccount
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(selectedCategory?.id, forKey: .selectedCategory)
        try container.encodeIfPresent(selectedAccount?.id, forKey: .selectedAccount)
    }
    
    init() {}
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let categorId = try container.decodeIfPresent(Int.self, forKey: .selectedCategory)
        
        if let categorId = categorId {
            selectedCategory = CategoriesStore.shared.getCategory(categoryId: categorId)
        }
        
        let accountId = try container.decodeIfPresent(Int.self, forKey: .selectedAccount)
        
        if let accountId = accountId {
            selectedAccount = AccountsStore.shared.getAccount(accountId: accountId)
        }
    }
    
    var jsonData: Data? {
        get { try? encoder.encode(self) }
        set {
            guard let data = newValue,
                  let model = try? decoder.decode(Self.self, from: data)
            else {
                return
            }
            
            selectedCategory = model.selectedCategory
            selectedAccount = model.selectedAccount
        }
    }
    
    var objectWillChangeSequence: AsyncPublisher<Publishers.Buffer<ObservableObjectPublisher>> {
        objectWillChange
            .buffer(size: 1, prefetch: .byRequest, whenFull: .dropOldest)
            .values
    }
}
