//
//  ViewController.swift
//  MIMetal
//
//  Created by 影子 on 2019/9/23.
//  Copyright © 2019 zsr. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var scene: MIMetalScene!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        scene = MIMetalScene.init(frame: self.view.bounds)
        
        let node = MIObject.init(mdlMesh: MIModelCreater.box(length: 3, width: 3, height: 3))
        
        
        scene.rootNode.addChildNode(node)
        scene.controlNode = node
        
        node.material?.setTexture(cgImage: #imageLiteral(resourceName: "image_test.jpeg").cgImage!)
        
        self.view.addSubview(scene.view)
        
    }


}

