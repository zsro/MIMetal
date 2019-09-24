//
//  MIAction.swift
//  Mirage3D
//
//  Created by 影子 on 2018/12/18.
//  Copyright © 2018 影子. All rights reserved.
//

import Foundation
import simd

public protocol MIActionable : NSObjectProtocol{
    
    func runAction(_ action: MIAction)
    
    func runAction(_ action: MIAction, completionHandler block: (() -> Void)?)
    
    func runAction(_ action: MIAction, forKey key: String?)
    
    func runAction(_ action: MIAction, forKey key: String?, completionHandler block: (() -> Void)?)
    
    func action(forKey key: String) -> MIAction?
    
    func removeAction(forKey key: String)
    
    func removeAllActions()
    
    var hasActions: Bool { get }
    
    var actionKeys: [String] { get }
}
enum MIActionType {
    case move
    case rotate
    case scale
}
public class MIAction : NSObject{
    
  
    
    var name: String
    let type: MIActionType
    /** 持续时间 **/
    private var duration: TimeInterval = 0.0
    var spendTime: TimeInterval = 0.0
    /** 变化模式 **/
    var timeingMode: MIActionTimingMode = .linear
    /** callback **/
    var timingFunction: ((MINode?, TimeInterval)->Void)?
    /** 速度 **/
    var speed: Float = 1.0
    
    
    private var _isFinish: Bool = false
    var isFinish: Bool {
        return _isFinish
    }
    

    private init(duration: TimeInterval, type: MIActionType){
        self.type = type
        name = "\(CFAbsoluteTimeGetCurrent())"
        self.duration = duration
        super.init()
    }
    /// 获取进度
    ///
    /// - Returns: 0.0 - 1.0
    private func getProgress() -> Float {
        if duration == 0.0{
            return 1
        }
        
        if spendTime >= duration{
            return 1
        }
        
        let x = Float(spendTime / duration)
        return x
    }

    class func moveBy(x: Float, y: Float, z: Float, duration: TimeInterval) -> MIAction{
        let action = MIAction.init(duration: duration, type: .move)
        let block: ((MINode?, TimeInterval)->Void) = { (node, daltaTime) in
            guard let node = node else {
                return
            }
            node.position = action.getLerpValue(startPoint: node.position,
                                                endPoint: float3.init(x, y, z),
                                                daltaTime: daltaTime)
        }
        action.timingFunction = block
        return action
    }
    
    class func moveBy(_ destination: float3, duration: TimeInterval) -> MIAction{
        let action = MIAction.init(duration: duration, type: .move)
        let block: ((MINode?, TimeInterval)->Void) = { (node, daltaTime) in
            guard let node = node else {
                return
            }
            node.position = action.getLerpValue(startPoint: node.position,
                                                endPoint: destination,
                                                daltaTime: daltaTime)
        }
        action.timingFunction = block
        return action
    }
    
    class func rotateBy(x: Float, y: Float, z: Float, duration: TimeInterval) -> MIAction{
        let action = MIAction.init(duration: duration, type: .rotate)
        
        let block: ((MINode?, TimeInterval)->Void) = { (node, daltaTime) in
            guard let node = node else {
                return
            }
            node.rotate = action.getLerpValue(startPoint: node.rotate,
                                              endPoint: float3.init(x, y, z),
                                              daltaTime: daltaTime)
        }
        
        action.timingFunction = block
        
        return action
        
    }
    
    class func scaleBy(x: Float, y: Float, z: Float, duration: TimeInterval) -> MIAction{
        let action = MIAction.init(duration: duration, type: .scale)
        
        let block: ((MINode?, TimeInterval)->Void) = { (node, daltaTime) in
            guard let node = node else {
                return
            }
            node.scale = action.getLerpValue(startPoint: node.scale,
                                              endPoint: float3.init(x, y, z),
                                              daltaTime: daltaTime)
        }
        
        action.timingFunction = block
        
        return action
        
    }
    
    private func getLerpValue(startPoint: float3, endPoint: float3, daltaTime: Double) -> float3 {
        let progress = getProgress()
        
        let l = (endPoint - startPoint) / (1 - progress) * Float(daltaTime / duration)
        let result = startPoint + l
        spendTime += daltaTime
        
        if spendTime >= duration{
            _isFinish = true
            return endPoint
        }
        
        return result
    }

    
}



public enum MIActionTimingMode: Int{
    case linear
    
    case easeIn
    
    case easeOut
    
    case easeInEaseOut
}
