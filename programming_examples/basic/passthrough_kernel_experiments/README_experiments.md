<!---//===- README_experiments.md -----------------------------------------*- Markdown -*-===//
//
// This file is licensed under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
// Copyright (C) 2024, Advanced Micro Devices, Inc.
// 
//===----------------------------------------------------------------------===//-->

# Passthrough Kernel Latency Experiments

## Contents
This repository (adapted from "Passthrough Kernel") was created to run passthrough latency experiments that profile the speedup we can expect to realize by exploiting activation sparsity.
We will test the worst-case sparsity patterns: alternating rows of $(1/S)$-sparsity. For instance, at `S = 2`, the worst case is transferring alternating
rows because we have to pay the associated with each strided transfer. Depending on how much data we are concerned with (shape of the operands), the best case is 
either a one shot passthrough (described below), or creating some parallel transfer configuration (i.e. paying overhead for a small number of BDs is acceptable in return for
a parallel transfer, over the serial one-shot). <br>

## Problem

Fix a subgraph of the model architecture where we have the output sparse activation vector $A$ from an activation function $f$. Now, we want to compute the output of the next layer by multiplying $A$ with a weight matrix $W$.

Since $W$ is very large, it is stored in external memory (DDR). We want to transfer a subset of the elements of $W$ from DDR to L2. Let us have an activation vector $A \in \mathbb{R}^{1 \times K}$ and $W \in \mathbb{R}^{K \times M}$. The output is $O=AW$. The transfer granularity is in rows, so each element $a_i \in A$ maps one-to-one to a row $W_{i*}$ of $W$. If $a_i \neq 0$, then transfer $W_{i*}$, otherwise do not.

Note that we could also have $A \in \mathbb{R}^{K \times 1}, W \in \mathbb{R}^{K \times M}$, so $O=A^TW$. Or even $A \in \mathbb{R}^{K \times 1}, W \in \mathbb{R}^{M \times K}$, so $O=WA$. These results are the same up to transposition, and the representation is the same in memory. Therefore, we consider row-wise transfers; it is not necessary to consider column-wise ones. 

`aie2.py` corresponds to a DDR to shimtile to memtile passthrough.

## Definitions
- `S` denotes the level of sparsity we are dealing with. An activation vector $A$ is $(1/S)$-sparse if there is 1 activated element per `S` elements. <br>
- `n` denotes the number of cores/columns on the NPU. We use `n = 4`.
- `N` denotes the size of $W$. Namely, $N=KM$.
- `N_memtile = N / n` is the data size held by each memtile.
- `width = N / K` is $M$, the size of a row of $W$.

## Setup
Follow the standard setup described in `$MY_BASE/README.md`. Ensure that you `source setup.sh` from the base of this repo. If this is the first time running it, i.e. `$MY_BASE/my_install` does not exist, then `source setup.sh --init` instead, which (re)installs everything from scratch. <br>

### Important
Before running any experiments, open another terminal and run `gcc spin.c -o spin.o ; ./spin.o`. This will reduce variance significantly (by preventing the processor from going into low power mode, which would be catastrophic for profiling since much of this is interrupt-driven).

To prevent the NPU from sleeping, run:
```
lspci | grep Signal
```
to obtain the signal processing controller, e.g. `66:00.1`. Then run:
```bash
sudo -i
echo on > /sys/bus/pci/devices/0000\:{controller}/power/control
```

## Hardware and Dataflow
Ensure the device used is set as `@device(AIEDevice.npu1_4col)`. The dataflow is as follows:
1. $W$ is composed of `int8_t` elements and is initially in DDR. Assume that we already know the pattern of $A$ (for these experiments, assume the `S`-alternating pattern).
2. Four pairs of shimtiles and memtiles "own" four sequential blocks of $W$ in DDR.
3. FIFO queues are established between the shimtile and corresponding memtile for a total of four queues.
4. For each shimtile-memtile pair, one BD is used to send elements of $W$ to the memtile, and a different BD is used to send these elements back to the shimtile.
The desired elements depend on the pattern of $A$, which is experiment-dependent. The transfers for each pair occur only on the corresponding "owned" block of $W$.
5. Synchronize the transfers.

## Experiments
- `experiment 1` transfers $W$ in one shot. `S` is ignored. Each (of 4) shimtiles uses two DMA buffer descriptors (BDs), one to and one from the shimtile. <br>
- `experiment 2` transfers $W$ in $K$ strided shots. Namely, the data is transferred one row at a time by setting `S = 1` in the code. <br>
- `experiment 4` transfers one row for every `S` rows. Note this is the same as experiment 2 with `S > 1`. <br>

Buffer descriptors are used in a way that maximizes throughput (i.e. we will not block on a BD to reuse it). There are 16 BDs per shimtile. Also, we fix `N=61440` because that is the maximum size transfer. Each of four memtiles can hold up to 16 KiB with 1 KiB reserved for the stack, so the max is 60 KiB.

### Variables
The experiments fix <br>

- `n = 4` <br>
- `N = vector_size = 61440` (fixed in the `Makefile` and `CMakeLists.txt`) <br>
- `K = 64` (fixed in the `Makefile` and `CMakeLists.txt`) <br>
- `width = N / K` <br>

and vary `S = {1, 2, 4, 8, 16, 32, 64}`. <br>

To obtain `experiment 2` results for `S = {32, 64}`, we must iterate only over `i = {0, 2}` and `i = {0}` respectively in the `@runtime_sequence`. This is because $W$ is tiled into four `N_memtile`-sized blocks, one owned by each shimtile. See the hardware and dataflow description above.

```python
...

S = 16   # sparsity metric on rows (e.g. 2 means transfer every second row)
N_memtile = N // n
width = N // K
dma_tile_range = range(n) # change this to any subset of tiles

...

@device(AIEDevice.npu1_4col)
def device_body():

    ...
    
    @runtime_sequence(
            T.memref(N, T.i8()), 
            T.memref(N, T.i8()), 
            T.memref(N, T.i8()) 
        )
        def sequence(inTensor, outTensor, actTensor):
    
            ...
    
            for i in dma_tile_range:
                npu_dma_memcpy_nd(
                    metadata=of_in_sm_names[i],
                    bd_id=i % 16,
                    mem=inTensor,
                    offsets=[0, 0, 0, i * N_memtile],
                    sizes=[1, 1, K // n // S, width],
                    strides=[0, 0, S * width, 1]
                )
                npu_dma_memcpy_nd(
                    metadata=of_out_sm_names[i],
                    bd_id=(i + n) % 16, # non-overlapping BDs
                    mem=outTensor,
                    offsets=[0, 0, 0, i * N_memtile],
                    sizes=[1, 1, K // n // S, width],
                    strides=[0, 0, S * width, 1]
                )
            npu_sync(column=0, row=0, direction=0, channel=0)

...
```

### Run
To run `experiment 1`, comment out the `experiment 2, 4` block (rudimentary currently, but branching might happen if we use an auxiliary variable). 
Vice versa for running `experiment 2, 4`. Finally, run `make run > out.txt` to see your latency breakdown for an experiment. The driver code is in `test.cpp`.

## Other Experiments
So far, we have described the $(1/S)$-alternating sparsity pattern, which is the worst-case pattern. Experiments for the one-shot pattern may be performed in a similar way,
but we must be careful about calling `npu_dma_memcpy_nd()` when changing `S` in this scenario.

### One shot passthrough

`S = 1`: Same as above. <br>
`S = 2`: Only iterate over `i = {0, 1}` in the `@runtime_sequence` and set `S = 1`. Intuitively, the desired weights are dense in the first two shimtiles, so we don't need to invoke `npu_dma_memcpy_nd()` on the other two shimtiles. <br>
`S = 4`: Only iterate over `i = {0}` in the `@runtime_sequence` and set `S = 1`. The desired weights are dense in the first shimtile only. <br>
`S = {8, 16, 32, 64}`: Only iterate over `i = {0}` in the `@runtime_sequence` and respectively set `S = {2, 4, 8, 16}`. The desired weights are dense in the first {half, fourth, eighth, sixteenth} of the first shimtile respectively. <br>

Note: It is very annoying to change the activation bitmap vector in `test.cpp` to verify correctness as you vary `S`. A good sanity check is that values in a given row should be strictly sequential, and you can view the output in `out.txt` or whereever you redirected it to. More likely than not, it is correct if this check is satisfied.
