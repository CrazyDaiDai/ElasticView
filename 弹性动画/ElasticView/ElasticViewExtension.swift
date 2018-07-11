//
//  ElasticViewExtension.swift
//  弹性动画
//
//  Created by 呆仔～林枫 on 2018/7/11.
//  Copyright © 2018年 最怕追求不凡,最后依然碌碌无为 - Crazy_Lin. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    private struct AssociatedKeys {
        static var descriptiveName = "AssociatedKeys.descriptiveName.elasticView"
    }
    
    private (set) var elasticView: ElasticView {
        get {
            if let elasticView = objc_getAssociatedObject(
                self,
                &AssociatedKeys.descriptiveName
                ) as? ElasticView {
                return elasticView
            }
            self.elasticView = ElasticView(to: self)
            if UIDevice.current.modelName == "Simulator" {
                Thread.sleep(forTimeInterval: 0.06)                
            }
            return self.elasticView
        }
        set(elasticView) {
            objc_setAssociatedObject(
                self,
                &AssociatedKeys.descriptiveName,
                elasticView,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }
    
    class ElasticView {
        private var superview: UIView
        /// 顶部控制点
        private let topControlPointView = UIView()
        /// 左边控制点
        private let leftControlPointView = UIView()
        /// 底部控制点
        private let bottomControlPointView = UIView()
        /// 右边控制点
        private let rightControlPointView = UIView()
        /// 弹性 Layer
        private let elasticShape = CAShapeLayer()
        
        
        init(to view: UIView) {
            self.superview = view
            
            setupComponents()
            positionControlPoints()
        }
        
        private func setupComponents()
        {
            elasticShape.fillColor = superview.backgroundColor?.cgColor
            superview.backgroundColor = UIColor.clear
            superview.clipsToBounds = false
            elasticShape.path = UIBezierPath(rect: superview.bounds).cgPath
            superview.layer.addSublayer(elasticShape)
            
            let views = [topControlPointView,leftControlPointView,bottomControlPointView,rightControlPointView]
            for controlPoint in views {
                superview.addSubview(controlPoint)
                controlPoint.frame = CGRect(x: 0.0, y: 0.0, width: 5.0, height: 5.0)
                //                controlPoint.backgroundColor = UIColor.yellow
            }
        }
        
        /// 调用此方法开始动画
        func startUpdateLoop()
        {
            displayLink.isPaused = false
            animateControlPoints()
        }
        
        @objc func updateLoop()
        {
            elasticShape.path = bezierPathForControlPoints()
        }
        
        private func animateControlPoints()
        {
            /* 控制点移动的偏移量 */
            let overshootAmount : CGFloat = -20.0
            /* 在 spring animation 动画中 Block 块包含的即将到来的 UI 变化将会持续0.25秒.
             通过多次修改填写这两个变量的数值来找到我们要的动画效果是很正常的 */
            UIView.animate(withDuration: 0.25, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 1.5, options: .curveEaseInOut, animations: {
                /* 上下左右移动控制点,将会产生动画 */
                self.topControlPointView.center.y -= overshootAmount
                self.leftControlPointView.center.x -= overshootAmount
                self.bottomControlPointView.center.y += overshootAmount
                self.rightControlPointView.center.x += overshootAmount
            }) { (_) in
                /* 创建另一个 spring animation 动画使视图还原 */
                UIView.animate(withDuration: 0.45, delay: 0.0, usingSpringWithDamping: 0.15, initialSpringVelocity: 5.5, options: .curveEaseInOut, animations: {
                    /* 重置控制点的位置——这也是一个动画 */
                    self.positionControlPoints()
                }, completion: { (_) in
                    /* 动画结束的时候暂停 displaylink 更新 */
                    self.stopUpdateLoop()
                })
            }
        }
        
        private func stopUpdateLoop()
        {
            displayLink.isPaused  = true
        }
        
        private func positionControlPoints()
        {
            topControlPointView.center = CGPoint(x: superview.bounds.midX, y: 0.0)
            leftControlPointView.center = CGPoint(x: 0.0, y: superview.bounds.midY)
            bottomControlPointView.center = CGPoint(x:superview.bounds.midX, y: superview.bounds.maxY)
            rightControlPointView.center = CGPoint(x: superview.bounds.maxX, y: superview.bounds.midY)
        }
        
        private func bezierPathForControlPoints() -> CGPath
        {
            // 创建一个 UIBezierPath 类对象来保存图形
            let path = UIBezierPath()
            // 提取4个控制点的位置,分别为 top left bottom right 四个常量
            let top = topControlPointView.layer.presentation()?.position
            let left = leftControlPointView.layer.presentation()?.position
            let bottom = bottomControlPointView.layer.presentation()?.position
            let right = rightControlPointView.layer.presentation()?.position
            
            let width = superview.frame.size.width
            let height = superview.frame.size.height
            // 通过长方形的顶点和4个控制点,绘制曲线,来创建路径
            path.move(to: CGPoint(x: 0, y: 0))
            path.addQuadCurve(to: CGPoint(x: width, y: 0), controlPoint: top!)
            path.addQuadCurve(to: CGPoint(x: width, y: height), controlPoint: right!)
            path.addQuadCurve(to: CGPoint(x: 0, y: height), controlPoint: bottom!)
            path.addQuadCurve(to: CGPoint(x: 0, y: 0), controlPoint: left!)
            // 返回路径,这就是我们期望的图层形状
            return path.cgPath
        }
        
        private lazy var displayLink: CADisplayLink = {
            let displayLink = CADisplayLink(target: self, selector: #selector(updateLoop))
            displayLink.add(to: .current, forMode: .commonModes)
            return displayLink
        }()
    }
}
