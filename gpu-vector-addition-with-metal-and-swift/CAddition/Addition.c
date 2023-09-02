//
//  Addition.c
//  gpu-vector-addition-with-metal-and-swift
//
//  Created by Julian Lork on 02.09.23.
//

#include "Addition.h"

void sum_of_arrays(const float *summand_a, const float *summand_b, float *result, size_t array_length){
    for(int i = 0; i < array_length; i++) {
        result[i] = summand_a[i] + summand_b[i];
    }
}
