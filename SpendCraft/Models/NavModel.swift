//
//  NavModel.swift
//  SpendCraft
//
//  Created by Richard Shields on 10/7/22.
//

import Foundation

final class NavModel: ObservableObject, Codable {
    @Published var selectedCategory: CategoriesStore.Category?
    
    enum CodingKeys: String, CodingKey {
        case selectedCategory
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(selectedCategory?.id, forKey: .selectedCategory)
    }

    init() {}
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        var id = try container.decodeIfPresent(Int.self, forKey: .selectedCategory)
    }
}
