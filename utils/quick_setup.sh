#!/usr/bin/env bash
##===- quick_setup.sh - Post-initial IRON for Ryzen AI dev ----------*- Script -*-===##
# 
# This file licensed under the Apache License v2.0 with LLVM Exceptions.
# See https://llvm.org/LICENSE.txt for license information.
# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
#
##===----------------------------------------------------------------------===##
#
# This script is the quickest path to running the Ryzen AI reference designs.
# Please have the Vitis tools and XRT environment setup before sourcing the 
# script.
#
# This is a modified version to set up environment after the initial setup script `init_setup.sh` 
# has been run at least once. Namely, this script does not remove prior installs.
#
# source ./utils/quick_setup.sh
#
##===----------------------------------------------------------------------===##

echo "Setting up RyzenAI developement tools..."
if [[ $WSL_DISTRO_NAME == "" ]]; then
  XRTSMI=`which xrt-smi`
  if ! test -f "$XRTSMI"; then 
    echo "XRT is not installed"
    return 1
  fi
  echo "Looking for NPU..."
  NPU=`/opt/xilinx/xrt/bin/xrt-smi examine | grep -w RyzenAI`
  if [[ $NPU == *"RyzenAI"* ]]; then
    echo "Ryzen AI NPU found:"
    echo $NPU
  else
    echo "NPU not found. Is the amdxdna driver installed?"
    return 1
  fi
else
  echo "Environment is WSL"
fi
if ! hash python3.10; then
   echo "This script requires python3.10"
   return 1
fi
if ! hash virtualenv; then
  echo "virtualenv is not installed"
  return 1
fi
if ! hash unzip; then
  echo "unzip is not installed"
  return 1
fi

python3 -m virtualenv ironenv

# The real path to source might depend on the virtualenv version
if [ -r ironenv/local/bin/activate ]; then
  source ironenv/local/bin/activate
else
  source ironenv/bin/activate
fi
VPP=`which xchesscc`
if test -f "$VPP"; then
  AIETOOLS="`dirname $VPP`/../aietools"
  mkdir -p my_install
  pushd my_install
  export PATH=`realpath llvm-aie/bin`:`realpath mlir_aie/bin`:`realpath mlir/bin`:$PATH
  export LD_LIBRARY_PATH=`realpath llvm-aie/lib`:`realpath mlir_aie/lib`:`realpath mlir/lib`:$LD_LIBRARY_PATH
  export PYTHONPATH=`realpath mlir_aie/python`:$PYTHONPATH
  export PEANO_DIR=`realpath llvm-aie`
  popd
  python3 -m pip install -r python/requirements.txt
  python3 -m pip install -r python/requirements_ml.txt
else
  echo "Vitis not found! Exiting..."
fi
