//
//  AdditionWrapper.swift
//  gpu-vector-addition-with-metal-and-swift
//
//  Created by Julian Lork on 02.09.23.
//

import Foundation
import Metal

class GPUAddition {
    
    let STORAGE_MODE: MTLResourceOptions = .storageModeShared
    
    let device: MTLDevice
    let commandQueue: MTLCommandQueue
    let pipelineState: MTLComputePipelineState
    
    let bufferSummandA: MTLBuffer
    let bufferSummandB: MTLBuffer
    let bufferResult: MTLBuffer
    let arrayLength: Int
    
    init(summandA: [Float], summandB: [Float]) {
        
        precondition(summandA.count == summandB.count, "Array length of summand A and B must match.")
        
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("No metal compatible device could be found.")
        }
        
        guard let commandQueue = device.makeCommandQueue() else {
            fatalError("\(device) failed to create a command queue.")
        }
        
        guard let pipelineState = GPUAddition.makeComputerPipelineState(device: device) else {
            fatalError("\(device) failed to create the compute pipeline state.")
        }
        
        guard let bufferSummandA = device.makeBuffer(bytes: summandA, length: MemoryLayout<Float>.stride * summandA.count, options: STORAGE_MODE) else {
            fatalError("\(device) failed to create the buffer for summandA.")
        }
        
        guard let bufferSummandB = device.makeBuffer(bytes: summandB, length: MemoryLayout<Float>.stride * summandB.count, options: STORAGE_MODE) else {
            fatalError("\(device) failed to create the buffer for summandB.")
        }
        
        guard let bufferResult = device.makeBuffer(length: MemoryLayout<Float>.stride * summandB.count, options: STORAGE_MODE) else {
            fatalError("\(device) failed to create the buffer for result.")
        }
        
        self.device = device
        self.commandQueue = commandQueue
        self.pipelineState = pipelineState
        self.bufferSummandA = bufferSummandA
        self.bufferSummandB = bufferSummandB
        self.bufferResult = bufferResult
        self.arrayLength = summandA.count
        
    }
    
}

extension GPUAddition {
    
    static let COMPUTE_FCN: String = "sum_of_arrays"
    
    
    class func makeComputerPipelineState(device: MTLDevice) -> MTLComputePipelineState? {
        
        guard let library = device.makeDefaultLibrary() else {
            fatalError("\(device) failed to make the default library.")
        }
        
        guard let computeFcn = library.makeFunction(name: COMPUTE_FCN) else {
            fatalError("Library failed to find the function \(COMPUTE_FCN)")
        }
        
        do {
            return try device.makeComputePipelineState(function: computeFcn)
        } catch {
            return nil
        }
    }
}


