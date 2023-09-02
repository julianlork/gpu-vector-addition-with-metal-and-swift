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
let result: [Float]

gpuAddition = GPUAddition(summandA, summandB)
gpuAddition.compute()
result = gpuAddition.getResult()

