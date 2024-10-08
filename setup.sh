#!/bin/bash
#################################################################################
# Setup Vitis (which includes aiecompiler and xchessde)
#################################################################################
source /opt/xilinx/xrt/setup.sh

export MYXILINX_VER=2023.2
export MYXILINX_BASE=/proj/xbuilds/${MYXILINX_VER}_daily_latest
export XILINX_LOC=$MYXILINX_BASE/installs/lin64/Vitis/$MYXILINX_VER
export AIETOOLS_ROOT=$XILINX_LOC/aietools
export PATH=$PATH:${AIETOOLS_ROOT}/bin:$XILINX_LOC/bin
export LM_LICENSE_FILE=2100@aiengine
export VITIS=${XILINX_LOC}
export XILINX_VITIS=${XILINX_LOC}
export VITIS_ROOT=${XILINX_LOC}


if [[ $1 == "--init"]]; then
    source utils/init_setup.sh
else
    source utils/quick_setup.sh

# Extras from the instructions:
export XRT_HACK_UNSECURE_LOADING_XCLBIN=1
source /opt/xilinx/xrt/setup.sh

# Extras from quick_setup.sh:
export MY_BASE=$HOME/ActSparsity-MLIR

export PATH=$MY_BASE:$PATH
source $MY_BASE/ironenv/bin/activate
export PATH=$MY_BASE/my_install/mlir-aie/bin:$MY_BASE/my_install/mlir/bin:$PATH
export LD_LIBRARY_PATH=$MY_BASE/my_install/mlir-aie/lib:$MY_BASE/my_install/mlir/lib:$LD_LIBRARY_PATH
export PYTHONPATH=$MY_BASE/my_install/mlir-aie/python:$PYTHONPATH

export PATH=$MY_BASE/bin:$MY_BASE/mlir/bin:$PATH
export LD_LIBRARY_PATH=$MY_BASE/lib:$MY_BASE/mlir/lib:$LD_LIBRARY_PATH
export PYTHONPATH=$MY_BASE/python:$PYTHONPATH
export PATH=$LD_LIBRARY_PATH:$PATH
export PATH=$PYTHONPATH:$PATH
export PATH=$MY_BASE/python/compiler:$PATH
export PATH=$MY_BASE/tools:$PATH

export MLIR_AIE_BUILD_DIR=$MY_BASE
source ${MLIR_AIE_BUILD_DIR}/ironenv/bin/activate
source ${MLIR_AIE_BUILD_DIR}/utils/env_setup.sh ${MLIR_AIE_BUILD_DIR}/my_install/mlir_aie ${MLIR_AIE_BUILD_DIR}/my_install/mlir
