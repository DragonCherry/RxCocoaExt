//
//  Array+Control.swift
//  Pods
//
//  Created by DragonCherry on 7/13/17.
//
//

import RxSwift
import RxCocoa

extension Array where Element: UIControl {
    
    public var responder: Driver<(index: Int, control: UIControl)?> {
        let drivers = flatMap { $0.rx.isFirstResponder.asDriver() }
        return Driver.combineLatest(drivers) { $0.index(of: true) }
            .map { index -> (index: Int, control: UIControl)? in
                if let index = index {
                    return (index, self[index])
                } else {
                    return nil
                }
            }
            .asDriver()
    }
}

extension Array where Element: UIControl {
    
    public func previousResponder(enabling: Bool = false) -> (index: Int, control: UIControl)? {
        guard let responder = firstResponder(), responder.index > 0 else { return nil }
        for previousIndex in (0..<responder.index).reversed() {
            guard previousIndex >= 0 else { break }
            if !enabling && !self[previousIndex].isEnabled { continue }
            return (previousIndex, self[previousIndex])
        }
        return nil
    }
    
    public func firstResponder() -> (index: Int, control: UIControl)? {
        for i in 0..<count {
            if self[i].isFirstResponder { return (i, self[i]) }
        }
        return nil
    }
    
    public func nextResponder(enabling: Bool = false) -> (index: Int, control: UIControl)? {
        guard let responder = firstResponder(), responder.index + 1 < count else { return nil }
        for nextIndex in (responder.index + 1)..<count {
            guard nextIndex < count else { break }
            if !enabling && !self[nextIndex].isEnabled { continue }
            return (nextIndex, self[nextIndex])
        }
        return nil
    }
    
    @discardableResult
    public func moveToPreviousResponder(disabling: Bool = false, enabling: Bool = false) -> Int? {
        guard let responder = firstResponder(), let previousResponder = previousResponder(enabling: enabling) else { return nil }
        return set(leaving: responder.control, arriving: previousResponder.control, disabling: disabling, enabling: enabling) ? previousResponder.index : nil
    }
    
    @discardableResult
    public func moveToNextResponder(disabling: Bool = false, enabling: Bool = false) -> Int? {
        guard let responder = firstResponder(), let nextResponder = nextResponder(enabling: enabling) else { return nil }
        return set(leaving: responder.control, arriving: nextResponder.control, disabling: disabling, enabling: enabling) ? nextResponder.index : nil
    }
    
    @discardableResult
    fileprivate func set(leaving: UIControl, arriving: UIControl, disabling: Bool, enabling: Bool) -> Bool {
        if disabling {
            leaving.isEnabled = false
        }
        var isArrived = true
        if enabling {
            if !arriving.isEnabled {
                arriving.isEnabled = true
            }
        } else {
            isArrived = arriving.isEnabled
        }
        return isArrived && arriving.becomeFirstResponder()
    }
}
