#!/bin/bash
# kernel build script by geiti94 v0.1 (made for s10e/s10/s10/n10/n10+ sources)

export MODEL=d2s
export VARIANT=eur
export ARCH=arm64
export BUILD_CROSS_COMPILE=/home/geiti94/Android/kernels/Toolchain/aarch64-linux-android-4.9/bin/aarch64-linux-android-
export BUILD_JOB_NUMBER=128

RDIR=$(pwd)
OUTDIR=$RDIR/arch/arm64/boot
DTSDIR=$RDIR/arch/arm64/boot/dts/exynos
DTBDIR=$OUTDIR/dtb
DTCTOOL=$RDIR/tools/mkdtimage
INCDIR=$RDIR/include

PAGE_SIZE=4096
DTB_PADDING=0

case $MODEL in
d2s)
	case $VARIANT in
	can|duos|eur|xx)
		KERNEL_DEFCONFIG=exynos9820-d2s_nemesis_defconfig
		;;
	*)
		echo "Unknown variant: $VARIANT"
		exit 1
		;;
	esac
;;
d2x)
	case $VARIANT in
	can|duos|eur|xx)
		KERNEL_DEFCONFIG=exynos9820-d2x_nemesis_defconfig
		;;
	*)
		echo "Unknown variant: $VARIANT"
		exit 1
		;;
	esac
;;
d1)
	case $VARIANT in
	can|duos|eur|xx)
		KERNEL_DEFCONFIG=exynos9820-d1_nemesis_defconfig
		;;
	*)
		echo "Unknown variant: $VARIANT"
		exit 1
		;;
	esac
;;
d1x)
	case $VARIANT in
	can|duos|eur|xx)
		KERNEL_DEFCONFIG=exynos9820-d1x_nemesis_defconfig
		;;
	*)
		echo "Unknown variant: $VARIANT"
		exit 1
		;;
	esac
;;
beyond2lte)
	case $VARIANT in
	can|duos|eur|xx)
		KERNEL_DEFCONFIG=exynos9820-beyond2lte_nemesis_defconfig
		;;
	*)
		echo "Unknown variant: $VARIANT"
		exit 1
		;;
	esac
;;
beyond1lte)
	case $VARIANT in
	can|duos|eur|xx)
		KERNEL_DEFCONFIG=exynos9820-beyond1lte_nemesis_defconfig
		;;
	*)
		echo "Unknown variant: $VARIANT"
		exit 1
		;;
	esac
;;
beyond0lte)
	case $VARIANT in
	can|duos|eur|xx)
		KERNEL_DEFCONFIG=exynos9820-beyond0lte_nemesis_defconfig
		;;
	*)
		echo "Unknown variant: $VARIANT"
		exit 1
		;;
	esac
;;
a50dd)
	case $VARIANT in
	can|duos|eur|xx)
		KERNEL_DEFCONFIG=exynos9610-a50_nemesis_defconfig
		;;
	*)
		echo "Unknown variant: $VARIANT"
		exit 1
		;;
	esac
;;
*)
	echo "Unknown device: $MODEL"
	exit 1
	;;
esac



FUNC_CLEAN_DTB()
{
	if ! [ -d $RDIR/arch/$ARCH/boot/dts ] ; then
		echo "no directory : "$RDIR/arch/$ARCH/boot/dts""
	else
		echo "rm files in : "$RDIR/arch/$ARCH/boot/dts/*.dtb""
		rm $RDIR/arch/$ARCH/boot/dts/*.dtb
		rm $RDIR/arch/$ARCH/boot/dtb/*.dtb
		rm $RDIR/arch/$ARCH/boot/boot.img-dtb
		rm $RDIR/arch/$ARCH/boot/boot.img-zImage
	fi
}

FUNC_BUILD_KERNEL()
{
	echo ""
        echo "=============================================="
        echo "START : FUNC_BUILD_KERNEL"
        echo "=============================================="
        echo ""
        echo "build common config="$KERNEL_DEFCONFIG ""
        echo "build model config="$MODEL ""


	export ANDROID_MAJOR_VERSION=p


	make -j$BUILD_JOB_NUMBER ARCH=$ARCH \
			CROSS_COMPILE=$BUILD_CROSS_COMPILE \
			$KERNEL_DEFCONFIG || exit -1

	make -j$BUILD_JOB_NUMBER ARCH=$ARCH \
			CROSS_COMPILE=$BUILD_CROSS_COMPILE || exit -1

	echo "Generating dtb.img..."
	$RDIR/tools/mkdtimg create "$OUTDIR/dt.img" --page_size=$PAGE_SIZE "$DTSDIR/*dtb"

	echo "Generating dtbo.img..."
	$RDIR/tools/mkdtimg create "$OUTDIR/dtbo.img" --page_size=$PAGE_SIZE "$DTSDIR/*dtbo"


	
	echo ""
	echo "================================="
	echo "END   : FUNC_BUILD_KERNEL"
	echo "================================="
	echo ""
}

# MAIN FUNCTION
rm -rf ./build.log
(
	START_TIME=`date +%s`

	FUNC_BUILD_KERNEL

	END_TIME=`date +%s`
	
	let "ELAPSED_TIME=$END_TIME-$START_TIME"
	echo "Total compile time was $ELAPSED_TIME seconds"

) 2>&1	| tee -a ./build.log
