#!/system/bin/sh
# Logging
#/sbin/busybox cp /data/user.log /data/user.log.bak
#/sbin/busybox rm /data/user.log
#exec >>/data/user.log
#exec 2>&1

#!/sbin/busybox sh

# set up Synapse support
/sbin/uci;

# apply some of synapse defaults at boot
echo "0" > /sys/devices/virtual/sec/sec_touchscreen/tsp_slide2wake
echo "1" > /sys/module/alarm/parameters/debug_mask
echo "1200000" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
chmod 0664 /system/etc/gps.conf
if [ -f /data/gps.conf ]
	    then
	    mount -o remount,rw /system
	    mount -o remount,rw /data
	    chown system system /system/etc/gps.conf
        chmod 0660 /system/etc/gps.conf
	    cp /data/gps.conf /system/etc/gps.conf
	    chown system system /system/etc/gps.conf
        chmod 0660 /system/etc/gps.conf
        mount -o remount,ro /system	    
fi

# install kernel modules
mount -o remount,rw /system
rm /system/lib/modules/*.ko
cp /modules/dhd.ko /system/lib/modules/
cp /modules/Si4709_driver.ko /system/lib/modules/
cp /modules/auth_rpcgss.ko /system/lib/modules/
cp /modules/cifs.ko /system/lib/modules/
cp /modules/lockd.ko /system/lib/modules/
cp /modules/nfs.ko /system/lib/modules/
cp /modules/rpcsec_gss_krb5.ko /system/lib/modules/
cp /modules/sunrpc.ko /system/lib/modules/
cp /modules/scsi_wait_scan.ko /system/lib/modules/
chmod 0644 /system/lib/modules/*.ko

# system status
cp /res/systemstatus /system/bin/systemstatus
chown root.system /system/bin/systemstatus
chmod 0755 /system/bin/systemstatus

cp /res/systemcat /system/bin/systemcat
chown root.system /system/bin/systemcat
chmod 0755 /system/bin/systemcat

# install lights lib needed by BLN
rm /system/lib/hw/lights.exynos4.so
cp /res/lights.exynos4.so /system/lib/hw/lights.exynos4.so
chown root.root /system/lib/hw/lights.exynos4.so
chmod 0664 /system/lib/hw/lights.exynos4.so

# install modded sqlite
cp -a /res/libsqlite.so /system/lib/libsqlite.so
cp -a /res/sqlite3 /system/xbin/sqlite3
chmod 0644 /system/lib/libsqlite.so
chmod 0755 /system/xbin/sqlite3

mount -o remount,ro /system

# google dns
setprop net.dns1 8.8.8.8
setprop net.dns2 8.8.4.4

# set recommended KSM settings by google
echo "100" > /sys/kernel/mm/ksm/pages_to_scan
echo "500" > /sys/kernel/mm/ksm/sleep_millisecs

sysctl -w vm.dirty_background_ratio=5;
sysctl -w vm.dirty_ratio=10;
# low swapiness to use swap only when the system 
# is under extreme memory pressure
sysctl -w vm.swappiness=25;

##### init scripts #####
/system/bin/sh sh /sbin/ext/run-init-scripts.sh
