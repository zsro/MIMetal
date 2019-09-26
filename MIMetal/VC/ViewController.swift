//
//  ViewController.swift
//  MIMetal
//
//  Created by 影子 on 2019/9/23.
//  Copyright © 2019 zsr. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController {
    
    var scene: MIMetalScene!
    var session: ARSession!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        scene = MIMetalScene.init(frame: self.view.bounds)
        let node = MIObject.init(mdlMesh: MIModelCreater.box(length: 3, width: 3, height: 3))
        scene.rootNode.addChildNode(node)
        scene.controlNode = node
        node.material?.setTexture(cgImage: #imageLiteral(resourceName: "image_test.jpeg").cgImage!)
        
        self.view.addSubview(scene.view)
        
        session = ARSession()
        session.delegate = self
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        session.run(configuration, options: ARSession.RunOptions.resetTracking)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        session.pause()
    }


}

extension ViewController: ARSessionDelegate{
    
    func sessionWasInterrupted(_ session: ARSession) {
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        print("111111")
    }
    
    ///anchors add
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        
    }
    
    ///会话报错时调用
    func session(_ session: ARSession, didFailWithError error: Error) {
        print("Error: 错误 错误 错误 ===== \(error.localizedDescription)")
    }
    
    ///anchors remove
    func session(_ session: ARSession, didRemove anchors: [ARAnchor]) {
        
    }
    
    ///anchors update
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        
    }
    
    /// 相机追踪状态改变时调用
    ///
    /// - Parameters:
    ///   - camera: 相机
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        print(camera.trackingState)
    }
    
    /// 会话从中断或暂停中恢复后，将调用此方法已确定是否重新尝试定位
    ///
    /// - Parameter:
    /// - Returns: true 开始重新定位
    func sessionShouldAttemptRelocalization(_ session: ARSession) -> Bool {
        return true
    }
    
    /// 当会话输出新的音频样本缓冲区时，将调用此方法。
    ///
    /// - Parameters:
    ///   - audioSampleBuffer: 捕获的音频样本缓冲区
    func session(_ session: ARSession, didOutputAudioSampleBuffer audioSampleBuffer: CMSampleBuffer) {
        
    }
    
}

