//
//  UIControl+Rx.swift
//  Pods
//
//  Created by DragonCherry on 7/13/17.
//
//

import RxSwift
import RxCocoa

extension Reactive where Base: UIControl {
    
    public var isFirstResponder: ControlProperty<Bool> {
        
        func property<T, ControlType: UIControl>(_ control: ControlType, getter:  @escaping (ControlType) -> T, setter: @escaping (ControlType, T) -> ()) -> ControlProperty<T> {
            let values: Observable<T> = Observable.deferred { [weak control] in
                guard let existingSelf = control else {
                    return Observable.empty()
                }
                
                return (existingSelf as UIControl).rx.controlEvent([.editingDidBegin, .editingDidEnd, .editingDidEndOnExit])
                    .flatMap { _ in
                        return control.map { Observable.just(getter($0)) } ?? Observable.empty()
                    }
                    .startWith(getter(existingSelf))
            }
            return ControlProperty(values: values, valueSink: UIBindingObserver(UIElement: control) { control, value in
                setter(control, value)
            })
        }
        
        return property(
            self.base,
            getter: { control in
                control.isFirstResponder
            },
            setter: { control, value in
                if control.isFirstResponder != value {
                    _ = value ? control.becomeFirstResponder() : control.resignFirstResponder()
                }
            })
    }
}
