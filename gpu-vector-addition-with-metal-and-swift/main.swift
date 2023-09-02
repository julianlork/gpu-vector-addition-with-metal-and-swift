//
//  main.swift
//  gpu-vector-addition-with-metal-and-swift
//
//  Created by Julian Lork on 02.09.23.
//

import Foundation

let gpuAddition: GPUAddition
let summandA: [Float] = (1...1000).map { _ in  Float.random(in: 1...1000)}
let summandB: [Float] = (1...1000).map {_ in Float.random(in: 1...1000)}
var cpuResult: [Float] = (1...1000).map { _ in 0 }
let gpuResult: [Float]

/// GPU addition
gpuAddition = GPUAddition(summandA, summandB)
gpuAddition.compute()
gpuResult = gpuAddition.getResult()

/// CPU addition (low level)
sum_of_arrays(summandA, summandB, &cpuResult, cpuResult.count)

/// Result verification
assert(cpuResult == gpuResult, "Error: GPU and CPU computations differ.")
print("\nGPU and CPU computations produce the same output.\n")
