//
//  Article.swift
//  Rx-MVVM-NewsApp-Sample
//
//  Created by cano on 2022/06/18.
//

import Foundation

struct APIResponse: Decodable {
    let articles: [Article]
}

struct Article: Decodable {
    let title: String
    let description: String
}
