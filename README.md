# Rx-MVVM-NewsApp-Sample

- https://newsapi.org/


![Simulator Screen Recording - iPhone 13 Pro - 2022-06-18 at 19 13 39](https://user-images.githubusercontent.com/6063541/174433357-49af4f7e-3022-4268-8f72-7617dbeaab35.gif)

- ViewModel

```
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
    private let action: Action<(), APIResponse>
    private let disposeBag = DisposeBag()
    
    init() {
        
        // ニュース記事一覧
        self.articles = BehaviorRelay<[Article]>(value: [])
        
        // アクション定義
        self.action = Action { _ in
            let urlStr = "https://newsapi.org/v2/top-headlines?sources=techcrunch&apiKey=\(Constants.api_key)"
            let url = URL(string:urlStr)!
            return URLRequest.load(resource: Resource<APIResponse>(url: url))
        }
        
        // 記事
        self.action.elements
            .map { $0.articles }
            .bind(to:self.articles)
            .disposed(by: disposeBag)
        
        // 起動
        self.trigger.asObservable()
            .bind(to:self.action.inputs)
            .disposed(by: disposeBag)
        
        // 検索中
        self.isLoading = action.executing.startWith(false)

        // エラー
        self.error = action.errors
    }
}
```
