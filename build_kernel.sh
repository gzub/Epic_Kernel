#/bin/bash

echo "$1 $2 $3"

case "$1" in
	Clean)
		echo "********************************************************************************"
		echo "* Clean Kernel                                                                 *"
		echo "********************************************************************************"

		pushd Kernel
		make clean V=1 ARCH=arm CROSS_COMPILE=$TOOLCHAIN/$TOOLCHAIN_PREFIX 2>&1 | tee make.clean.out
		popd
		echo " It's done... "
		exit
		;;
	*)
		PROJECT_NAME=SPH-D700
		HW_BOARD_REV="03"
		;;
esac

if [ "$CPU_JOB_NUM" = "" ] ; then
	CPU_JOB_NUM=8
fi

TARGET_LOCALE="vzw"

TOOLCHAIN=$ARM_TOOLCHAIN
TOOLCHAIN_PREFIX=$ARM_TOOLCHAIN_PREFIX

KERNEL_BUILD_DIR=$ANDROID_KERNEL_BUILD
ANDROID_OUT_DIR=$ANDROID_SYSTEM_BUILD/out/target/product/epic

export PRJROOT=$PWD
export PROJECT_NAME
export HW_BOARD_REV

export LD_LIBRARY_PATH=.:${TOOLCHAIN}/../lib

echo "************************************************************"
echo "* EXPORT VARIABLE		                            	 *"
echo "************************************************************"
echo "PRJROOT=$PRJROOT"
echo "PROJECT_NAME=$PROJECT_NAME"
echo "HW_BOARD_REV=$HW_BOARD_REV"
echo "************************************************************"

BUILD_MODULE()
{
	echo "************************************************************"
	echo "* BUILD_MODULE	                                       	 *"
	echo "************************************************************"
	echo

	pushd Kernel
		make ARCH=arm modules
	popd
}

BUILD_KERNEL()
{
	echo "************************************************************"
	echo "*        BUILD_KERNEL                                      *"
	echo "************************************************************"
	echo

	pushd $KERNEL_BUILD_DIR

	export KDIR=`pwd`
	export ARCH=arm

	cp $ANDROID_KERNEL_CONFIG $KERNEL_BUILD_DIR/arch/$ARCH/configs/temp_defconfig

	make ARCH=$ARCH temp_defconfig 

	make V=1 -j$CPU_JOB_NUM ARCH=arm CROSS_COMPILE=$TOOLCHAIN/$TOOLCHAIN_PREFIX 2>&1 | tee $COMPILEDBG

	rm $KERNEL_BUILD_DIR/arch/$ARCH/configs/temp_defconfig

	popd
}

# print title
PRINT_USAGE()
{
	echo "************************************************************"
	echo "* PLEASE TRY AGAIN                                         *"
	echo "************************************************************"
	echo
}

PRINT_TITLE()
{
	echo
	echo "************************************************************"
	echo "*                     MAKE PACKAGES"
	echo "************************************************************"
	echo "* 1. kernel : zImage"
	echo "* 2. modules"
	echo "************************************************************"
}

##############################################################
#                   MAIN FUNCTION                            #
##############################################################
if [ $# -gt 3 ]
then
	echo
	echo "**************************************************************"
	echo "*  Option Error                                              *"
	PRINT_USAGE
	exit 1
fi

START_TIME=`date +%s`

PRINT_TITLE

BUILD_KERNEL
END_TIME=`date +%s`
let "ELAPSED_TIME=$END_TIME-$START_TIME"
echo "Total compile time is $ELAPSED_TIME seconds"

