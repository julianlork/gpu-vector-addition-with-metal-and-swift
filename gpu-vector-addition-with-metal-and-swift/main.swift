//
//  main.swift
//  gpu-vector-addition-with-metal-and-swift
//
//  Created by Julian Lork on 02.09.23.
//

import Foundation
let arrayLength: Int = 100000000
let summandA: [Float] = (1...arrayLength).map { _ in  Float(Int.random(in: 1...arrayLength))}
let summandB: [Float] = (1...arrayLength).map {_ in  Float(Int.random(in: 1...arrayLength))}
var cpuResult: [Float] = (1...arrayLength).map { _ in 0.0 }
let gpuAddition: GPUAddition = GPUAddition(summandA, summandB)

let gpuComputationTime: CFTimeInterval = executeAdditionOnGPU()
let cpuComputationTime: CFTimeInterval = executeAdditionOnCPU()

assert(cpuResult == gpuAddition.getResult(), "Error: GPU and CPU computations differ.")
print("\nGPU and CPU computations produce the same output.")
print("GPU result in \(gpuComputationTime) sec")
print("CPU result in \(cpuComputationTime) sec\n")

func executeAdditionOnGPU() -> CFTimeInterval {
    let startTime = CFAbsoluteTimeGetCurrent()
    gpuAddition.compute()
    let endTime = CFAbsoluteTimeGetCurrent()
    return endTime-startTime
}

func executeAdditionOnCPU() -> CFTimeInterval {
    let startTime = CFAbsoluteTimeGetCurrent()
    sum_of_arrays(summandA, summandB, &cpuResult, cpuResult.count)  /// &: inout param
    let endTime = CFAbsoluteTimeGetCurrent()
    return endTime-startTime
}
