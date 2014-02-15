rm /home/gustavo/zips/*.zip
cp /home/gustavo/kernel/arch/arm/configs/kernel_defconfig /home/gustavo/kernel/.config
make -j3
find -name '*.ko' -exec cp -av {} /home/gustavo/kernel/usr/galaxys2_initramfs_files/modules/ \;
chmod 644 /home/gustavo/kernel/usr/galaxys2_initramfs_files/modules/*
/home/gustavo/toolchain/bin/arm-linux-androideabi-strip --strip-unneeded /home/gustavo/kernel/usr/galaxys2_initramfs_files/modules/*
make -j3 zImage CONFIG_INITRAMFS_SOURCE="/home/gustavo/kernel/usr/initramfs/cm-10.2_initramfs.list"
cp /home/gustavo/kernel/arch/arm/boot/zImage /home/gustavo/zip_tmp/
CURRENTDATE=$(date +"%d-%m")
cd /home/gustavo/zip_tmp
rm *.zip
zip -r kk-kernel-$CURRENTDATE-CWM.zip ./
cp ./*.zip /home/gustavo/zips/jb-kernel-$CURRENTDATE-CWM.zip
cd /home/gustavo/kernel
