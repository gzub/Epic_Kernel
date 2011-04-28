#/bin/bash

echo "$1 $2 $3"

if [ "$CPU_JOB_NUM" = "" ] ; then
	CPU_JOB_NUM=8
fi


TARGET_LOCALE="vzw"
TARGET=arm
TOOLCHAIN=$ARM_TOOLCHAIN
TOOLCHAIN_PREFIX=$ARM_TOOLCHAIN_PREFIX
KERNEL_BUILD_DIR=$ANDROID_KERNEL_BUILD
ANDROID_OUT_DIR=$ANDROID_SYSTEM_BUILD/out/target/product/epic
BUILDARGS="V=1 -j$CPU_JOB_NUM ARCH=$TARGET CROSS_COMPILE=$TOOLCHAIN/$TOOLCHAIN_PREFIX"
CLEANARGS="-j$CPU_JOB_NUM ARCH=$TARGET CROSS_COMPILE=$TOOLCHAIN/$TOOLCHAIN_PREFIX"
export LD_LIBRARY_PATH=.:${TOOLCHAIN}/../lib

case "$1" in
	Clean)
		echo "********************************************************************************"
		echo "* Clean Kernel                                                                 *"
		echo "********************************************************************************"

		pushd $KERNEL_BUILD_DIR >> /dev/null
		make clean $CLEANARGS
		popd >> /dev/null
		echo " It's done... "
		exit
		;;
	*)
		PROJECT_NAME=SPH-D700
		HW_BOARD_REV="03"
		;;
esac

echo "************************************************************"
echo "* EXPORT VARIABLE		                            	     *"
echo "************************************************************"
echo "PRJROOT=$KERNEL_BUILD_DIR"
echo "PROJECT_NAME=$PROJECT_NAME"
echo "HW_BOARD_REV=$HW_BOARD_REV"
echo "************************************************************"

BUILD_MODULE()
{
	echo "************************************************************"
	echo "* BUILD_MODULE	                                       	 *"
	echo "************************************************************"
	echo

	pushd $KERNEL_BUILD_DIR >> /dev/null
		make ARCH=$TARGET modules $BUILDARGS
	popd >> /dev/null
}

BUILD_KERNEL()
{
	echo "************************************************************"
	echo "*        BUILD_KERNEL                                      *"
	echo "************************************************************"
	echo

	pushd $KERNEL_BUILD_DIR >> /dev/null

	cp $ANDROID_KERNEL_CONFIG $KERNEL_BUILD_DIR/arch/$TARGET/configs/temp_defconfig

	make ARCH=$TARGET temp_defconfig 

	make $BUILDARGS 2>&1 | tee $COMPILEDBG

	rm $KERNEL_BUILD_DIR/arch/$TARGET/configs/temp_defconfig

	popd >> /dev/null
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

