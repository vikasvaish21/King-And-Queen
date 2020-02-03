//
//  ViewController.swift
//  Valentine'sDaySpecial
//
//  Created by vikas on 31/01/20.
//  Copyright © 2020 VikasWorld. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var heartNode: SCNNode?
    var rubyNode: SCNNode?
    var imageNodes = [SCNNode]()
    var isJumping = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
       sceneView.autoenablesDefaultLighting = true
        let heartScene = SCNScene(named:"art.scnassets/heart.scn")
        let rubyScene = SCNScene(named: "art.scnassets/Ruby.scn")
        heartNode = heartScene?.rootNode
        rubyNode = rubyScene?.rootNode
       
        // Show statistics such as fps and timing information
         //sceneView.showsStatistics = true
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARImageTrackingConfiguration()
        if let trackingImages = ARReferenceImage.referenceImages(inGroupNamed: "Playing Cards", bundle: Bundle.main){
            configuration.trackingImages = trackingImages
            configuration.maximumNumberOfTrackedImages = 2
        }
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
        
        if let imageAnchor = anchor as? ARImageAnchor{
            let size = imageAnchor.referenceImage.physicalSize
            let plane = SCNPlane(width: size.width, height: size.height)
            plane.firstMaterial?.diffuse.contents = UIColor.white.withAlphaComponent(0.5)
            plane.cornerRadius = 0.005
            let planeNode = SCNNode(geometry: plane)
            planeNode.eulerAngles.x = -.pi / 2
            node.addChildNode(planeNode)
            
           var shapeNode: SCNNode?
            switch imageAnchor.referenceImage.name {
            case CardType.King.rawValue:
                shapeNode = heartNode
            case CardType.Queen.rawValue:
                shapeNode = rubyNode
            default:
                break
            }
            let shapeSpin = SCNAction.rotateBy(x: 0, y: 2 * .pi, z: 0, duration: 10)
            let repeatSpin = SCNAction.repeatForever(shapeSpin)
            shapeNode?.runAction(repeatSpin)
            guard let shape = shapeNode else {
                return nil
            }
           // shapeNode?.addChildNode(shape)
            node.addChildNode(shape)
            imageNodes.append(node)
            return node
        }
        return nil
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        if imageNodes.count == 2{
            let positionOne = SCNVector3ToGLKVector3(imageNodes[0].position)
            let positionTwo = SCNVector3ToGLKVector3(imageNodes[1].position)
            let distance = GLKVector3Distance(positionOne, positionTwo)
            if distance < 0.20 {
                spinJump(node: imageNodes[0])
                spinJump(node: imageNodes[1])
                isJumping = true
            } else{
                isJumping = false
            }
        }
    }
    func spinJump(node: SCNNode){
        if isJumping{
            return
        }
        let shapeNode = node.childNodes[1]
        let shapeSpin = SCNAction.rotateBy(x: 0, y: 2 * .pi, z: 0, duration: 1)
        shapeSpin.timingMode = .easeInEaseOut
        let up = SCNAction.moveBy(x:0, y:0.06,z:0,duration:0.5)
        up.timingMode = .easeInEaseOut
        let down = up.reversed()
        let upDown = SCNAction.sequence([up, down])
        shapeNode.runAction(shapeSpin)
        shapeNode.runAction(upDown)
    }
    
    enum CardType: String{
        case King = "King"
        case Queen = "Queen"
    }
}
