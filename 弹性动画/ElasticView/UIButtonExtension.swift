//
//  UIButtonExtension.swift
//  防止按钮重复点击
//
//  Created by 呆仔～林枫 on 2018/7/11.
//  Copyright © 2018年 最怕追求不凡,最后依然碌碌无为 - Crazy_Lin. All rights reserved.
//

import Foundation
import UIKit

extension UIButton {
    
        private struct UIButtonObjectKeys {
            static var accpetEventInterval = "UIButtonObjectKeys.accpetEventInterval"
            static var acceptEventTime = "UIButtonObjectKeys.acceptEventTime"
        }
    // 设置的点击间隔
    var acceptEventInterval: TimeInterval {
        set {
            objc_setAssociatedObject(self,
                                     &UIButtonObjectKeys.accpetEventInterval,
                                     newValue,
                                     .OBJC_ASSOCIATION_RETAIN)
        }
        get {
            return (objc_getAssociatedObject(self,&UIButtonObjectKeys.accpetEventInterval) as? TimeInterval) ?? 0.75
        }
    }
    // 储存的上一次点击时间
    private var acceptEventTime: TimeInterval {
        set {
            objc_setAssociatedObject(self,
                                     &UIButtonObjectKeys.acceptEventTime,
                                     newValue, .OBJC_ASSOCIATION_RETAIN)
        }
        get {
            return (objc_getAssociatedObject(self, &UIButtonObjectKeys.acceptEventTime) as? TimeInterval) ?? 0.5
        }
    }
    open override func sendAction(_ action: Selector, to target: Any?, for event: UIEvent?) {
        // 如果这次点击时间减去上次点击事件小于设置的点击间隔，则不执行
        if Date().timeIntervalSince1970 - self.acceptEventTime < self.acceptEventInterval { return }
        // 存储最后一次点击执行的时间
        if self.acceptEventInterval > 0 {
            self.acceptEventTime = Date().timeIntervalSince1970
        }
        // 执行action
        super.sendAction(action, to: target, for: event) }
}
