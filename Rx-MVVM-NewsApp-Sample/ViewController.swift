//
//  ViewController.swift
//  Rx-MVVM-NewsApp-Sample
//
//  Created by cano on 2022/06/18.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx
import MBProgressHUD

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    let viewModel = ViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        
        self.setUpViews()
        self.bind()
        
        self.viewModel.trigger.onNext(())
    }
    
    func setUpViews() {
        // cell登録
        self.tableView.register(R.nib.articleCell)
        
        // cell表示
        self.tableView.rx.willDisplayCell
            .subscribe(onNext: ({ (cell,indexPath) in
                cell.alpha = 0
                let transform = CATransform3DTranslate(CATransform3DIdentity, -250, 0, 0)
                cell.layer.transform = transform
                UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                    cell.alpha = 1
                    cell.layer.transform = CATransform3DIdentity
                }, completion: nil)
            })).disposed(by: rx.disposeBag)
    }
    
    func bind() {
        
        // 記事
        self.viewModel.outputs
            .articles.asObservable()
            .bind(to: self.tableView.rx.items) {
                (tableView, row, element ) in
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.articleCell, for:  IndexPath(row : row, section : 0))!
                cell.configure(element)
                return cell
            }
            .disposed(by: rx.disposeBag)
        
        // 記事取得中はMBProgressHUDを表示
        self.viewModel.outputs
            .isLoading.asDriver(onErrorJustReturn: false)
            .drive(MBProgressHUD.rx.isAnimating(view: self.view))
            .disposed(by: rx.disposeBag)
        
        // エラー表示
        self.viewModel.outputs
            .error
            .subscribe(onNext: { [weak self] error in
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "エラー", message: error.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self?.present(alert, animated: true, completion: nil)
                }
            })
            .disposed(by: rx.disposeBag)
    }
}

