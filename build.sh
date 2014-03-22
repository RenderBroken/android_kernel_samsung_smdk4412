#!/bin/bash

TOOLCHAIN="/media/storage/android/source/toolchains/arm-cortex_a9-linux-gnueabihf-linaro_4.7.4-2014.01/bin/arm-cortex_a9-linux-gnueabihf-"
STRIP="/media/storage/android/source/toolchains/arm-cortex_a9-linux-gnueabihf-linaro_4.7.4-2014.01/bin/arm-gnueabi-strip"
OUTDIR="out"
CONFIG="kernel_defconfig"
KK_CWM_INITRAMFS_SOURCE="/media/storage/android/source/smdk4412/usr/initramfs/cwm-i777.list"
KK_TWRP_INITRAMFS_SOURCE="/media/storage/android/source/smdk4412/usr/initramfs/twrp-i777.list"
JB_INITRAMFS_SOURCE="/media/storage/android/source/smdk4412/usr/initramfs/jb-i777.list"
RAMDISK="/media/storage/android/source/smdk4412/ramdisk"
RAMDISK_OUT="/media/storage/android/source/smdk4412/usr/initramfs/ramdisk-i777.cpio"
MODULES=("/media/storage/android/source/smdk4412/net/sunrpc/auth_gss/auth_rpcgss.ko" "/media/storage/android/source/smdk4412/fs/cifs/cifs.ko" "drivers/net/wireless/bcmdhd/dhd.ko" "/media/storage/android/source/smdk4412/fs/lockd/lockd.ko" "/media/storage/android/source/smdk4412/fs/nfs/nfs.ko" "/media/storage/android/source/smdk4412/net/sunrpc/auth_gss/rpcsec_gss_krb5.ko" "drivers/scsi/scsi_wait_scan.ko" "drivers/samsung/fm_si4709/Si4709_driver.ko" "/media/storage/android/source/smdk4412/net/sunrpc/sunrpc.ko")
KERNEL_DIR="/media/storage/android/source/smdk4412"
MODULES_DIR="/media/storage/android/source/smdk4412/usr/galaxys2_initramfs_files/modules"
CURRENTDATE=$(date +"%m-%d")

case "$1" in
	clean)
        cd ${KERNEL_DIR}
        make clean && make mrproper
		;;
	kk)
        # compress the ramdisk in cpio
        cd ${RAMDISK}
        rm *.cpio
        find . -not -name ".gitignore" | cpio -o -H newc > ${RAMDISK_OUT}
        
        cd ${KERNEL_DIR}
        make -j8 kernel_defconfig ARCH=arm CROSS_COMPILE=${TOOLCHAIN}

        # build modules first to include them into android ramdisk
        make -j8 ARCH=arm CROSS_COMPILE=${TOOLCHAIN} modules
       
        for module in "${MODULES[@]}" ; do
            cp "${module}" ${MODULES_DIR}
            ${STRIP} --strip-unneeded ${MODULES_DIR}/*
        done
      
        # build the CWM kernel
        cd ${KERNEL_DIR}
        make -j8 ARCH=arm CROSS_COMPILE=${TOOLCHAIN} CONFIG_INITRAMFS_SOURCE=${KK_CWM_INITRAMFS_SOURCE}
        cp arch/arm/boot/zImage ${OUTDIR}
        cd ${OUTDIR}
		echo "Creating kk CWM kernel zip..."
        zip -r kk-kernel-$CURRENTDATE-CWM.zip ./ -x *.zip /system/* *.gitignore
        # build the TWRP kernel
        cd ${KERNEL_DIR}
        make -j8 ARCH=arm CROSS_COMPILE=${TOOLCHAIN} CONFIG_INITRAMFS_SOURCE=${KK_TWRP_INITRAMFS_SOURCE}
        cp arch/arm/boot/zImage ${OUTDIR}
        cd ${OUTDIR}
		echo "Creating kk TWRP kernel zip..."
        zip -r kk-kernel-$CURRENTDATE-TWRP.zip ./ -x *.zip /system/* *.gitignore
        
		echo "Done!"
	    ;;
	  jb)
	    cd ${KERNEL_DIR}
        make kernel_defconfig ARCH=arm CROSS_COMPILE=${TOOLCHAIN}

        # build modules first to include them into android ramdisk
        make -j8 ARCH=arm CROSS_COMPILE=${TOOLCHAIN} modules
       
        for module in "${MODULES[@]}" ; do
            cp "${module}" ${MODULES_DIR}
            ${STRIP} --strip-unneeded ${MODULES_DIR}/*
        done
      
        # build the jelly bean kernel
        cd ${KERNEL_DIR}
        make -j8 ARCH=arm CROSS_COMPILE=${TOOLCHAIN} CONFIG_INITRAMFS_SOURCE=${JB_INITRAMFS_SOURCE} zImage
        cp arch/arm/boot/zImage ${OUTDIR}
        cd ${OUTDIR}
		echo "Creating jb kernel zip..."
        zip -r jb-kernel-$CURRENTDATE.zip ./ -x *.zip *.gitignore
        
        echo "Done!"
esac
