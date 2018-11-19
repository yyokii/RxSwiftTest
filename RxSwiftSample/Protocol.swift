//
//  Protocol.swift
//  RxSwiftSample
//
//  Created by Yoki Higashihara on 2018/10/14.
//  Copyright © 2018年 Yoki Higashihara. All rights reserved.
//

import Foundation
import RxCocoa

// ViewController に監視させる対象を定義
protocol RxViewModelOutput {
    // https://qiita.com/yuzushioh/items/0a4483502c5c8569790a
    var counterText: Driver<String> { get }
}
// ViewModel に継承させる protocol を定義
protocol RxViewModelType {
    var outputs: RxViewModelOutput? { get }
    init(input: RxViewModelInput)
}
