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
    
    public var responder: Driver<Int> {
        let drivers = flatMap { $0.rx.isFirstResponder.asDriver() }
        return Driver.combineLatest(drivers) { $0.index(of: true) ?? -1 }
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
        guard let responder = firstResponder(), responder.index > 0 else { return nil }
        
        for previousIndex in (0..<(responder.index - 1)).reversed() {
            guard previousIndex >= 0 else { break }
            if set(leaving: responder.control, arriving: self[previousIndex], disabling: disabling, enabling: enabling) {
                return previousIndex
            } else {
                continue
            }
        }
        return nil
    }
    
    @discardableResult
    public func moveToNextResponder(disabling: Bool = false, enabling: Bool = false) -> Int? {
        guard let responder = firstResponder(), responder.index + 1 < count else { return nil }
        
        for nextIndex in (responder.index + 1)..<count {
            guard nextIndex < count else { break }
            if set(leaving: responder.control, arriving: self[nextIndex], disabling: disabling, enabling: enabling) {
                return nextIndex
            } else {
                continue
            }
        }
        return nil
    }
    
    @discardableResult
    fileprivate func set(leaving: UIControl, arriving: UIControl, disabling: Bool, enabling: Bool) -> Bool {
        if disabling {
            leaving.isEnabled = false
        }
        var isArrived = false
        if enabling {
            if !arriving.isEnabled {
                arriving.isEnabled = true
                isArrived = true
            }
        } else {
            if !arriving.isEnabled {
                return false
            }
        }
        return isArrived && arriving.becomeFirstResponder()
    }
}
