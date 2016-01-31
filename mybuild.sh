#!/bin/sh

if [ -d OrangePI-Kernel ]; then
	(cd OrangePI-Kernel ; git pull)
else
	git clone https://github.com/loboris/OrangePI-Kernel.git
fi

TMPF=`mktemp -d /tmp/XXXOPI_$$`
CURD=`pwd`

end()
{
        rm -f $TMPF
        exit 0
}

trap end 9 2

if [ ! -f rootfs.cpio.gz ]; then
	echo "Building initram image"
	tar xzf rootfs.tgz -C $TMPF
	cp -f OrangePI-Kernel/build/rootfs-test1/lib/modules/3.4.39-030439-highbank/modules.order \
		${TMPF}/lib/modules/3.4.39-030439-highbank
	cd ${TMPF}/lib/modules/3.4.39-030439-highbank
	find kernel -name "*.ko" -print | sort > modules.builtin
	cd ../../../
	find . | cpio --quiet -o -H newc > ${CURD}/rootfs.cpio
	cd $CURD
	gzip rootfs.cpio
	if [ $? -gt 0 ]; then
		echo "Error creating initram image"
		exit 1
	else
		echo "OK creating initram image"
		ls -alF rootfs.cpio.gz
	fi
fi

echo "Updating kernel version"
# next line to be customized
perl -pi -e 's|^EXTRAVERSION.*|EXTRAVERSION = -1mni|' OrangePI-Kernel/linux-3.4/Makefile

# =====================================================
# After build uImage and lib are in output directory
# =====================================================
if [ -d output ]; then
  echo "Output folder exists, exiting..."
  exit 1
fi

echo "Start building the kernel"
LINKERNEL_DIR=`pwd`/OrangePI-Kernel/linux-3.4
LCC=`pwd`/OrangePI-Kernel/brandy/gcc-linaro/bin

export PATH="${LCC}":"$PATH"

sh ./build_kernel.sh $LINKERNEL_DIR
sh ./make_mali_driver.sh $LINKERNEL_DIR
sh ./make_nand_driver.sh $LINKERNEL_DIR

mv ${LINKERNEL_DIR}/output .
echo "Everything is in the output folder"

echo "Reversing kernel version"
cd OrangePI-Kernel/linux-3.4/
git checkout Makefile
cd ../..
