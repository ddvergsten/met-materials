//
//  ViewController.swift
//  DgdChapter4
//
//  Created by David Dvergsten on 11/25/20.
//

import Cocoa
import MetalKit

class ViewController: NSViewController {

    var renderer: Renderer?
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let metalView = view as? MTKView else {
            fatalError("metal view not set up in storyboard")
        }
        renderer = Renderer(metalView: metalView)
        
        //var renderer:Renderer  = Renderer()
        //renderer.init(
        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

