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
    init(metalView: MTKView){
        guard let device = MTLCreateSystemDefaultDevice(),
              let commandQueue = device.makeCommandQueue() else{
            fatalError("GPU not available")
        }
        Renderer.device = device
        Renderer.commandQueue = commandQueue
        metalView.device = device
        let allocator = MTKMeshBufferAllocator(device: device)
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
        
        //this will be the NDC coords we use to draw the dot
        //vertices = [[float3(0.0, 0.0, 0.5)]]
        
        
        
        //create a buffer on the gpu and fill with data??
         originalBuffer = Renderer.device.makeBuffer(bytes: &vertices, length: MemoryLayout<float3>.stride * vertices.count, options: [])
        
        //vertices[0] += [float3(0.3, -0.4, 0.5)]
        
        
//        vertices = vertices.map{
//            let vertex = matrix * float4($0, 1)
//            return [vertex.x, vertex.y, vertex.z]
//        }
        //vertices[0] += [0.3, -0.4, 0.5]
        transformedBuffer = device.makeBuffer(bytes: &vertices, length: MemoryLayout<float3>.stride * vertices.count, options: [])
        
        
        
        
        
        //if we don't do this we won't hit our render loop below
        metalView.delegate = self
    }
    var originalBuffer: MTLBuffer!
    var transformedBuffer: MTLBuffer!
    var vertices:[float3] = [float3(0.0, 0.0, 0.5)]
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
        matrix1.columns.3 = [-0.3, 0.4, 0.0, 1.0]
        
        var matrix2 = matrix_identity_float4x4
        matrix2.columns.3 = [0.3, -0.4, 0, 1]
        
        //we setup the pipeline state in init, telling us what shaders to use and
        //and vertex descriptor format for the vertex shader
        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setVertexBytes(&matrix1, length: MemoryLayout<float4x4>.stride, index: 1)
        //set the buffer with the actual data, ie vertices of the train model
        renderEncoder.setVertexBuffer(originalBuffer, offset: 0, index: 0)
        //set first argument of fragment shader to green color
        var greenColor: [float4] = [[0.0, 1.0, 0.0, 1.0]]
        renderEncoder.setFragmentBytes(&greenColor, length: MemoryLayout<float4>.stride, index: 0)
        
        //draw the point at index 0 and count = 1 at this point because we have an array of float3's
        renderEncoder.drawPrimitives(type: .point, vertexStart: 0, vertexCount: vertices.count)
        
        renderEncoder.setVertexBytes(&matrix2, length: MemoryLayout<float4x4>.stride, index: 1)
        renderEncoder.setVertexBuffer(transformedBuffer, offset: 0, index: 0)
        var redColor:float4 = float4(1.0, 0.0, 0.0, 1.0)
        renderEncoder.setFragmentBytes(&redColor, length: MemoryLayout<float4>.stride, index: 0)
        renderEncoder.drawPrimitives(type: .point, vertexStart: 0, vertexCount: vertices.count)
        //we're done drawing with this encoder, can we do more draw commands with this single renderEncoder??
        renderEncoder.endEncoding()
        guard let drawable = view.currentDrawable else {
            return
        }
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
