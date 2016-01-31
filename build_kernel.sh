#!/bin/bash

cross_comp="arm-linux-gnueabi"

#=========================================================

LINKERNEL_DIR=$1

cd ${LINKERNEL_DIR}

# build rootfs
mkdir -p output
rm -rf output/*
mkdir -p output/lib
cp -f ../../rootfs.cpio.gz output/

#==================================================================================
make_kernel() {
    # ############
    # Build kernel
    # ############

    echo "Building kernel for OrangePI-plus ..."
    echo "  Cleaning ..."
    make ARCH=arm CROSS_COMPILE=${cross_comp}- mrproper
    cd modules/nand
    make ARCH=arm CROSS_COMPILE=${cross_comp}- clean
    cd ../../
    echo "  Configuring ..."
    #make ARCH=arm CROSS_COMPILE=${cross_comp}- sun8iw7p1smp_lobo_defconfig
    #if [ $? -ne 0 ]; then
    #    echo "  Error: KERNEL NOT BUILT."
    #    exit 1
    #fi
    echo " Updating configuration ..."
    cp -f ../../config .config

    sleep 1

    # #############################################################################
    # build kernel (use -jN, where N is number of cores you can spare for building)
    echo "  Building kernel & modules ..."
    make -j4 ARCH=arm CROSS_COMPILE=${cross_comp}- uImage modules
    #rm modules/*
    if [ $? -ne 0 ]; then
	echo "  Error: KERNEL building has encountered a glitch...let's check uImage file"
    fi
    if [ -f arch/arm/boot/uImage ]; then
	echo "  OK, the kernel was built."
    else
        echo "  Error: KERNEL NOT BUILT."
        exit 1
    fi
    sleep 1

    # ########################
    # export modules to output
    echo "  Exporting modules ..."
    rm -rf output/lib/*
    make ARCH=arm CROSS_COMPILE=${cross_comp}- INSTALL_MOD_PATH=output modules_install
    if [ $? -ne 0 ] || [ ! -d output/lib/modules ]; then
        echo "  Error installing MODULES"
    fi
    echo "  Exporting firmware ..."
    make ARCH=arm CROSS_COMPILE=${cross_comp}- INSTALL_MOD_PATH=output firmware_install
    if [ $? -ne 0 ] || [ ! -d output/lib/firmware ]; then
        echo "  Error installing FIRMWARE"
    fi
    sleep 1

    # #####################
    # Copy uImage to output
    export KERNEL_VERSION=`make ARCH=arm CROSS_COMPILE=${cross_comp}- -s kernelversion -C ./`
    cp arch/arm/boot/uImage output/uImage-$KERNEL_VERSION
    cd output
    ln -sf uImage-$KERNEL_VERSION uImage
 
    cp -f ${LINKERNEL_DIR}/.config ${LINKERNEL_DIR}/output/config-$KERNEL_VERSION
    cp ${LINKERNEL_DIR}/System.map ${LINKERNEL_DIR}/output/System.map-$KERNEL_VERSION
    rm -f ${LINKERNEL_DIR}/output/lib/modules/${KERNEL_VERSION}/{build,source}
}

#==================================================================================
make_debian_package() {
	cd ${LINKERNEL_DIR}
	echo "Building debian packages for OrangePI-plus ..."
	echo "make ARCH=arm CROSS_COMPILE=${cross_comp}- KBUILD_DEBARCH=armhf deb-pkg"
	make ARCH=arm CROSS_COMPILE=${cross_comp}- KBUILD_DEBARCH=armhf deb-pkg
	if [ $? -ne 0 ]; then
	      echo "  Error: building Debian packages"
	else
		echo "Debian packages were created"
		exit 1
    	fi
	cd ..
}
#==================================================================================

make_kernel
#make_debian_package

echo "***OK***"
