//
//  UIControl+Ext.swift
//  Pods
//
//  Created by DragonCherry on 8/7/17.
//
//

import RxSwift
import RxCocoa

extension Reactive where Base: UIButton {
    public var title: UIBindingObserver<Base, String> {
        return UIBindingObserver(UIElement: base) { view, text in
            view.setTitle(text, for: .normal)
        }
    }
}
