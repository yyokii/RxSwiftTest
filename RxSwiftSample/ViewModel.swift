//
//  ViewModel.swift
//  RxSwiftSample
//
//  Created by Yoki Higashihara on 2018/10/14.
//  Copyright © 2018年 Yoki Higashihara. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

// ボタンの入力シーケンス
struct RxViewModelInput {
    // Observable は翻訳すると観測可能という意味で文字どおり観測可能なものを表現するクラス
    let countUpButton: Observable<Void>
    let countDownButton: Observable<Void>
    let countResetButton: Observable<Void>
}

class ViewModel: RxViewModelType{
    var outputs: RxViewModelOutput?
    
    private let countRelay = BehaviorRelay<Int>(value: 0)
    private let initialCount = 0
    private let disposeBag = DisposeBag()
    
    required init(input: RxViewModelInput) {
        self.outputs = self
        resetCount()
        input.countUpButton
            .subscribe(onNext: { [weak self] in
                self?.incrementCount()
            })
            .disposed(by: disposeBag)
        input.countDownButton
            .subscribe(onNext: { [weak self] in
                self?.decrementCount()
            })
            .disposed(by: disposeBag)
        input.countResetButton
            .subscribe(onNext: { [weak self] in
                self?.resetCount()
            })
            .disposed(by: disposeBag)
    }
    
    private func incrementCount() {
        let count = countRelay.value + 1
        countRelay.accept(count)
    }
    
    private func decrementCount() {
        let count = countRelay.value - 1
        countRelay.accept(count)
    }
    
    private func resetCount() {
        countRelay.accept(initialCount)
    }
}

extension ViewModel: RxViewModelOutput {
    var counterText: SharedSequence<DriverSharingStrategy, String> {
        let counterText = countRelay
        .map {
                "Rxパターン: \($0)"
        }
        .asDriver(onErrorJustReturn: "")
        return counterText
    }
}
