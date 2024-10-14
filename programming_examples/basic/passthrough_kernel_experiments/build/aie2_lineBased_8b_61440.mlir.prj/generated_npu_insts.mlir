module {
  aie.device(npu1_4col) {
    memref.global "public" @out_sm3_cons : memref<960xi8>
    memref.global "public" @out_sm3 : memref<960xi8>
    memref.global "public" @in_sm3_cons : memref<960xi8>
    memref.global "public" @in_sm3 : memref<960xi8>
    memref.global "public" @out_sm2_cons : memref<960xi8>
    memref.global "public" @out_sm2 : memref<960xi8>
    memref.global "public" @in_sm2_cons : memref<960xi8>
    memref.global "public" @in_sm2 : memref<960xi8>
    memref.global "public" @out_sm1_cons : memref<960xi8>
    memref.global "public" @out_sm1 : memref<960xi8>
    memref.global "public" @in_sm1_cons : memref<960xi8>
    memref.global "public" @in_sm1 : memref<960xi8>
    memref.global "public" @out_sm0_cons : memref<960xi8>
    memref.global "public" @out_sm0 : memref<960xi8>
    memref.global "public" @in_sm0_cons : memref<960xi8>
    memref.global "public" @in_sm0 : memref<960xi8>
    func.func private @passThroughLine(memref<960xi8>, memref<960xi8>, i32)
    %tile_0_0 = aie.tile(0, 0) {controller_id = #aie.packet_info<pkt_type = 0, pkt_id = 15>}
    %tile_1_0 = aie.tile(1, 0) {controller_id = #aie.packet_info<pkt_type = 0, pkt_id = 15>}
    %tile_2_0 = aie.tile(2, 0) {controller_id = #aie.packet_info<pkt_type = 0, pkt_id = 15>}
    %tile_3_0 = aie.tile(3, 0) {controller_id = #aie.packet_info<pkt_type = 0, pkt_id = 15>}
    %tile_0_1 = aie.tile(0, 1) {controller_id = #aie.packet_info<pkt_type = 0, pkt_id = 26>}
    %tile_1_1 = aie.tile(1, 1) {controller_id = #aie.packet_info<pkt_type = 0, pkt_id = 26>}
    %tile_2_1 = aie.tile(2, 1) {controller_id = #aie.packet_info<pkt_type = 0, pkt_id = 26>}
    %tile_3_1 = aie.tile(3, 1) {controller_id = #aie.packet_info<pkt_type = 0, pkt_id = 26>}
    %in_sm3_cons_buff_0 = aie.buffer(%tile_3_1) {address = 0 : i32, mem_bank = 0 : i32, sym_name = "in_sm3_cons_buff_0"} : memref<960xi8> 
    %in_sm3_cons_buff_1 = aie.buffer(%tile_3_1) {address = 960 : i32, mem_bank = 0 : i32, sym_name = "in_sm3_cons_buff_1"} : memref<960xi8> 
    %in_sm3_cons_prod_lock = aie.lock(%tile_3_1, 0) {init = 2 : i32, sym_name = "in_sm3_cons_prod_lock"}
    %in_sm3_cons_cons_lock = aie.lock(%tile_3_1, 1) {init = 0 : i32, sym_name = "in_sm3_cons_cons_lock"}
    %in_sm2_cons_buff_0 = aie.buffer(%tile_2_1) {address = 0 : i32, mem_bank = 0 : i32, sym_name = "in_sm2_cons_buff_0"} : memref<960xi8> 
    %in_sm2_cons_buff_1 = aie.buffer(%tile_2_1) {address = 960 : i32, mem_bank = 0 : i32, sym_name = "in_sm2_cons_buff_1"} : memref<960xi8> 
    %in_sm2_cons_prod_lock = aie.lock(%tile_2_1, 0) {init = 2 : i32, sym_name = "in_sm2_cons_prod_lock"}
    %in_sm2_cons_cons_lock = aie.lock(%tile_2_1, 1) {init = 0 : i32, sym_name = "in_sm2_cons_cons_lock"}
    %in_sm1_cons_buff_0 = aie.buffer(%tile_1_1) {address = 0 : i32, mem_bank = 0 : i32, sym_name = "in_sm1_cons_buff_0"} : memref<960xi8> 
    %in_sm1_cons_buff_1 = aie.buffer(%tile_1_1) {address = 960 : i32, mem_bank = 0 : i32, sym_name = "in_sm1_cons_buff_1"} : memref<960xi8> 
    %in_sm1_cons_prod_lock = aie.lock(%tile_1_1, 0) {init = 2 : i32, sym_name = "in_sm1_cons_prod_lock"}
    %in_sm1_cons_cons_lock = aie.lock(%tile_1_1, 1) {init = 0 : i32, sym_name = "in_sm1_cons_cons_lock"}
    %in_sm0_cons_buff_0 = aie.buffer(%tile_0_1) {address = 0 : i32, mem_bank = 0 : i32, sym_name = "in_sm0_cons_buff_0"} : memref<960xi8> 
    %in_sm0_cons_buff_1 = aie.buffer(%tile_0_1) {address = 960 : i32, mem_bank = 0 : i32, sym_name = "in_sm0_cons_buff_1"} : memref<960xi8> 
    %in_sm0_cons_prod_lock = aie.lock(%tile_0_1, 0) {init = 2 : i32, sym_name = "in_sm0_cons_prod_lock"}
    %in_sm0_cons_cons_lock = aie.lock(%tile_0_1, 1) {init = 0 : i32, sym_name = "in_sm0_cons_cons_lock"}
    aie.flow(%tile_0_0, DMA : 0, %tile_0_1, DMA : 0)
    aie.flow(%tile_0_1, DMA : 0, %tile_0_0, DMA : 0)
    aie.flow(%tile_1_0, DMA : 0, %tile_1_1, DMA : 0)
    aie.flow(%tile_1_1, DMA : 0, %tile_1_0, DMA : 0)
    aie.flow(%tile_2_0, DMA : 0, %tile_2_1, DMA : 0)
    aie.flow(%tile_2_1, DMA : 0, %tile_2_0, DMA : 0)
    aie.flow(%tile_3_0, DMA : 0, %tile_3_1, DMA : 0)
    aie.flow(%tile_3_1, DMA : 0, %tile_3_0, DMA : 0)
    aie.shim_dma_allocation @in_sm0(MM2S, 0, 0)
    memref.global "private" constant @blockwrite_data_0 : memref<8xi32> = dense<[240, 0, 0, 0, -2147483648, 0, 0, 33554432]>
    memref.global "private" constant @blockwrite_data_1 : memref<8xi32> = dense<[240, 0, 0, 0, -2147483648, 0, 0, 33554432]>
    aiex.runtime_sequence(%arg0: memref<61440xi8>, %arg1: memref<61440xi8>, %arg2: memref<61440xi8>) {
      %0 = memref.get_global @blockwrite_data_0 : memref<8xi32>
      aiex.npu.blockwrite(%0) {address = 118784 : ui32} : memref<8xi32>
      aiex.npu.address_patch {addr = 118788 : ui32, arg_idx = 0 : i32, arg_plus = 0 : i32}
      aiex.npu.write32 {address = 119316 : ui32, column = 0 : i32, row = 0 : i32, value = 0 : ui32}
      %1 = memref.get_global @blockwrite_data_1 : memref<8xi32>
      aiex.npu.blockwrite(%1) {address = 118816 : ui32} : memref<8xi32>
      aiex.npu.address_patch {addr = 118820 : ui32, arg_idx = 1 : i32, arg_plus = 0 : i32}
      aiex.npu.maskwrite32 {address = 119296 : ui32, column = 0 : i32, mask = 3840 : ui32, row = 0 : i32, value = 3840 : ui32}
      aiex.npu.write32 {address = 119300 : ui32, column = 0 : i32, row = 0 : i32, value = 2147483649 : ui32}
      aiex.npu.sync {channel = 0 : i32, column = 0 : i32, column_num = 1 : i32, direction = 0 : i32, row = 0 : i32, row_num = 1 : i32}
    }
    aie.shim_dma_allocation @out_sm0(S2MM, 0, 0)
    aie.shim_dma_allocation @in_sm1(MM2S, 0, 1)
    %memtile_dma_0_1 = aie.memtile_dma(%tile_0_1) {
      %0 = aie.dma_start(S2MM, 0, ^bb1, ^bb3)
    ^bb1:  // 2 preds: ^bb0, ^bb2
      aie.use_lock(%in_sm0_cons_prod_lock, AcquireGreaterEqual, 1)
      aie.dma_bd(%in_sm0_cons_buff_0 : memref<960xi8>, 0, 960) {bd_id = 0 : i32, next_bd_id = 1 : i32}
      aie.use_lock(%in_sm0_cons_cons_lock, Release, 1)
      aie.next_bd ^bb2
    ^bb2:  // pred: ^bb1
      aie.use_lock(%in_sm0_cons_prod_lock, AcquireGreaterEqual, 1)
      aie.dma_bd(%in_sm0_cons_buff_1 : memref<960xi8>, 0, 960) {bd_id = 1 : i32, next_bd_id = 0 : i32}
      aie.use_lock(%in_sm0_cons_cons_lock, Release, 1)
      aie.next_bd ^bb1
    ^bb3:  // pred: ^bb0
      %1 = aie.dma_start(MM2S, 0, ^bb4, ^bb6)
    ^bb4:  // 2 preds: ^bb3, ^bb5
      aie.use_lock(%in_sm0_cons_cons_lock, AcquireGreaterEqual, 1)
      aie.dma_bd(%in_sm0_cons_buff_0 : memref<960xi8>, 0, 960) {bd_id = 2 : i32, next_bd_id = 3 : i32}
      aie.use_lock(%in_sm0_cons_prod_lock, Release, 1)
      aie.next_bd ^bb5
    ^bb5:  // pred: ^bb4
      aie.use_lock(%in_sm0_cons_cons_lock, AcquireGreaterEqual, 1)
      aie.dma_bd(%in_sm0_cons_buff_1 : memref<960xi8>, 0, 960) {bd_id = 3 : i32, next_bd_id = 2 : i32}
      aie.use_lock(%in_sm0_cons_prod_lock, Release, 1)
      aie.next_bd ^bb4
    ^bb6:  // pred: ^bb3
      aie.end
    }
    aie.shim_dma_allocation @out_sm1(S2MM, 0, 1)
    aie.shim_dma_allocation @in_sm2(MM2S, 0, 2)
    %memtile_dma_1_1 = aie.memtile_dma(%tile_1_1) {
      %0 = aie.dma_start(S2MM, 0, ^bb1, ^bb3)
    ^bb1:  // 2 preds: ^bb0, ^bb2
      aie.use_lock(%in_sm1_cons_prod_lock, AcquireGreaterEqual, 1)
      aie.dma_bd(%in_sm1_cons_buff_0 : memref<960xi8>, 0, 960) {bd_id = 0 : i32, next_bd_id = 1 : i32}
      aie.use_lock(%in_sm1_cons_cons_lock, Release, 1)
      aie.next_bd ^bb2
    ^bb2:  // pred: ^bb1
      aie.use_lock(%in_sm1_cons_prod_lock, AcquireGreaterEqual, 1)
      aie.dma_bd(%in_sm1_cons_buff_1 : memref<960xi8>, 0, 960) {bd_id = 1 : i32, next_bd_id = 0 : i32}
      aie.use_lock(%in_sm1_cons_cons_lock, Release, 1)
      aie.next_bd ^bb1
    ^bb3:  // pred: ^bb0
      %1 = aie.dma_start(MM2S, 0, ^bb4, ^bb6)
    ^bb4:  // 2 preds: ^bb3, ^bb5
      aie.use_lock(%in_sm1_cons_cons_lock, AcquireGreaterEqual, 1)
      aie.dma_bd(%in_sm1_cons_buff_0 : memref<960xi8>, 0, 960) {bd_id = 2 : i32, next_bd_id = 3 : i32}
      aie.use_lock(%in_sm1_cons_prod_lock, Release, 1)
      aie.next_bd ^bb5
    ^bb5:  // pred: ^bb4
      aie.use_lock(%in_sm1_cons_cons_lock, AcquireGreaterEqual, 1)
      aie.dma_bd(%in_sm1_cons_buff_1 : memref<960xi8>, 0, 960) {bd_id = 3 : i32, next_bd_id = 2 : i32}
      aie.use_lock(%in_sm1_cons_prod_lock, Release, 1)
      aie.next_bd ^bb4
    ^bb6:  // pred: ^bb3
      aie.end
    }
    aie.shim_dma_allocation @out_sm2(S2MM, 0, 2)
    aie.shim_dma_allocation @in_sm3(MM2S, 0, 3)
    %memtile_dma_2_1 = aie.memtile_dma(%tile_2_1) {
      %0 = aie.dma_start(S2MM, 0, ^bb1, ^bb3)
    ^bb1:  // 2 preds: ^bb0, ^bb2
      aie.use_lock(%in_sm2_cons_prod_lock, AcquireGreaterEqual, 1)
      aie.dma_bd(%in_sm2_cons_buff_0 : memref<960xi8>, 0, 960) {bd_id = 0 : i32, next_bd_id = 1 : i32}
      aie.use_lock(%in_sm2_cons_cons_lock, Release, 1)
      aie.next_bd ^bb2
    ^bb2:  // pred: ^bb1
      aie.use_lock(%in_sm2_cons_prod_lock, AcquireGreaterEqual, 1)
      aie.dma_bd(%in_sm2_cons_buff_1 : memref<960xi8>, 0, 960) {bd_id = 1 : i32, next_bd_id = 0 : i32}
      aie.use_lock(%in_sm2_cons_cons_lock, Release, 1)
      aie.next_bd ^bb1
    ^bb3:  // pred: ^bb0
      %1 = aie.dma_start(MM2S, 0, ^bb4, ^bb6)
    ^bb4:  // 2 preds: ^bb3, ^bb5
      aie.use_lock(%in_sm2_cons_cons_lock, AcquireGreaterEqual, 1)
      aie.dma_bd(%in_sm2_cons_buff_0 : memref<960xi8>, 0, 960) {bd_id = 2 : i32, next_bd_id = 3 : i32}
      aie.use_lock(%in_sm2_cons_prod_lock, Release, 1)
      aie.next_bd ^bb5
    ^bb5:  // pred: ^bb4
      aie.use_lock(%in_sm2_cons_cons_lock, AcquireGreaterEqual, 1)
      aie.dma_bd(%in_sm2_cons_buff_1 : memref<960xi8>, 0, 960) {bd_id = 3 : i32, next_bd_id = 2 : i32}
      aie.use_lock(%in_sm2_cons_prod_lock, Release, 1)
      aie.next_bd ^bb4
    ^bb6:  // pred: ^bb3
      aie.end
    }
    aie.shim_dma_allocation @out_sm3(S2MM, 0, 3)
    %memtile_dma_3_1 = aie.memtile_dma(%tile_3_1) {
      %0 = aie.dma_start(S2MM, 0, ^bb1, ^bb3)
    ^bb1:  // 2 preds: ^bb0, ^bb2
      aie.use_lock(%in_sm3_cons_prod_lock, AcquireGreaterEqual, 1)
      aie.dma_bd(%in_sm3_cons_buff_0 : memref<960xi8>, 0, 960) {bd_id = 0 : i32, next_bd_id = 1 : i32}
      aie.use_lock(%in_sm3_cons_cons_lock, Release, 1)
      aie.next_bd ^bb2
    ^bb2:  // pred: ^bb1
      aie.use_lock(%in_sm3_cons_prod_lock, AcquireGreaterEqual, 1)
      aie.dma_bd(%in_sm3_cons_buff_1 : memref<960xi8>, 0, 960) {bd_id = 1 : i32, next_bd_id = 0 : i32}
      aie.use_lock(%in_sm3_cons_cons_lock, Release, 1)
      aie.next_bd ^bb1
    ^bb3:  // pred: ^bb0
      %1 = aie.dma_start(MM2S, 0, ^bb4, ^bb6)
    ^bb4:  // 2 preds: ^bb3, ^bb5
      aie.use_lock(%in_sm3_cons_cons_lock, AcquireGreaterEqual, 1)
      aie.dma_bd(%in_sm3_cons_buff_0 : memref<960xi8>, 0, 960) {bd_id = 2 : i32, next_bd_id = 3 : i32}
      aie.use_lock(%in_sm3_cons_prod_lock, Release, 1)
      aie.next_bd ^bb5
    ^bb5:  // pred: ^bb4
      aie.use_lock(%in_sm3_cons_cons_lock, AcquireGreaterEqual, 1)
      aie.dma_bd(%in_sm3_cons_buff_1 : memref<960xi8>, 0, 960) {bd_id = 3 : i32, next_bd_id = 2 : i32}
      aie.use_lock(%in_sm3_cons_prod_lock, Release, 1)
      aie.next_bd ^bb4
    ^bb6:  // pred: ^bb3
      aie.end
    }
    aie.packet_flow(15) {
      aie.packet_source<%tile_0_0, Ctrl : 0>
      aie.packet_dest<%tile_0_0, South : 0>
    } {keep_pkt_header = true, priority_route = true}
    aie.packet_flow(15) {
      aie.packet_source<%tile_1_0, Ctrl : 0>
      aie.packet_dest<%tile_1_0, South : 0>
    } {keep_pkt_header = true, priority_route = true}
    aie.packet_flow(15) {
      aie.packet_source<%tile_2_0, Ctrl : 0>
      aie.packet_dest<%tile_2_0, South : 0>
    } {keep_pkt_header = true, priority_route = true}
    aie.packet_flow(15) {
      aie.packet_source<%tile_3_0, Ctrl : 0>
      aie.packet_dest<%tile_3_0, South : 0>
    } {keep_pkt_header = true, priority_route = true}
  }
}

