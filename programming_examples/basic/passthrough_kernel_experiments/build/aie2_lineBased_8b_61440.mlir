module {
  aie.device(npu1_4col) {
    func.func private @passThroughLine(memref<960xi8>, memref<960xi8>, i32)
    %tile_0_0 = aie.tile(0, 0)
    %tile_1_0 = aie.tile(1, 0)
    %tile_2_0 = aie.tile(2, 0)
    %tile_3_0 = aie.tile(3, 0)
    %tile_0_1 = aie.tile(0, 1)
    %tile_1_1 = aie.tile(1, 1)
    %tile_2_1 = aie.tile(2, 1)
    %tile_3_1 = aie.tile(3, 1)
    aie.objectfifo @in_sm0(%tile_0_0, {%tile_0_1}, 2 : i32) : !aie.objectfifo<memref<960xi8>>
    aie.objectfifo @out_sm0(%tile_0_1, {%tile_0_0}, 2 : i32) : !aie.objectfifo<memref<960xi8>>
    aie.objectfifo @in_sm1(%tile_1_0, {%tile_1_1}, 2 : i32) : !aie.objectfifo<memref<960xi8>>
    aie.objectfifo @out_sm1(%tile_1_1, {%tile_1_0}, 2 : i32) : !aie.objectfifo<memref<960xi8>>
    aie.objectfifo @in_sm2(%tile_2_0, {%tile_2_1}, 2 : i32) : !aie.objectfifo<memref<960xi8>>
    aie.objectfifo @out_sm2(%tile_2_1, {%tile_2_0}, 2 : i32) : !aie.objectfifo<memref<960xi8>>
    aie.objectfifo @in_sm3(%tile_3_0, {%tile_3_1}, 2 : i32) : !aie.objectfifo<memref<960xi8>>
    aie.objectfifo @out_sm3(%tile_3_1, {%tile_3_0}, 2 : i32) : !aie.objectfifo<memref<960xi8>>
    aie.objectfifo.link [@in_sm0] -> [@out_sm0]([] [])
    aie.objectfifo.link [@in_sm1] -> [@out_sm1]([] [])
    aie.objectfifo.link [@in_sm2] -> [@out_sm2]([] [])
    aie.objectfifo.link [@in_sm3] -> [@out_sm3]([] [])
    aiex.runtime_sequence(%arg0: memref<61440xi8>, %arg1: memref<61440xi8>, %arg2: memref<61440xi8>) {
      aiex.npu.dma_memcpy_nd(0, 0, %arg0[0, 0, 0, 0][1, 1, 1, 960][0, 0, 0, 1]) {id = 0 : i64, metadata = @in_sm0} : memref<61440xi8>
      aiex.npu.dma_memcpy_nd(0, 0, %arg1[0, 0, 0, 0][1, 1, 1, 960][0, 0, 0, 1]) {id = 1 : i64, metadata = @out_sm0} : memref<61440xi8>
      aiex.npu.sync {channel = 0 : i32, column = 0 : i32, column_num = 1 : i32, direction = 0 : i32, row = 0 : i32, row_num = 1 : i32}
    }
  }
}

