//
//  CategoriesStore.swift
//  SpendCraft
//
//  Created by Richard Shields on 9/19/22.
//

import Foundation

class CategoriesStore: ObservableObject {
    @Published var categories: Categories = Categories(tree: [])
    
    static func load(completion: @escaping (Result<Categories, Error>)->Void) {
        try? Http.get(path: "/api/groups") { data in
            guard let data = data else {
                print ("data is nil")
                return;
            }
            
            var categoriesResponse: [Response.CategoryTreeNode]
            do {
                categoriesResponse = try JSONDecoder().decode([Response.CategoryTreeNode].self, from: data)
            }
            catch {
                print ("Error: \(error)")
                return
            }

            let categories: Categories = Categories(tree: categoriesResponse);
        
            DispatchQueue.main.async {
                completion(.success(categories))
            }
        }
    }
}
