//
//  Renderer.swift
//  DgdChapter4
//
//  Created by David Dvergsten on 11/25/20.
//

import Foundation
import MetalKit

class Renderer: NSObject {
    static var device: MTLDevice!
    static var commandQueue: MTLCommandQueue!
    var pipelineState: MTLRenderPipelineState!
    var uniforms = Uniforms()
    init(metalView: MTKView){
        guard let device = MTLCreateSystemDefaultDevice(),
              let commandQueue = device.makeCommandQueue() else{
            fatalError("GPU not available")
        }
        Renderer.device = device
        Renderer.commandQueue = commandQueue
        metalView.device = device
        
        let vertexDescriptor2 = MTLVertexDescriptor()
        vertexDescriptor2.attributes[0].format = .float3
        vertexDescriptor2.attributes[0].offset = 0
        vertexDescriptor2.attributes[0].bufferIndex = 0
        
        //the stride of a vec3 of floats, xyz of position point we will send to vertexshader
        vertexDescriptor2.layouts[0].stride = MemoryLayout<SIMD3<Float>>.stride
        
        let library = device.makeDefaultLibrary()
        let vertexFunction = library?.makeFunction(name: "vertex_main")
        let fragmentFunction = library?.makeFunction(name: "fragment_main")
        
        //setup the pipeline so it knows how to act on the data we give it
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        
        //tells the pipeline where in the buffer the vertex data starts, stride etc of vertex
        //position data
        pipelineDescriptor.vertexDescriptor = vertexDescriptor2
        
        //is this rgb8 rgba etc, apparently the view defines this for us which the viewcontroller gives us
        pipelineDescriptor.colorAttachments[0].pixelFormat = metalView.colorPixelFormat
        do{
            pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        }
        catch let error {
            fatalError(error.localizedDescription)
        }
        
        super.init()
        
        metalView.clearColor = MTLClearColor(red: 1.0, green: 1.0, blue: 0.8, alpha: 1.0)
        
        
        //create a buffer on the gpu and fill with data??
         originalBuffer = Renderer.device.makeBuffer(bytes: &vertices, length: MemoryLayout<float3>.stride * vertices.count, options: [])
        
        //if we don't do this we won't hit our render loop below
        metalView.delegate = self
        
        let translation = float4x4(translation: [0, 0.3, 0])
        
        let rotation = float4x4(rotation: [0, 0, Float(45).degreesToRadians])
        uniforms.modelMatrix = translation * rotation
    }
    var angle:Float = 90.0
    var originalBuffer: MTLBuffer!
    var transformedBuffer: MTLBuffer!
    var vertices:[float3] = [
        [-0.7, 0.8, 1],
        [-0.7, -0.4, 1],
        [0.4, 0.2, 1]
    ]
}

extension Renderer: MTKViewDelegate{
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize){
        print("window size changed")
    }
    func draw(in view: MTKView) {
        guard let descriptor = view.currentRenderPassDescriptor,
              let commandBuffer = Renderer.commandQueue.makeCommandBuffer(),
              let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor)
        else {
            return
        }
        
        var matrix1 = matrix_identity_float4x4
        
        angle += 0.1
        //matrix1.columns.0 = [cos(angle), -sin(angle), 0, 0]
       // matrix1.columns.1 = [sin(angle), cos(angle), 0, 0]
        var distanceVector = float4(vertices.last!.x,
                                    vertices.last!.y,
                                    vertices.last!.z, 1)
        let translation = float4x4(translation: [0, 0.3, 0])
        
        let rotation = float4x4(rotation: [0, 0, Float(angle).degreesToRadians])
        uniforms.modelMatrix = translation * rotation
        
        var translate = matrix_identity_float4x4
        translate.columns.3 = distanceVector
        var rotate = matrix_identity_float4x4
        rotate.columns.0 = [cos(angle), -sin(angle), 0, 0]
        rotate.columns.1 = [sin(angle), cos(angle), 0, 0]
        
        matrix1 = translate * rotate * translate.inverse
        
        //we setup the pipeline state in init, telling us what shaders to use and
        //and vertex descriptor format for the vertex shader
        renderEncoder.setRenderPipelineState(pipelineState)
        //renderEncoder.setVertexBytes(&matrix1, length: MemoryLayout<float4x4>.stride, index: 1)
        renderEncoder.setVertexBytes(&uniforms, length: MemoryLayout<Uniforms>.stride, index: 1)
        //set the buffer with the actual data, ie vertices of the train model
        renderEncoder.setVertexBuffer(originalBuffer, offset: 0, index: 0)
        //set first argument of fragment shader to green color
        var greenColor: [float4] = [[0.0, 1.0, 0.0, 1.0]]
        renderEncoder.setFragmentBytes(&greenColor, length: MemoryLayout<float4>.stride, index: 0)
        
        //draw the point at index 0 and count = 1 at this point because we have an array of float3's
        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertices.count)
        
        //we're done drawing with this encoder, can we do more draw commands with this single renderEncoder??
        renderEncoder.endEncoding()
        guard let drawable = view.currentDrawable else {
            return
        }
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
