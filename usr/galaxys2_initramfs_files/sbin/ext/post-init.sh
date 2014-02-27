#!/system/bin/sh
# Logging
#/sbin/busybox cp /data/user.log /data/user.log.bak
#/sbin/busybox rm /data/user.log
#exec >>/data/user.log
#exec 2>&1

#!/sbin/busybox sh

mkdir /data/.siyah
chmod 0777 /data/.siyah

. /res/customconfig/customconfig-helper

ccxmlsum=`md5sum /res/customconfig/customconfig.xml | awk '{print $1}'`
if [ "a${ccxmlsum}" != "a`cat /data/.siyah/.ccxmlsum`" ];
then
  rm -f /data/.siyah/*.profile
  echo ${ccxmlsum} > /data/.siyah/.ccxmlsum
fi
[ ! -f /data/.siyah/default.profile ] && cp /res/customconfig/default.profile /data/.siyah

read_defaults
read_config

# disable debugging on some modules
if [ "$logger" == "off" ];then
  rm -rf /dev/log
  echo 0 > /sys/module/ump/parameters/ump_debug_level
  echo 0 > /sys/module/mali/parameters/mali_debug_level
  echo 0 > /sys/module/kernel/parameters/initcall_debug
  echo 0 > /sys//module/lowmemorykiller/parameters/debug_level
  echo 0 > /sys/module/earlysuspend/parameters/debug_mask
  echo 0 > /sys/module/alarm/parameters/debug_mask
  echo 0 > /sys/module/alarm_dev/parameters/debug_mask
  echo 0 > /sys/module/binder/parameters/debug_mask
  echo 0 > /sys/module/xt_qtaguid/parameters/debug_mask
fi

#apply last soundgasm level on boot
/res/uci.sh soundgasm_hp $soundgasm_hp

# apply STweaks defaults
/res/uci.sh apply

#usb mode
/res/customconfig/actions/usb-mode ${usb_mode}

# install kernel modules
mount -o remount,rw /system
rm /system/lib/modules/*.ko
# install wifi module
cp /modules/dhd.ko /system/lib/modules/
# install fm radio module
cp /modules/Si4709_driver.ko /system/lib/modules/
# check if optional modules should be installed
if [ "$cifs" == "on" ];then
cp /modules/auth_rpcgss.ko /system/lib/modules/
cp /modules/cifs.ko /system/lib/modules/
cp /modules/lockd.ko /system/lib/modules/
cp /modules/nfs.ko /system/lib/modules/
cp /modules/rpcsec_gss_krb5.ko /system/lib/modules/
cp /modules/sunrpc.ko /system/lib/modules/
fi
if [ "$scsi" == "on" ];then
cp /modules/scsi_wait_scan.ko /system/lib/modules/
fi

cp /modules/*.ko /system/lib/modules/
chmod 0644 /system/lib/modules/*.ko

### Disables Built In Error Reporting
setprop profiler.force_disable_err_rpt 1
setprop profiler.force_disable_ulog 1

# gpu watch
cp /res/gpuwatch /system/bin/gpuwatch
chown root.system /system/bin/gpuwatch
chmod 0755 /system/bin/gpuwatch

cp /res/gpucat /system/bin/gpucat
chown root.system /system/bin/gpucat
chmod 0755 /system/bin/gpucat

# install lights lib needed by BLN
rm /system/lib/hw/lights.exynos4.so
cp /res/lights.exynos4.so /system/lib/hw/lights.exynos4.so
chown root.root /system/lib/hw/lights.exynos4.so
chmod 0664 /system/lib/hw/lights.exynos4.so
mount -o remount,ro /system

# google dns
setprop net.dns1 8.8.8.8
setprop net.dns2 8.8.4.4

# set recommended KSM settings by google
echo "100" > /sys/kernel/mm/ksm/pages_to_scan
echo "500" > /sys/kernel/mm/ksm/sleep_millisecs

sysctl -w vm.dirty_background_ratio=10;
sysctl -w vm.dirty_ratio=20;
# low swapiness to use swap only when the system 
# is under extreme memory pressure
sysctl -w vm.swappiness=25;

##### init scripts #####
/system/bin/sh sh /sbin/ext/run-init-scripts.sh
