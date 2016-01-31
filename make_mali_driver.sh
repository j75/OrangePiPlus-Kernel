#!/bin/bash

echo "  Building mali drivers..."

cross_comp="arm-linux-gnueabi"

cd $1

export LICHEE_PLATFORM=linux
export KERNEL_VERSION=`make ARCH=arm CROSS_COMPILE=${cross_comp}- -s kernelversion -C ./`

LICHEE_KDIR=`pwd`
KDIR=`pwd`
export LICHEE_MOD_DIR=${LICHEE_KDIR}/output/lib/modules/${KERNEL_VERSION}
mkdir -p $LICHEE_MOD_DIR/kernel/drivers/gpu/mali
mkdir -p $LICHEE_MOD_DIR/kernel/drivers/gpu/ump

export LICHEE_KDIR
export MOD_DIR=${LICHEE_KDIR}/output/lib/modules/${KERNEL_VERSION}
export KDIR

cd modules/mali
make ARCH=arm CROSS_COMPILE=${cross_comp}- clean
if [ $? -ne 0 ]; then
    echo "  Error: clean."
    exit 1
fi
make ARCH=arm CROSS_COMPILE=${cross_comp}- build
if [ $? -ne 0 ]; then
    echo "  Error: build."
    exit 1
fi
make ARCH=arm CROSS_COMPILE=${cross_comp}- install
if [ $? -ne 0 ]; then
    echo "  Error: install."
    exit 1
fi

cd ../..

echo "  mali build OK."
exit 0
