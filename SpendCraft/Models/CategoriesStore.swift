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
        guard let url = URL(string: "https://spendcraft.app/api/groups") else {
            return
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        
        guard let session = try? getSession() else {
            return
        }

        let task = session.dataTask(with: urlRequest) {data, response, error in
            if let error = error {
                print("Error: \(error)");
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                print ("response is nil")
                return
            }
            
            guard (200...299).contains(response.statusCode) else {
                print ("Server error: \(response.statusCode)")
                return
            }
            
            print("success: \(response.statusCode)")
            
            guard let data = data else {
                print ("data is nil")
                return;
            }
            
            var categoriesResponse: [CategoryTreeNode]
            do {
                categoriesResponse = try JSONDecoder().decode([CategoryTreeNode].self, from: data)
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
        task.resume()
    }
}
