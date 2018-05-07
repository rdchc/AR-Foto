//
//  ViewController.swift
//  AR-Foto
//
//  Created by CCH on 4/5/2018.
//  Copyright © 2018年 CCH. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet weak var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
//        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        let scene = SCNScene()
        addCube(in: scene)
        
        // Set the scene to the view
        sceneView.scene = scene
        sceneView.automaticallyUpdatesLighting = true
        
        // Long press gesture recognizer
//        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.didTap(withGestureRecognizer:)))
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(ViewController.didLongPress(with:)))
        sceneView.addGestureRecognizer(longPressRecognizer)
    }
    
    @IBAction func add(_ sender: Any) {
        addCube(in: sceneView.scene)
    }
    
    @IBAction func takePhoto(_ sender: Any) {
        // Create a snapshot
        let snapshot = sceneView.snapshot()
        
        // Save to photo album
        UIImageWriteToSavedPhotosAlbum(snapshot, self, nil, nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    // Add a cube in the provided scene
    func addCube(in scene: SCNScene) {
        let box = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
        let material = SCNMaterial()
        material.name = "color"
        material.diffuse.contents = UIColor.green
        box.materials = [material]
        
        let boxNode = SCNNode(geometry: box)
        boxNode.name = "myBox"
        boxNode.position = SCNVector3Make(0, 0, -0.5)
        scene.rootNode.addChildNode(boxNode)
    }
    
    // MARK: Gesture recognizers
    @objc func didLongPress(with recognizer: UIGestureRecognizer) {
        let tapLocation = recognizer.location(in: sceneView)
        let hitTestResults = sceneView.hitTest(tapLocation)
        guard let node = hitTestResults.first?.node else { return }
//        print(node.name ?? "No name")
        
        node.removeFromParentNode()
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
