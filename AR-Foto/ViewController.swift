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

class ViewController: UIViewController {

    var isAdding: Bool = false
    @IBOutlet weak var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Set lightings
        configLighting(for: sceneView)
        
        // Create a new scene to the scene view
        let scene = SCNScene()
        sceneView.scene = scene
        
        // Double tap gesture recognizer
        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.doubleTapHandler(with:)))
        doubleTapRecognizer.numberOfTapsRequired = 2
        sceneView.addGestureRecognizer(doubleTapRecognizer)
    }
    
    @IBAction func add(_ sender: Any) {
        isAdding = true
        // Show planes
        sceneView.scene.rootNode.enumerateChildNodes {(node,_) in
            if node.name == "plane" {
                node.isHidden = false
            }
        }
        // Construct cube
//        let cube = buildCube(in: sceneView.scene)
        // Add gesture recognizer
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.singleTapHandler(with:)))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @IBAction func restart(_ sender: Any) {
        let configuration = self.sceneView.session.configuration!
        
        // Pause the session
        sceneView.session.pause()
        
        // Present confirmation dialog
        let dialog = UIAlertController(title: "Restart?", message: "This will clear all objects added.", preferredStyle: .alert)
        // Delete action
        dialog.addAction(UIAlertAction(title: "OK", style: .destructive, handler: { (_) in
            // Remove all nodes
            self.sceneView.scene.rootNode.enumerateChildNodes {(node,_) in
                if let name = node.name {
                    print("Deleting node " + name)
                }
                node.removeFromParentNode()
            }
            // Start the session again
            self.sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        }))
        // Cancel action
        dialog.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
            self.sceneView.session.run(configuration)
        }))
        present(dialog, animated: true, completion: nil)
    }
    
    @IBAction func takePhoto(_ sender: Any) {
        // Create a snapshot
        let snapshot = sceneView.snapshot()
        
        // Save to photo album
        UIImageWriteToSavedPhotosAlbum(snapshot, self, nil, nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpSceneView(for: sceneView)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
// ############################################################################################
    // MARK: - Self-defined functions
    
    // Set up a AR scene view
    func setUpSceneView(for view: ARSCNView) {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        view.session.run(configuration)
        
        view.delegate = self
        view.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
    }
    
    // Configure lighting issues
    func configLighting(for view: ARSCNView) {
        view.autoenablesDefaultLighting = true
        view.automaticallyUpdatesLighting = true
    }
    
    // Build a cube
    func buildCube(in scene: SCNScene) -> SCNNode {
        let box = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
        let material = SCNMaterial()
        material.name = "color"
        material.diffuse.contents = UIColor.green
        box.materials = [material]
        
        let boxNode = SCNNode(geometry: box)
        boxNode.name = "myBox"
        return boxNode
//        boxNode.position = SCNVector3Make(0, 0, -0.5)
//        scene.rootNode.addChildNode(boxNode)
    }
    
    
    // MARK: Gesture recognizers
    @objc func doubleTapHandler(with recognizer: UIGestureRecognizer) {
        print("Double tapped")
        
        let tapLocation = recognizer.location(in: sceneView)
        let hitTestResults = sceneView.hitTest(tapLocation)
        if let node = hitTestResults.first?.node {
            node.removeFromParentNode()
        }
    }

    @objc func singleTapHandler(with recognizer: UIGestureRecognizer) {
        print("Tapping")
        
        if isAdding {
            // 0. Disable adding
            isAdding = false
            
            // 1. Retrieve hit test results
            let tapLocation = recognizer.location(in: sceneView)
            let hitTestResults = sceneView.hitTest(tapLocation, types: .existingPlaneUsingExtent)
            
            // 2. Get target position
            guard let hitTestResult = hitTestResults.first else { return }
            let translation = hitTestResult.worldTransform.translation
            let x = translation.x
            let y = translation.y
            let z = translation.z
            
            // 3. Add object to the plane
            let objNode = buildCube(in: sceneView.scene)
            objNode.position = SCNVector3(x,y,z)
            sceneView.scene.rootNode.addChildNode(objNode)
            
            // 4. Hide planes
            sceneView.scene.rootNode.enumerateChildNodes {(node,_) in
                if node.name == "plane" {
                    node.isHidden = true
                }
            }
        }
    }
}

// ############################################################################################
    // MARK: - ARSCNViewDelegate
    extension ViewController: ARSCNViewDelegate {
        func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
            print("Adding plane")
            
            // 1. Get plane anchor
            guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
            
            // 2. Set up plane
            let width = CGFloat(planeAnchor.extent.x)
            let height = CGFloat(planeAnchor.extent.z)
            let plane = SCNPlane(width: width, height: height)
            
            // 3. Set plane color
            plane.materials.first?.diffuse.contents = UIColor.transparentLightBlue
            
            // 4. Bind plane to node
            let planeNode = SCNNode(geometry: plane)
            planeNode.name = "plane"
            let x = CGFloat(planeAnchor.center.x)
            let y = CGFloat(planeAnchor.center.y)
            let z = CGFloat(planeAnchor.center.z)
            planeNode.position = SCNVector3(x, y, z)
            planeNode.eulerAngles.x = -.pi / 2
            planeNode.isHidden = true
            
            // 5. Add plane node
            print("Adding plane")
            node.addChildNode(planeNode)
        }
        
        func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
            // 1. Get plane anchors and plane
            guard let planeAnchor = anchor as? ARPlaneAnchor,
            let planeNode = node.childNodes.first,
            let plane = planeNode.geometry as? SCNPlane
                else { return }
            
            // 2. Update plane width and depth
            let width = CGFloat(planeAnchor.extent.x)
            let depth = CGFloat(planeAnchor.extent.z)
            plane.width = width
            plane.height = depth
            
            // 3. Update plane node position
            let x = CGFloat(planeAnchor.center.x)
            let y = CGFloat(planeAnchor.center.y)
            let z = CGFloat(planeAnchor.center.z)
            planeNode.position = SCNVector3(x, y, z)
            print("Updating node")
        }
    }

// MARK: - Extensions
extension float4x4 {
    var translation: float3 {
        let translation = self.columns.3
        return float3(translation.x, translation.y, translation.z)
    }
}

extension UIColor {
    open class var transparentLightBlue: UIColor {
        return UIColor(red: 90/255, green: 200/255, blue: 250/255, alpha: 0.50)
    }
}
