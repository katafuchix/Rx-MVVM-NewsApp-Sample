//
//  ViewModel.swift
//  Rx-MVVM-NewsApp-Sample
//
//  Created by cano on 2022/06/18.
//

import Foundation
import RxSwift
import RxCocoa
import NSObject_Rx
import Action


protocol ViewModelInputs {
    var trigger: PublishSubject<Void> { get }
}

protocol ViewModelOutputs {
    var articles : BehaviorRelay<[Article]> { get }
    var isLoading: Observable<Bool> { get }
    var error: Observable<ActionError> { get }
}

protocol ViewModelType {
    var inputs: ViewModelInputs { get }
    var outputs: ViewModelOutputs { get }
}


class ViewModel: ViewModelType, ViewModelInputs, ViewModelOutputs {

    var inputs: ViewModelInputs { return self }
    var outputs: ViewModelOutputs { return self }

    // MARK: - Inputs
    let trigger = PublishSubject<Void>()

    // MARK: - Outputs
    let articles : BehaviorRelay<[Article]>
    let isLoading: Observable<Bool>
    let error: Observable<ActionError>
    
    // 内部変数
    private let action: Action<(), [Article]>
    private let disposeBag = DisposeBag()
    
    init(repository: ArticleRepositoryType,
         scheduler: SchedulerType = MainScheduler.instance) {
        
        // ニュース記事一覧
        self.articles = BehaviorRelay<[Article]>(value: [])
        
        // アクション定義
        self.action = Action { _ in
            return repository.fetchArticles().observe(on: scheduler)
        }
        
        // 記事
        self.action.elements
            .observe(on: scheduler)
            .bind(to:self.articles)
            .disposed(by: disposeBag)
        
        // 起動
        self.trigger.asObservable()
            .observe(on: scheduler)
            .bind(to:self.action.inputs)
            .disposed(by: disposeBag)
        
        // 検索中
        self.isLoading = action.executing
            .observe(on: scheduler)
            .startWith(false)
            .distinctUntilChanged()

        // エラー
        self.error = action.errors.observe(on: scheduler)
    }
}
