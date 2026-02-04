//
//  Repository.swift
//  Rx-MVVM-NewsApp-Sample
//
//  Created by cano on 2026/02/04.
//

import Foundation
import RxSwift

// 通信部分を抽象化
protocol ArticleRepositoryType {
    func fetchArticles() -> Observable<[Article]>
}

class ArticleRepository: ArticleRepositoryType {
    func fetchArticles() -> Observable<[Article]> {
        let urlStr = "https://newsapi.org/v2/top-headlines?sources=techcrunch&apiKey=\(Constants.api_key)"
        let url = URL(string:urlStr)!
        return URLRequest.load(resource: Resource<APIResponse>(url: url))
                .map {$0.articles}
    }
}
