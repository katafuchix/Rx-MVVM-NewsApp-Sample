//
//  ViewModelTests.swift
//  Rx-MVVM-NewsApp-Sample
//
//  Created by cano on 2026/02/04.
//

import XCTest
import RxSwift
import RxRelay
import RxTest

@testable import Rx_MVVM_NewsApp_Sample

class ViewModelTests: XCTestCase {
    
    var viewModel: ViewModel!
    var mockRepository: MockArticleRepository!
    var scheduler: TestScheduler!
    var disposeBag: DisposeBag!
    
    override func setUp() {
        super.setUp()
        // 1. 仮想時間を扱うスケジューラを作成
        self.scheduler = TestScheduler(initialClock: 0)
        self.disposeBag = DisposeBag()
        
        self.mockRepository = MockArticleRepository()
        // テスト用の scheduler を注入してインスタンス化！
        self.viewModel = ViewModel(repository: self.mockRepository, scheduler: self.scheduler)
    }
    
    func test_load_articles_success() {
        // 1. 準備
        let mockArticles = [Article(title: "title", description: "descrition")]
        mockRepository.stubbedArticles = .just(mockArticles)
        
        let articlesObserver = scheduler.createObserver([Article].self)
        let loadingObserver  = scheduler.createObserver(Bool.self)
        
        viewModel.outputs.articles.subscribe(articlesObserver).disposed(by: disposeBag)
        viewModel.outputs.isLoading.subscribe(loadingObserver).disposed(by: disposeBag)

        // 2. 実行
        viewModel.trigger.onNext(())
        
        // Action の内部処理が進むように時間を進める
        scheduler.advanceTo(10)

        // 3. 検証
        // articles の検証
        let articleEvents = articlesObserver.events.compactMap { $0.value.element }
        XCTAssertEqual(articleEvents.last?.first?.title, "title")

        // isLoading の検証 (false -> true -> false の順に変化するはず)
        let loadingEvents = loadingObserver.events.compactMap { $0.value.element }
        XCTAssertEqual(loadingEvents, [false, true, false])
    }
    
    func test_load_articles_failure() {
        // 1. 準備：エラーを返すように設定
        mockRepository.shouldReturnError = true
        
        let loadingObserver = scheduler.createObserver(Bool.self)
        let errorObserver = scheduler.createObserver(Bool.self) // エラーが届いたか監視
        
        viewModel.outputs.isLoading.subscribe(loadingObserver).disposed(by: disposeBag)
        // エラーが発生したこと（ストリームにイベントが流れたか）を監視
        viewModel.outputs.error.map { _ in true }.subscribe(errorObserver).disposed(by: disposeBag)

        // 2. 実行
        viewModel.trigger.onNext(())
        scheduler.advanceTo(10)

        // 3. 検証
        // ① isLoading の検証：エラーが起きても [false, true, false] と戻るべき
        let loadingResults = loadingObserver.events.compactMap { $0.value.element }
        XCTAssertEqual(loadingResults, [false, true, false], "エラー時もローディングは終了する必要があります")

        // ② エラー通知の検証：イベントが1回飛んできているか
        let errorEvents = errorObserver.events.compactMap { $0.value.element }
        XCTAssertEqual(errorEvents.count, 1, "エラー通知が飛んできていません")
    }
}


// MARK: - Test Helpers
final class MockArticleRepository: ArticleRepositoryType {

    var stubbedArticles: Observable<[Article]> = .empty()// 成功時に返したいデータ
    var shouldReturnError = false  // エラーを発生させたい場合は true にする
    
    func fetchArticles() -> Observable<[Article]> {
        if shouldReturnError {
            // ActionError.underlyingError として扱われるように適当なエラーを返す
            return .error(NSError(domain: "test", code: -1, userInfo: nil))
        }
        return stubbedArticles
    }
}
