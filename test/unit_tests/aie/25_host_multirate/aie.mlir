//===- aie.mlir ------------------------------------------------*- MLIR -*-===//
//
// This file is licensed under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
// Copyright (C) 2022, Advanced Micro Devices, Inc.
//
//===----------------------------------------------------------------------===//

// RUN: %PYTHON aiecc.py -j4 %VitisSysrootFlag% --host-target=%aieHostTargetTriplet% %link_against_hsa% %s %test_lib_flags %extraAieCcFlags% %S/test.cpp -o test.elf
// RUN: %run_on_vck5000 ./test.elf

aie.device(xcvc1902) {
    %tile34 = aie.tile(3, 4)
    %tile70 = aie.tile(7, 0)

    %hostLock = aie.lock(%tile34, 0) {sym_name="hostLock"}

    func.func @evaluate_condition(%argIn : i32) -> (i1) {
        %true = arith.constant 1 : i1
        return %true : i1
    }

    func.func @payload(%argIn : i32) -> (i32) {
        %next = arith.constant 1 : i32
        return %next : i32
    }

    %ext_buf70_in  = aie.external_buffer {sym_name = "ddr_test_buffer_in"}: memref<256xi32>
    %ext_buf70_out = aie.external_buffer {sym_name = "ddr_test_buffer_out"}: memref<64xi32>

    aie.objectfifo @of_in (%tile70, {%tile34}, 1 : i32) : !aie.objectfifo<memref<64xi32>>
    aie.objectfifo @of_out (%tile34, {%tile70}, 1 : i32) : !aie.objectfifo<memref<64xi32>>

    aie.objectfifo.register_external_buffers @of_in (%tile70, {%ext_buf70_in}) : (memref<256xi32>)
    aie.objectfifo.register_external_buffers @of_out (%tile70, {%ext_buf70_out}) : (memref<64xi32>)

    %core34 = aie.core(%tile34) {
        %c0 = arith.constant 0 : index
        %c1 = arith.constant 1 : index
        %height = arith.constant 64 : index
        %init1 = arith.constant 1 : i32

        %res = scf.while (%arg1 = %init1) : (i32) -> i32 {
            %condition = func.call @evaluate_condition(%arg1) : (i32) -> i1
            scf.condition(%condition) %arg1 : i32
        } do {
            ^bb0(%arg2: i32):
            %next = func.call @payload(%arg2) : (i32) -> i32

            aie.use_lock(%hostLock, Acquire, 1)

            %inputSubview = aie.objectfifo.acquire @of_in (Consume, 1) : !aie.objectfifosubview<memref<64xi32>>
            %outputSubview = aie.objectfifo.acquire @of_out (Produce, 1) : !aie.objectfifosubview<memref<64xi32>>

            %input = aie.objectfifo.subview.access %inputSubview[0] : !aie.objectfifosubview<memref<64xi32>> -> memref<64xi32>
            %output = aie.objectfifo.subview.access %outputSubview[0] : !aie.objectfifosubview<memref<64xi32>> -> memref<64xi32>

            scf.for %indexInHeight = %c0 to %height step %c1 {
                %d1 = memref.load %input[%indexInHeight] : memref<64xi32>
                memref.store %d1, %output[%indexInHeight] : memref<64xi32>
            }

            aie.objectfifo.release @of_in (Consume, 1)
            aie.objectfifo.release @of_out (Produce, 1)

            aie.use_lock(%hostLock, Release, 0)

            scf.yield %next : i32
        }
        aie.end
    }
}
