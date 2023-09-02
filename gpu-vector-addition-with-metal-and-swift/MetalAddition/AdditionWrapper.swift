//
//  AdditionWrapper.swift
//  gpu-vector-addition-with-metal-and-swift
//
//  Created by Julian Lork on 02.09.23.
//

import Foundation
import Metal

class GPUAddition {
    
    private let STORAGE_MODE: MTLResourceOptions = MTLResourceOptions.storageModeShared
    
    private let device: MTLDevice
    private let commandQueue: MTLCommandQueue
    private let pipelineState: MTLComputePipelineState
    
    private let bufferSummandA: MTLBuffer
    private let bufferSummandB: MTLBuffer
    private let bufferResult: MTLBuffer
    private let arrayLength: Int
    
    init(_ summandA: [Float], _ summandB: [Float]) {
        
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

extension GPUAddition {
    
    func compute() -> () {
        guard
            let commandBuffer: MTLCommandBuffer = self.commandQueue.makeCommandBuffer(),
            let computeEncoder: MTLComputeCommandEncoder = commandBuffer.makeComputeCommandEncoder() else { return }
        
        computeEncoder.setComputePipelineState(self.pipelineState)
        computeEncoder.setBuffer(self.bufferSummandA, offset: 0, index: 0)
        computeEncoder.setBuffer(self.bufferSummandB, offset: 0, index: 1)
        computeEncoder.setBuffer(self.bufferResult, offset: 0, index: 2)
        computeEncoder.dispatchThreads(self.getGridSize(), threadsPerThreadgroup: self.getNumThreadsPerThreadgrup())
        computeEncoder.endEncoding()
        
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
        
    }
    
    func getResult() -> [Float] {
        let rawPtr: UnsafeMutableRawPointer = self.bufferResult.contents()
        let typedPtr: UnsafeMutablePointer<Float> = rawPtr.bindMemory(to: Float.self, capacity: self.arrayLength)
        let bufferPtr: UnsafeBufferPointer = UnsafeBufferPointer(start: typedPtr, count: self.arrayLength)
        return Array(bufferPtr)
    }
    
    private func getGridSize() -> MTLSize {
        return MTLSizeMake(self.arrayLength, 1, 1)
    }
    
    private func getNumThreadsPerThreadgrup() -> MTLSize {
        let maxNumThreadsPerThreadgroup = min(self.pipelineState.maxTotalThreadsPerThreadgroup, self.arrayLength) /// limit thread group size to array length
        return MTLSizeMake(maxNumThreadsPerThreadgroup, 1, 1)
    }
    
}
