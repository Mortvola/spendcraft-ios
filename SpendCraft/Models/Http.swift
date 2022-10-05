//
//  Http.swift
//  SpendCraft
//
//  Created by Richard Shields on 10/4/22.
//

import Foundation

let serverName = "spendcraft.app"

func getUrl(path: String) -> URL? {
    return URL(string: "https://\(serverName)\(path)")
}
