# passthrough_kernel/aie2_core.py -*- Python -*-
#
# This file is licensed under the Apache License v2.0 with LLVM Exceptions.
# See https://llvm.org/LICENSE.txt for license information.
# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
#
# (c) Copyright 2024 Advanced Micro Devices, Inc. or its affiliates
#
# This file defines the experiment runtime for a passthrough sequence
#   from external memory (shimtiles) to L2 memory (memtiles) 
#   to L1 memory (computetiles) and back.

import sys
import math

from aie.dialects.aie import *
from aie.dialects.aiex import *
from aie.dialects.scf import *
from aie.extras.context import mlir_mod_ctx

import aie.utils.trace as trace_utils
from aie.extras.dialects.ext import memref, arith  # memref and arithmatic dialects

def passthroughKernel(vector_size, trace_size, activation_size):
    N = vector_size
    n = 4   # number of cores
    K = 64  # number of rows
    S = 2   # sparsity metric on rows (e.g. 2 means transfer every second row)
    N_memtile = N // n
    width = N // K
    dma_tile_range = range(n)

    @device(AIEDevice.npu1_4col)
    def device_body():
        memref_sm = T.memref(N_memtile // S, T.i8())
        memref_mc = T.memref(N_memtile // S, T.i8()) 

        passThroughLine = external_func(
            "passThroughLine", inputs=[memref_mc, memref_mc, T.i32()]
        )

        # Tile declarations
        ShimTiles = [tile(i, 0) for i in range(n)]
        MemTiles = [tile(i, 1) for i in range(n)]
        ComputeTiles = [tile(i, 2) for i in range(n)]

        of_in_sm_names = [f"in_sm{i}" for i in range(n)]
        of_out_sm_names = [f"out_sm{i}" for i in range(n)]
        of_in_mc_names = [f"in_mc{i}" for i in range(n)]
        of_out_mc_names = [f"out_mc{i}" for i in range(n)]

        of_in_sm_fifos = {}
        of_out_sm_fifos = {}
        of_in_mc_fifos = {}
        of_out_mc_fifos = {}

        # AIE-array data movement with object fifos
        for i in range(n):
            of_in_sm_fifos[of_in_sm_names[i]] = \
                object_fifo(of_in_sm_names[i], ShimTiles[i], MemTiles[i], 2, memref_sm)
            of_out_sm_fifos[of_out_sm_names[i]] = \
                object_fifo(of_out_sm_names[i], MemTiles[i], ShimTiles[i], 2, memref_sm)
            of_in_mc_fifos[of_in_mc_names[i]] = \
                object_fifo(of_in_mc_names[i], MemTiles[i], ComputeTiles[i], 2, memref_mc)
            of_out_mc_fifos[of_out_mc_names[i]] = \
                object_fifo(of_out_mc_names[i], ComputeTiles[i], MemTiles[i], 2, memref_mc)

        for i in range(n):
            # link shim-mem fifo to mem-core fifo
            object_fifo_link(of_in_sm_fifos[of_in_sm_names[i]], \
                                of_in_mc_fifos[of_in_mc_names[i]])
            # and back
            object_fifo_link(of_out_mc_fifos[of_out_mc_names[i]], \
                                of_out_sm_fifos[of_out_sm_names[i]])

        # Set up compute tiles
        for i in range(n):
            @core(ComputeTiles[i], "passThrough.cc.o")
            def core_body():
                for _ in for_(sys.maxsize):
                    elemIn = of_in_mc_fifos[of_in_mc_names[i]].acquire(
                        ObjectFifoPort.Consume, 1)
                    elemOut = of_out_mc_fifos[of_out_mc_names[i]].acquire(
                        ObjectFifoPort.Produce, 1)
                    
                    call(passThroughLine, [elemIn, elemOut, N])

                    of_in_mc_fifos[of_in_mc_names[i]].release(
                        ObjectFifoPort.Consume, 1)
                    of_out_mc_fifos[of_out_mc_names[i]].release(
                        ObjectFifoPort.Produce, 1)
                    yield_([])

        # Define experiment runtime sequence. Only one of these experiments
        #   should be defined at any one time. We do not case on experiment number
        #   in the sequence to avoid additional overhead.
        # Note: Experiment 2, 4 have the same logic. For experiment 2, just put `S=1` above.
        @runtime_sequence(
            T.memref(N, T.i8()), 
            T.memref(N, T.i8()), 
            T.memref(N, T.i8()) 
        )
        def sequence(inTensor, outTensor, actTensor):
            # Experiment 1
            for i in dma_tile_range:
                npu_dma_memcpy_nd(
                    metadata=of_in_sm_names[i],
                    bd_id=i % 16,
                    mem=inTensor,
                    offsets=[0, 0, 0, i * N_memtile],
                    sizes=[1, 1, 1, N_memtile],
                )
                npu_dma_memcpy_nd(
                    metadata=of_out_sm_names[i],
                    bd_id=(i + 4) % 16,
                    mem=outTensor,
                    offsets=[0, 0, 0, i * N_memtile],
                    sizes=[1, 1, 1, N_memtile],
                )

            # Experiment 2, 4
            # for i in dma_tile_range:
            #     npu_dma_memcpy_nd(
            #         metadata=of_in_sm_names[i],
            #         bd_id=i % 16,
            #         mem=inTensor,
            #         offsets=[0, 0, 0, i * N_memtile],
            #         sizes=[1, 1, K // n // S, width],
            #         strides=[0, 0, S * width, 1]
            #     )
            #     npu_dma_memcpy_nd(
            #         metadata=of_out_sm_names[i],
            #         bd_id=(i + 4) % 16,
            #         mem=outTensor,
            #         offsets=[0, 0, 0, i * N_memtile],
            #         sizes=[1, 1, K // n // S, width],
            #         strides=[0, 0, S * width, 1]
            #     )

            npu_sync(column=0, row=0, direction=0, channel=0) 

try:
    vector_size = int(sys.argv[1])
    if vector_size % 64 != 0 or vector_size < 512:
        print("Vector size must be a multiple of 64 and greater than or equal to 512")
        raise ValueError
    trace_size = 0 if (len(sys.argv) < 3) else int(sys.argv[2])
    activation_size = vector_size if (len(sys.argv) < 4) else int(sys.argv[3])
    if vector_size % activation_size != 0:
        print("Activation size must divide the vector size")
        raise ValueError
except ValueError:
    print("Argument has inappropriate value")
with mlir_mod_ctx() as ctx:
    passthroughKernel(vector_size, trace_size, activation_size)
    print(ctx.module)
