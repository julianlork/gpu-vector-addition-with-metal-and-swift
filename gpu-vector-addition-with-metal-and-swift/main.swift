//
//  main.swift
//  gpu-vector-addition-with-metal-and-swift
//
//  Created by Julian Lork on 02.09.23.
//

import Foundation

let summandA: [Float] = (1...1000).map { _ in  Float.random(in: 1...1000)}
let summandB: [Float] = (1...1000).map {_ in Float.random(in: 1...1000)}

let gpuAddition: GPUAddition = GPUAddition(summandA, summandB)
gpuAddition.compute()


