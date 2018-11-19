//
//  ViewController.swift
//  RxSwiftSample
//
//  Created by Yoki Higashihara on 2018/10/14.
//  Copyright © 2018年 Yoki Higashihara. All rights reserved.
//

import UIKit
import WebKit
import RxSwift
import RxCocoa
import RxOptional

class ViewController: UIViewController {

    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var countUpButton: UIButton!
    @IBOutlet weak var countDownButton: UIButton!
    @IBOutlet weak var countResetButton: UIButton!
    
    // webview
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var progressView: UIProgressView!
    
    private let disposeBag = DisposeBag()
    
    private var viewModel: ViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewModel()
        setupWebView()
    }
    
    private func setupViewModel() {
        let input = RxViewModelInput(
            countUpButton: countUpButton.rx.tap.asObservable(),
            countDownButton: countDownButton.rx.tap.asObservable(),
            countResetButton: countResetButton.rx.tap.asObservable()
        )
        viewModel = ViewModel(input: input)
        viewModel.outputs?.counterText
            .drive(countLabel.rx.text)
            .disposed(by: disposeBag)
    }
    
    private func setupWebView() {
        // ローディングしているときは　プログレスバーなどを表示（isHidden=false）
        
        // プログレスバーの表示制御、ゲージ制御、アクティビティインジケータ表示制御で使うた め、一旦オブザーバを定義
        let loadingObservable = webView.rx.observe(Bool.self, "loading")
            .filterNil() //nil の際はemptyを返す
            .share()
        // プログレスバーの表示・非表示 loadingObservable
        loadingObservable
            .map { return !$0 }
            .observeOn(MainScheduler.instance) // https://tech-blog.sgr-ksmt.org/2016/03/15/rxswift_scheduler/
            .bind(to: progressView.rx.isHidden)
            .disposed(by: disposeBag)
        // アクティビティインジケータ表示制御
        loadingObservable
            .bind(to: UIApplication.shared.rx.isNetworkActivityIndicatorVisible)
            .disposed(by: disposeBag)
        // NavigationController のタイトル表示
        loadingObservable
            .map { [weak self] _ in return self?.webView.title }
            .observeOn(MainScheduler.instance)
            .bind(to: navigationItem.rx.title)
            .disposed(by: disposeBag)
        // プログレスバーのゲージ制御
        webView.rx.observe(Double.self, "estimatedProgress")
            .filterNil()
            .map { return Float($0) }
            .observeOn(MainScheduler.instance)
            .bind(to: progressView.rx.progress)
            .disposed(by: disposeBag)
        
        let url = URL(string: "https://www.google.com/")
        let urlRequest = URLRequest(url: url!)
        webView.load(urlRequest)
    }
}

