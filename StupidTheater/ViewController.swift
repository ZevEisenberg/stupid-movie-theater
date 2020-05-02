//
//  ViewController.swift
//  StupidTheater
//
//  Created by Zev Eisenberg on 5/2/20.
//  Copyright © 2020 Zev Eisenberg. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController {

    @IBOutlet var sceneView: ARSCNView!

    private let playAudioWhileMuted = true

    private let audioFileNames = [
        "Popcorn",
        "Candy",
        "Straw",
        "down-in-front",
    ]

    private var nextSoundEffect = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
//        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/Theater.scn")!
        
        // Set the scene to the view
        sceneView.scene = scene

        setUpVideoNode()

        if playAudioWhileMuted {
            do {
                try AVAudioSession.sharedInstance().setCategory(.playback)
            }
            catch {
                print("Error setting playback category: \(error)")
            }
        }

        sceneView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(screenTapped(_:))))
    }

    // Adapted from https://gist.github.com/glaurent/aad82c4185f3c92f21dc
    func setUpVideoNode() {
        let skScene = SKScene(size: CGSize(width: 1920, height: 1080))
        let avPlayer = AVPlayer(url: Bundle.main.url(forResource: "charade_meeting", withExtension: "mp4")!)
        avPlayer.volume = 0.1
        let videoSKNode = SKVideoNode(avPlayer: avPlayer)
        skScene.scaleMode = .aspectFit
        videoSKNode.position = CGPoint(x: skScene.size.width / 2, y: skScene.size.height / 2)
        videoSKNode.size = skScene.size
        skScene.addChild(videoSKNode)

        let screenNode = sceneView.scene.rootNode.childNode(withName: "screen", recursively: true)!
        screenNode.geometry?.firstMaterial?.emission.contents = skScene
        screenNode.geometry?.firstMaterial?.emission.intensity = 1

        // flip video upside down, so that it's shown in the right position
        videoSKNode.yScale = -1

        videoSKNode.play()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.isLightEstimationEnabled = false

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
}

private extension ViewController {

    @objc func screenTapped(_ sender: UITapGestureRecognizer) {
        let effectName = audioFileNames[nextSoundEffect]
        nextSoundEffect += 1
        if nextSoundEffect >= audioFileNames.endIndex {
            nextSoundEffect = 0
        }
        let audioNode = sceneView.scene.rootNode.childNode(withName: effectName, recursively: true)!
        let audioSource = SCNAudioSource(fileNamed: effectName + ".mp3")!
        let audioPlayer = SCNAudioPlayer(source: audioSource)

        audioNode.addAudioPlayer(audioPlayer)

        let play = SCNAction.playAudio(audioSource, waitForCompletion: true)
        audioNode.runAction(play)
    }

}

extension ViewController: ARSCNViewDelegate {
    
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
