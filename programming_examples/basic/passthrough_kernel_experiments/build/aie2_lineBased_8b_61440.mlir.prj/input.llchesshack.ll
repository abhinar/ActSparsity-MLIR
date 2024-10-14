; ModuleID = 'LLVMDialectModule'
source_filename = "LLVMDialectModule"
target triple = "aie2"

@in_sm0_cons_buff_1 = external global [960 x i8]
@in_sm0_cons_buff_0 = external global [960 x i8]
@in_sm1_cons_buff_1 = external global [960 x i8]
@in_sm1_cons_buff_0 = external global [960 x i8]
@in_sm2_cons_buff_1 = external global [960 x i8]
@in_sm2_cons_buff_0 = external global [960 x i8]
@in_sm3_cons_buff_1 = external global [960 x i8]
@in_sm3_cons_buff_0 = external global [960 x i8]
@out_sm3_cons = external global [960 x i8]
@out_sm3 = external global [960 x i8]
@in_sm3_cons = external global [960 x i8]
@in_sm3 = external global [960 x i8]
@out_sm2_cons = external global [960 x i8]
@out_sm2 = external global [960 x i8]
@in_sm2_cons = external global [960 x i8]
@in_sm2 = external global [960 x i8]
@out_sm1_cons = external global [960 x i8]
@out_sm1 = external global [960 x i8]
@in_sm1_cons = external global [960 x i8]
@in_sm1 = external global [960 x i8]
@out_sm0_cons = external global [960 x i8]
@out_sm0 = external global [960 x i8]
@in_sm0_cons = external global [960 x i8]
@in_sm0 = external global [960 x i8]

declare void @debug_i32(i32)

declare void @llvm.aie2.put.ms(i32, i32)

declare { i32, i32 } @llvm.aie2.get.ss()

declare void @llvm.aie2.mcd.write.vec(<16 x i32>, i32)

declare <16 x i32> @llvm.aie2.scd.read.vec(i32)

declare void @llvm.aie2.acquire(i32, i32)

declare void @llvm.aie2.release(i32, i32)

declare void @passThroughLine(ptr, ptr, i32)

!llvm.module.flags = !{!0}

!0 = !{i32 2, !"Debug Info Version", i32 3}
