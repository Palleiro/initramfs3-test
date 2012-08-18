#!/sbin/busybox sh

#Credits:
# Zacharias.maladroit
# Voku1987
# Collin_ph@xda
# Dorimanx@xda
# Gokhanmoral@xda
# Johnbeetee

# TAKE NOTE THAT LINES PRECEDED BY A "#" IS COMMENTED OUT!
# This script must be activated after init start =< 25sec or parameters from /sys/* will not be loaded!

# read setting from profile

# Get values from profile. since we dont have the recovery source code i cant change the .siyah dir, so just leave it there for history.
PROFILE=`cat /data/.siyah/.active.profile`;
. /data/.siyah/$PROFILE.profile;

FILE_NAME=$0;
PIDOFCORTEX=$$;

# default settings (1000 = 10 seconds)
dirty_expire_centisecs_default=1000;
dirty_writeback_centisecs_default=1000;

# battery settings
dirty_expire_centisecs_battery=0;
dirty_writeback_centisecs_battery=0;

# static sets for functions, they will be changes by other functions later
if [[ "$PROFILE" == "performance" ]]; then
	MORE_SPEED=1;
	MORE_BATTERY=0;
	DEFAULT_SPEED=0;
elif [[ "$PROFILE" == "default" ]]; then
	MORE_SPEED=0;
	DEFAULT_SPEED=1;
	MORE_BATTERY=0;
else
	MORE_BATTERY=1;
	MORE_SPEED=0;
	DEFAULT_SPEED=0;
fi;

# ==============================================================
# Touch Screen tweaks
# ==============================================================

TOUCHSCREENTUNE() 
{
	# touch sensitivity settings. - by GokhanMoral
	# not needed any more, we have extweaks interface for it! 
	# -> so never enable it!
	(
	# offset 59: MXT224_THRESHOLD_BATT_INIT
	kmemhelper -n mxt224_data -t char -o 59 50
	# offset 60: MXT224_THRESHOLD_CHRG
	kmemhelper -n mxt224_data -t char -o 60 55
	# offset 61: MXT224_NOISE_THRESHOLD_BATT
	kmemhelper -n mxt224_data -t char -o 61 30
	# offset 62: MXT224_NOISE_THRESHOLD_CHRG
	kmemhelper -n mxt224_data -t char -o 62 40
	# offset 63: MXT224_MOVFILTER_BATT
	kmemhelper -n mxt224_data -t char -o 63 11
	# offset 64: MXT224_MOVFILTER_CHRG
	kmemhelper -n mxt224_data -t char -o 64 46
	# offset 67: MXT224E_THRESHOLD_BATT
	kmemhelper -n mxt224_data -t char -o 67 50
	# offset 77: MXT224E_MOVFILTER_BATT
	kmemhelper -n mxt224_data -t char -o 77 46
	)&
}
#TOUCHSCREENTUNE; #DISABLED for good, but it's good info. so no delete.

# =========
# Renice - kernel thread responsible for managing the swap memory and logs
# =========
renice 19 `pidof kswapd0`;
renice 19 `pgrep logcat`;

# ==============================================================
# I/O-TWEAKS 
# ==============================================================
IO_TWEAKS()
{
	MMC=`ls -d /sys/block/mmc*`;
	ZRM=`ls -d /sys/block/zram*`;

	for z in $ZRM; do

		if [ -e $i/queue/rotational ]; then
			echo "0" > $i/queue/rotational;
		fi;

		if [ -e $i/queue/iostats ]; then
			echo "0" > $i/queue/iostats;
		fi;

		if [ -e $i/queue/rq_affinity ]; then
			echo "1" > $i/queue/rq_affinity;
		fi;

		if [ -e $i/queue/read_ahead_kb ]; then
			echo "512" >  $i/queue/read_ahead_kb;
		fi;

		if [ -e $i/queue/max_sectors_kb ]; then
			echo "512" >  $i/queue/max_sectors_kb; # default: 127
		fi;

	done;

	for i in $MMC; do

		if [ -e $i/queue/scheduler ]; then
			echo $scheduler > $i/queue/scheduler;
		fi;

		if [ -e $i/queue/rotational ]; then
			echo "0" > $i/queue/rotational;
		fi;

		if [ -e $i/queue/iostats ]; then
			echo "0" > $i/queue/iostats;
		fi;

		if [ -e $i/queue/rq_affinity ]; then
			echo "1" > $i/queue/rq_affinity;   
		fi;

		if [ -e $i/queue/read_ahead_kb ]; then
			echo "1024" >  $i/queue/read_ahead_kb; # default: 128
		fi;

		if [ -e $i/queue/max_sectors_kb ]; then
			echo "1024" >  $i/queue/max_sectors_kb; # default: 512
		fi;

		if [ -e $i/queue/nr_requests ]; then
			echo "128" > $i/queue/nr_requests; # default: 128
		fi;

		if [ -e $i/queue/iosched/writes_starved ]; then
			echo "1" > $i/queue/iosched/writes_starved;
		fi;

		if [ -e $i/queue/iosched/back_seek_max ]; then
			echo "16384" > $i/queue/iosched/back_seek_max; # default: 16384
		fi;

		if [ -e $i/queue/iosched/max_budget_async_rq ]; then
			echo "2" > $i/queue/iosched/max_budget_async_rq; # default: 4
		fi;

		if [ -e $i/queue/iosched/back_seek_penalty ]; then
			echo "1" > $i/queue/iosched/back_seek_penalty; # default: 2
		fi;

		if [ -e $i/queue/iosched/fifo_expire_sync ]; then
			echo "125" > $i/queue/iosched/fifo_expire_sync; # default: 125
		fi;

		if [ -e $i/queue/iosched/timeout_sync ]; then
			echo "4" > $i/queue/iosched/timeout_sync; # default: HZ / 8
		fi;

		if [ -e $i/queue/iosched/fifo_expire_async ]; then
			echo "250" > $i/queue/iosched/fifo_expire_async; # default: 250
		fi;

		if [ -e $i/queue/iosched/timeout_async ]; then
			echo "2" > $i/queue/iosched/timeout_async; # default: HZ / 25
		fi;

		if [ -e $i/queue/iosched/slice_idle ]; then
			echo "2" > $i/queue/iosched/slice_idle; # default: 8
		fi;

		if [ -e $i/queue/iosched/quantum ]; then
			echo "8" > $i/queue/iosched/quantum; # default: 4
		fi;

		if [ -e $i/queue/iosched/slice_async_rq ]; then
			echo "2" > $i/queue/iosched/slice_async_rq; # default: 2
		fi;

		if [ -e $i/queue/iosched/fifo_batch ]; then
			echo "1" > $i/queue/iosched/fifo_batch;
		fi;

		if [ -e $i/queue/iosched/rev_penalty ]; then
			echo "1" > $i/queue/iosched/rev_penalty;
		fi;

		if [ -e $i/queue/iosched/low_latency ]; then
			echo "1" > $i/queue/iosched/low_latency;
		fi;

	done;

	if [ -e /sys/devices/virtual/bdi/default/read_ahead_kb ]; then
		echo "512" > /sys/devices/virtual/bdi/default/read_ahead_kb;
	fi;

	SDCARDREADAHEAD=`ls -d /sys/devices/virtual/bdi/179*`;
	for i in $SDCARDREADAHEAD; do
		echo "1024" > $i/read_ahead_kb;
	done;

	echo "15" > /proc/sys/fs/lease-break-time;

	log -p i -t $FILE_NAME "*** filesystem tweaks ***: enabled";
}
if [ $cortexbrain_io == on ]; then
	IO_TWEAKS;
fi;

# ==============================================================
# KERNEL-TWEAKS
# ==============================================================
KERNEL_TWEAKS()
{
	echo "1" > /proc/sys/vm/oom_kill_allocating_task;
	sysctl -w vm.panic_on_oom=0;

	log -p i -t $FILE_NAME "*** kernel tweaks ***: enabled";
}
if [ $cortexbrain_kernel_tweaks == on ]; then
	KERNEL_TWEAKS;
fi;

# ==============================================================
# SYSTEM-TWEAKS
# ==============================================================
SYSTEM_TWEAKS()
{
	# enable Hardware Rendering
	#setprop video.accelerate.hw 1;
	#setprop debug.performance.tuning 1;
	#setprop debug.sf.hw 1;
	setprop persist.sys.use_dithering 1;
	#setprop persist.sys.ui.hw true; # ->reported as problem maker in some roms.

	# render UI with GPU
	setprop hwui.render_dirty_regions false;
	setprop windowsmgr.max_events_per_sec 120;
	setprop profiler.force_disable_err_rpt 1;
	setprop profiler.force_disable_ulog 1;

	# Proximity tweak
	setprop mot.proximity.delay 15;

	# more Tweaks
	setprop dalvik.vm.execution-mode int:jit;
	setprop persist.adb.notify 0;
	setprop pm.sleep_mode 1;

	if [ "`getprop dalvik.vm.heapsize | sed 's/m//g'`" -lt 120 ]; then
		setprop dalvik.vm.heapsize 128m
	fi;

	log -p i -t $FILE_NAME "*** system tweaks ***: enabled";
}
if [ $cortexbrain_system == on ]; then
	SYSTEM_TWEAKS;
fi;

# ==============================================================
# EXTWEAKS FIXING
# ==============================================================

# apply last led_timeout set on boot to fix the timeout reset.
/res/uci.sh led_timeout $led_timeout;

# ==============================================================
# CLEANING-TWEAKS
# ==============================================================
rm -rf /data/lost+found/* 2> /dev/null;
rm -rf /system/lost+found/* 2> /dev/null;
rm -rf /preload/lost+found/* 2> /dev/null;
rm -rf /cache/lost+found/* 2> /dev/null;
rm -rf /data/tombstones/* 2> /dev/null;
rm -rf /data/anr/* 2> /dev/null;

# ==============================================================
# BATTERY-TWEAKS
# ==============================================================

# block access to debugger memory dumps writes, 
# save power and safe flash drive
chmod 400 /data/tombstones -R
chown drm:drm /data/tombstones -R

# allow writing to critical folders
chmod 777 /data/anr -R
chown system:system /data/anr -R

BATTERY_TWEAKS()
{
	# battery-calibration if battery is full
	LEVEL=`cat /sys/class/power_supply/battery/capacity`;
	CURR_ADC=`cat /sys/class/power_supply/battery/batt_current_adc`;
	BATTFULL=`cat /sys/class/power_supply/battery/batt_full_check`;
	echo "*** LEVEL: $LEVEL - CUR: $CURR_ADC ***"
	if [ "$LEVEL" == "100" ] && [ "$BATTFULL" == "1" ]; then
		rm -f /data/system/batterystats.bin;
		echo "battery-calibration done ...";
	fi;

	# WIFI PM-FAST support
	if [ -e /sys/module/dhd/parameters/wifi_pm ]; then
		echo "1" > /sys/module/dhd/parameters/wifi_pm;
	fi;

	# LCD Power-Reduce
	if [ -e /sys/class/lcd/panel/power_reduce ]; then
		echo "1" > /sys/class/lcd/panel/power_reduce;
	fi;

	# USB power support
	for i in `ls /sys/bus/usb/devices/*/power/level`; do
		chmod 777 $i;
		echo "auto" > $i;
	done;
	for i in `ls /sys/bus/usb/devices/*/power/autosuspend`; do
		chmod 777 $i;
		echo "1" > $i;
	done;

	# BUS power support
	buslist="spi i2c sdio";
	for bus in $buslist; do
		for i in `ls /sys/bus/$bus/devices/*/power/control`; do
			chmod 777 $i;
			echo "auto" > $i;
		done;
	done;

	log -p i -t $FILE_NAME "*** battery tweaks ***: enabled";
}
if [ $cortexbrain_battery == on ]; then
	BATTERY_TWEAKS;
fi;

# ==============================================================
# CPU-LUZACTIVE FIX
# ==============================================================

SYSTEM_GOVERNOR=`cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor`
if [ $SYSTEM_GOVERNOR == "lulzactive" ]; then
	echo "${scaling_max_freq}" > /sys/devices/virtual/sec/sec_touchscreen/tsp_touch_freq;
fi;

# ==============================================================
# CPU-TWEAKS
# ==============================================================

CPU_GOV_TWEAKS()
{
	SYSTEM_GOVERNOR=`cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor`

	if [ $MORE_BATTERY == 1 ]; then

		if [ $SYSTEM_GOVERNOR == "HYPER" ]; then
			echo "120000" > /sys/devices/system/cpu/cpufreq/HYPER/sampling_rate;
			echo "90" > /sys/devices/system/cpu/cpufreq/HYPER/up_threshold;
			echo "90" > /sys/devices/system/cpu/cpufreq/HYPER/up_threshold_min_freq;
			echo "1" > /sys/devices/system/cpu/cpufreq/HYPER/sampling_down_factor;
			echo "5" > /sys/devices/system/cpu/cpufreq/HYPER/down_differential;
			echo "20" > /sys/devices/system/cpu/cpufreq/HYPER/freq_step;
			echo "200000" > /sys/devices/system/cpu/cpufreq/HYPER/freq_responsiveness;
		fi;

		if [ $SYSTEM_GOVERNOR == "ondemand" ]; then
			echo "120000" > /sys/devices/system/cpu/cpufreq/ondemand/sampling_rate;
			echo "90" > /sys/devices/system/cpu/cpufreq/ondemand/up_threshold;
			echo "5" > /sys/devices/system/cpu/cpufreq/ondemand/down_differential;
			echo "1" > /sys/devices/system/cpu/cpufreq/ondemand/sampling_down_factor;
			echo "20" > /sys/devices/system/cpu/cpufreq/ondemand/freq_step;
		fi;

		if [ $SYSTEM_GOVERNOR == "conservative" ]; then
			echo "120000" > /sys/devices/system/cpu/cpufreq/ondemand/sampling_rate;
			echo "20" > /sys/devices/system/cpu/cpufreq/conservative/freq_step;
			echo "1" > /sys/devices/system/cpu/cpufreq/conservative/sampling_down_factor;
			echo "40" > /sys/devices/system/cpu/cpufreq/conservative/down_threshold;
			echo "90" > /sys/devices/system/cpu/cpufreq/conservative/up_threshold;
		fi;

		if [ $SYSTEM_GOVERNOR == "abyssplug" ]; then
			echo "1" > /sys/devices/system/cpu/cpufreq/abyssplug/down_differential;
			echo "40" > /sys/devices/system/cpu/cpufreq/abyssplug/down_threshold;
			echo "90" > /sys/devices/system/cpu/cpufreq/abyssplug/up_threshold;
		fi;

		if [ $SYSTEM_GOVERNOR == "pegasusq" ]; then
			echo "120000" > /sys/devices/system/cpu/cpufreq/pegasusq/sampling_rate;
			echo "90" > /sys/devices/system/cpu/cpufreq/pegasusq/up_threshold;
			echo "2" > /sys/devices/system/cpu/cpufreq/pegasusq/sampling_down_factor;
			echo "5" > /sys/devices/system/cpu/cpufreq/pegasusq/down_differential;
			echo "20" > /sys/devices/system/cpu/cpufreq/pegasusq/freq_step;
			echo "10" > /sys/devices/system/cpu/cpufreq/pegasusq/cpu_up_rate;
			echo "10" > /sys/devices/system/cpu/cpufreq/pegasusq/cpu_down_rate;
			echo "300000" > /sys/devices/system/cpu/cpufreq/pegasusq/hotplug_freq_1_1;
			echo "200000" > /sys/devices/system/cpu/cpufreq/pegasusq/hotplug_freq_2_0;
			echo "250" > /sys/devices/system/cpu/cpufreq/pegasusq/hotplug_rq_1_1;
			echo "240" > /sys/devices/system/cpu/cpufreq/pegasusq/hotplug_rq_2_0;
			echo "95" > /sys/devices/system/cpu/cpufreq/pegasusq/up_threshold_at_min_freq;
			echo "200000" > /sys/devices/system/cpu/cpufreq/pegasusq/freq_for_responsiveness;
			echo "0" > /sys/devices/system/cpu/cpufreq/pegasusq/max_cpu_lock;
			echo "0" > /sys/devices/system/cpu/cpufreq/pegasusq/dvfs debug;
			echo "0" > /sys/devices/system/cpu/cpufreq/pegasusq/hotplug_lock;
		fi;

	elif [ $DEFAULT_SPEED == 1 ]; then

		if [ $SYSTEM_GOVERNOR == "lulzactive" ]; then
			echo "${scaling_max_freq}" > /sys/devices/virtual/sec/sec_touchscreen/tsp_touch_freq;
		fi;

		if [ $SYSTEM_GOVERNOR == "HYPER" ]; then
			echo "100000" > /sys/devices/system/cpu/cpufreq/HYPER/sampling_rate;
			echo "80" > /sys/devices/system/cpu/cpufreq/HYPER/up_threshold;
			echo "70" > /sys/devices/system/cpu/cpufreq/HYPER/up_threshold_min_freq;
			echo "1" > /sys/devices/system/cpu/cpufreq/HYPER/sampling_down_factor;
			echo "5" > /sys/devices/system/cpu/cpufreq/HYPER/down_differential;
			echo "20" > /sys/devices/system/cpu/cpufreq/HYPER/freq_step;
			echo "200000" > /sys/devices/system/cpu/cpufreq/HYPER/freq_responsiveness;
		fi;

		if [ $SYSTEM_GOVERNOR == "ondemand" ]; then
			echo "100000" > /sys/devices/system/cpu/cpufreq/ondemand/sampling_rate;
			echo "80" > /sys/devices/system/cpu/cpufreq/ondemand/up_threshold;
			echo "5" > /sys/devices/system/cpu/cpufreq/ondemand/down_differential;
			echo "1" > /sys/devices/system/cpu/cpufreq/ondemand/sampling_down_factor;
			echo "30" > /sys/devices/system/cpu/cpufreq/ondemand/freq_step;
		fi;

		if [ $SYSTEM_GOVERNOR == "conservative" ]; then
			echo "40" > /sys/devices/system/cpu/cpufreq/conservative/freq_step;
			echo "1" > /sys/devices/system/cpu/cpufreq/conservative/sampling_down_factor;
			echo "30" > /sys/devices/system/cpu/cpufreq/conservative/down_threshold;
			echo "80" > /sys/devices/system/cpu/cpufreq/conservative/up_threshold;
		fi;

		if [ $SYSTEM_GOVERNOR == "abyssplug" ]; then
			echo "5" > /sys/devices/system/cpu/cpufreq/abyssplug/down_differential;
			echo "30" > /sys/devices/system/cpu/cpufreq/abyssplug/down_threshold;
			echo "80" > /sys/devices/system/cpu/cpufreq/abyssplug/up_threshold;
		fi;

		if [ $SYSTEM_GOVERNOR == "pegasusq" ]; then
			echo "100000" > /sys/devices/system/cpu/cpufreq/pegasusq/sampling_rate;
			echo "80" > /sys/devices/system/cpu/cpufreq/pegasusq/up_threshold;
			echo "2" > /sys/devices/system/cpu/cpufreq/pegasusq/sampling_down_factor;
			echo "5" > /sys/devices/system/cpu/cpufreq/pegasusq/down_differential;
			echo "40" > /sys/devices/system/cpu/cpufreq/pegasusq/freq_step;
			echo "${load_l1}" > /sys/devices/system/cpu/cpufreq/pegasusq/cpu_down_rate
			echo "${load_h0}" > /sys/devices/system/cpu/cpufreq/pegasusq/cpu_up_rate
			echo "500000" > /sys/devices/system/cpu/cpufreq/pegasusq/hotplug_freq_1_1;
			echo "200000" > /sys/devices/system/cpu/cpufreq/pegasusq/hotplug_freq_2_0;
			echo "250" > /sys/devices/system/cpu/cpufreq/pegasusq/hotplug_rq_1_1;
			echo "240" > /sys/devices/system/cpu/cpufreq/pegasusq/hotplug_rq_2_0;
			echo "80" > /sys/devices/system/cpu/cpufreq/pegasusq/up_threshold_at_min_freq;
			echo "200000" > /sys/devices/system/cpu/cpufreq/pegasusq/freq_for_responsiveness;
			echo "0" > /sys/devices/system/cpu/cpufreq/pegasusq/max_cpu_lock;
			echo "0" > /sys/devices/system/cpu/cpufreq/pegasusq/dvfs debug;
			echo "0" > /sys/devices/system/cpu/cpufreq/pegasusq/hotplug_lock;
		fi;

	elif [ $MORE_SPEED == 1 ]; then

		if [ $SYSTEM_GOVERNOR == "lulzactive" ]; then
			echo "${scaling_max_freq}" > /sys/devices/virtual/sec/sec_touchscreen/tsp_touch_freq;
		fi;

		if [ $SYSTEM_GOVERNOR == "HYPER" ]; then
			echo "50000" > /sys/devices/system/cpu/cpufreq/HYPER/sampling_rate;
			echo "60" > /sys/devices/system/cpu/cpufreq/HYPER/up_threshold;
			echo "60" > /sys/devices/system/cpu/cpufreq/HYPER/up_threshold_min_freq;
			echo "1" > /sys/devices/system/cpu/cpufreq/HYPER/sampling_down_factor;
			echo "5" > /sys/devices/system/cpu/cpufreq/HYPER/down_differential;
			echo "40" > /sys/devices/system/cpu/cpufreq/HYPER/freq_step;
			echo "200000" > /sys/devices/system/cpu/cpufreq/HYPER/freq_responsiveness;
		fi;

		if [ $SYSTEM_GOVERNOR == "ondemand" ]; then
			echo "50000" > /sys/devices/system/cpu/cpufreq/ondemand/sampling_rate;
			echo "60" > /sys/devices/system/cpu/cpufreq/ondemand/up_threshold;
			echo "5" > /sys/devices/system/cpu/cpufreq/ondemand/down_differential;
			echo "1" > /sys/devices/system/cpu/cpufreq/ondemand/sampling_down_factor;
			echo "40" > /sys/devices/system/cpu/cpufreq/ondemand/freq_step;
		fi;

		if [ $SYSTEM_GOVERNOR == "conservative" ]; then
			echo "50" > /sys/devices/system/cpu/cpufreq/conservative/freq_step;
			echo "1" > /sys/devices/system/cpu/cpufreq/conservative/sampling_down_factor;
			echo "20" > /sys/devices/system/cpu/cpufreq/conservative/down_threshold;
			echo "60" > /sys/devices/system/cpu/cpufreq/conservative/up_threshold;
		fi;

		if [ $SYSTEM_GOVERNOR == "abyssplug" ]; then
			echo "5" > /sys/devices/system/cpu/cpufreq/abyssplug/down_differential;
			echo "20" > /sys/devices/system/cpu/cpufreq/abyssplug/down_threshold;
			echo "60" > /sys/devices/system/cpu/cpufreq/abyssplug/up_threshold;
		fi;

		if [ $SYSTEM_GOVERNOR == "pegasusq" ]; then
			echo "50000" > /sys/devices/system/cpu/cpufreq/pegasusq/sampling_rate;
			echo "60" > /sys/devices/system/cpu/cpufreq/pegasusq/up_threshold;
			echo "2" > /sys/devices/system/cpu/cpufreq/pegasusq/sampling_down_factor;
			echo "5" > /sys/devices/system/cpu/cpufreq/pegasusq/down_differential;
			echo "40" > /sys/devices/system/cpu/cpufreq/pegasusq/freq_step;
			echo "${load_l1}" > /sys/devices/system/cpu/cpufreq/pegasusq/cpu_down_rate;
			echo "${load_h0}" > /sys/devices/system/cpu/cpufreq/pegasusq/cpu_up_rate;
			echo "500000" > /sys/devices/system/cpu/cpufreq/pegasusq/hotplug_freq_1_1;
			echo "200000" > /sys/devices/system/cpu/cpufreq/pegasusq/hotplug_freq_2_0;
			echo "250" > /sys/devices/system/cpu/cpufreq/pegasusq/hotplug_rq_1_1;
			echo "240" > /sys/devices/system/cpu/cpufreq/pegasusq/hotplug_rq_2_0;
			echo "70" > /sys/devices/system/cpu/cpufreq/pegasusq/up_threshold_at_min_freq;
			echo "400000" > /sys/devices/system/cpu/cpufreq/pegasusq/freq_for_responsiveness;
			echo "0" > /sys/devices/system/cpu/cpufreq/pegasusq/max_cpu_lock;
			echo "0" > /sys/devices/system/cpu/cpufreq/pegasusq/dvfs debug;
			echo "0" > /sys/devices/system/cpu/cpufreq/pegasusq/hotplug_lock;
		fi;
	fi;

	log -p i -t $FILE_NAME "*** cpu gov tweaks ***: enabled";
}
if [ $cortexbrain_cpu == on ]; then
	CPU_GOV_TWEAKS;
fi;

# ==============================================================
# MEMORY-TWEAKS
# ==============================================================
MEMORY_TWEAKS()
{
	echo "$dirty_expire_centisecs_default" > /proc/sys/vm/dirty_expire_centisecs;
	echo "$dirty_writeback_centisecs_default" > /proc/sys/vm/dirty_writeback_centisecs;
	echo "20" > /proc/sys/vm/dirty_background_ratio; # default: 10
	echo "20" > /proc/sys/vm/dirty_ratio; # default: 20
	echo "4" > /proc/sys/vm/min_free_order_shift; # default: 4
	echo "0" > /proc/sys/vm/overcommit_memory; # default: 0
	echo "1000" > /proc/sys/vm/overcommit_ratio; # default: 50
	echo "96 96" > /proc/sys/vm/lowmem_reserve_ratio;
	echo "3" > /proc/sys/vm/page-cluster; # default: 3
	echo "4096" > /proc/sys/vm/min_free_kbytes
	echo "65530" > /proc/sys/vm/max_map_count;
	echo "250 32000 32 128" > /proc/sys/kernel/sem; # default: 250 32000 32 128

	log -p i -t $FILE_NAME "*** memory tweaks ***: enabled";
}
if [ $cortexbrain_memory == on ]; then
	MEMORY_TWEAKS;
fi;

# ==============================================================
# TCP-TWEAKS
# ==============================================================
TCP_TWEAKS()
{
	echo "0" > /proc/sys/net/ipv4/tcp_timestamps;
	echo "1" > /proc/sys/net/ipv4/tcp_tw_reuse;
	echo "1" > /proc/sys/net/ipv4/tcp_sack;
	echo "1" > /proc/sys/net/ipv4/tcp_tw_recycle;
	echo "1" > /proc/sys/net/ipv4/tcp_window_scaling;
	echo "1" > /proc/sys/net/ipv4/tcp_moderate_rcvbuf;
	echo "1" > /proc/sys/net/ipv4/route/flush;
	echo "2" > /proc/sys/net/ipv4/tcp_syn_retries;
	echo "2" > /proc/sys/net/ipv4/tcp_synack_retries;
	echo "10" > /proc/sys/net/ipv4/tcp_fin_timeout;
	echo "0" > /proc/sys/net/ipv4/tcp_ecn;
	echo "256960" > /proc/sys/net/core/wmem_max;
	echo "563200" > /proc/sys/net/core/rmem_max;
	echo "256960" > /proc/sys/net/core/rmem_default;
	echo "256960" > /proc/sys/net/core/wmem_default;
	echo "20480" > /proc/sys/net/core/optmem_max;
	echo "4096 16384 110208" > /proc/sys/net/ipv4/tcp_wmem;
	echo "4096 87380 563200" > /proc/sys/net/ipv4/tcp_rmem;
	echo "4096" > /proc/sys/net/ipv4/udp_rmem_min;
	echo "4096" > /proc/sys/net/ipv4/udp_wmem_min;
	setprop net.tcp.buffersize.default 4096,87380,563200,4096,16384,110208;
	setprop net.tcp.buffersize.wifi    4095,87380,563200,4096,16384,110208;
	setprop net.tcp.buffersize.umts    4094,87380,563200,4096,16384,110208;
	setprop net.tcp.buffersize.edge    4093,26280,35040,4096,16384,35040;
	setprop net.tcp.buffersize.gprs    4092,8760,11680,4096,8760,11680;
	setprop net.tcp.buffersize.evdo_b  4094,87380,262144,4096,16384,262144;
	setprop net.tcp.buffersize.hspa    4092,87380,563200,4096,16384,110208;

	log -p i -t $FILE_NAME "*** tcp tweaks ***: enabled";
}
if [ $cortexbrain_tcp == on ]; then
	TCP_TWEAKS;
fi;

# ==============================================================
# FIREWALL-TWEAKS
# ==============================================================
FIREWALL_TWEAKS()
{
	# ping/icmp protection
	echo "1" > /proc/sys/net/ipv4/icmp_echo_ignore_broadcasts;
	echo "1" > /proc/sys/net/ipv4/icmp_echo_ignore_all;
	echo "1" > /proc/sys/net/ipv4/icmp_ignore_bogus_error_responses;

	if [ -e /proc/sys/net/ipv6/icmp_echo_ignore_broadcasts ]; then
		echo "1" > /proc/sys/net/ipv6/icmp_echo_ignore_broadcasts;
	fi;

	if [ -e /proc/sys/net/ipv6/icmp_echo_ignore_all ]; then
		echo "1" > /proc/sys/net/ipv6/icmp_echo_ignore_all;
	fi;

	if [ -e /proc/sys/net/ipv6/icmp_ignore_bogus_error_responses ]; then
		echo "1" > /proc/sys/net/ipv6/icmp_ignore_bogus_error_responses;
	fi;

	# syn protection
	if [ -e /proc/sys/net/ipv4/tcp_synack_retries ]; then
		echo "10" > /proc/sys/net/ipv4/tcp_synack_retries;
	fi;

	if [ -e /proc/sys/net/ipv6/tcp_synack_retries ]; then
		echo "10" > /proc/sys/net/ipv6/tcp_synack_retries;
	fi;

	if [ -e /proc/sys/net/ipv6/tcp_syncookies ]; then
		echo "0" > /proc/sys/net/ipv6/tcp_syncookies;
	fi;

	if [ -e /proc/sys/net/ipv4/tcp_syncookies ]; then
		echo "3" > /proc/sys/net/ipv4/tcp_syncookies;
	fi;

	# IPv6 privacy tweak
	echo "2" > /proc/sys/net/ipv6/conf/all/use_tempaddr;

	# drop spoof, redirects, etc
	echo "1" > /proc/sys/net/ipv4/conf/all/rp_filter;
	echo "1" > /proc/sys/net/ipv4/conf/default/rp_filter;
	echo "0" > /proc/sys/net/ipv4/conf/all/send_redirects;
	echo "0" > /proc/sys/net/ipv4/conf/default/send_redirects;
	echo "0" > /proc/sys/net/ipv4/conf/default/accept_redirects;
	echo "0" > /proc/sys/net/ipv4/conf/all/accept_source_route;
	echo "0" > /proc/sys/net/ipv4/conf/default/accept_source_route;

	if [ -e /proc/sys/net/ipv6/conf/all/rp_filter ]; then
		echo "1" > /proc/sys/net/ipv6/conf/all/rp_filter;
	fi;

	if [ -e /proc/sys/net/ipv6/conf/default/rp_filter ]; then
		echo "1" > /proc/sys/net/ipv6/conf/default/rp_filter;
	fi;

	if [ -e /proc/sys/net/ipv6/conf/all/send_redirects ]; then
		echo "0" > /proc/sys/net/ipv6/conf/all/send_redirects;
	fi;

	if [ -e /proc/sys/net/ipv6/conf/default/send_redirects ]; then
		echo "0" > /proc/sys/net/ipv6/conf/default/send_redirects;
	fi;

	if [ -e /proc/sys/net/ipv6/conf/default/accept_redirects ]; then
		echo "0" > /proc/sys/net/ipv6/conf/default/accept_redirects;
	fi;

	if [ -e /proc/sys/net/ipv6/conf/all/accept_source_route ]; then
		echo "0" > /proc/sys/net/ipv6/conf/all/accept_source_route;
	fi;

	if [ -e /proc/sys/net/ipv6/conf/default/accept_source_route ]; then
		echo "0" > /proc/sys/net/ipv6/conf/default/accept_source_route;
	fi;

	log -p i -t $FILE_NAME "*** firewall-tweaks ***: enabled";
}
if [ $cortexbrain_firewall == on ]; then
	FIREWALL_TWEAKS;
fi;


# ==============================================================
# ROOT: Install function.
# ==============================================================

ROOT_INSTALL_NOW ()
{

if [ -e /data/.siyah/root_install ] && [ ! -e /system/xbin/su ]; then

	# Extract Payload with root files.
	/sbin/busybox mount -o remount,rw /dev/block/mmcblk0p9 /system > /dev/null 2>&1
	/sbin/busybox mount -t rootfs -o remount,rw rootfs
	/sbin/busybox chmod 755 /sbin/read_boot_headers
	eval $(/sbin/read_boot_headers /dev/block/mmcblk0p5)
	load_offset=$boot_offset
	load_len=$boot_len
	cd /
	dd bs=512 if=/dev/block/mmcblk0p5 skip=$load_offset count=$load_len | tar x

	# Clean su traces.
	/sbin/busybox rm -f /system/bin/su > /dev/null 2>&1
	/sbin/busybox rm -f /system/xbin/su > /dev/null 2>&1
	/sbin/busybox mkdir /system/xbin > /dev/null 2>&1
	/sbin/busybox chmod 755 /system/xbin

	# Extract SU binary.
	/sbin/busybox xzcat /res/misc/payload/su.xz > /system/xbin/su
	/sbin/busybox chown 0.0 /system/xbin/su
	/sbin/busybox chmod 6755 /system/xbin/su

	# Clean super user old apps.
	/sbin/busybox rm -f /system/app/*uper?ser.apk > /dev/null 2>&1
	/sbin/busybox rm -f /system/app/?uper?u.apk > /dev/null 2>&1
	/sbin/busybox rm -f /system/app/*chainfire?supersu*.apk > /dev/null 2>&1
	/sbin/busybox rm -f /data/app/*uper?ser.apk > /dev/null 2>&1
	/sbin/busybox rm -f /data/app/?uper?u.apk > /dev/null 2>&1
	/sbin/busybox rm -f /data/app/*chainfire?supersu*.apk > /dev/null 2>&1
	/sbin/busybox rm -rf /data/dalvik-cache/*uper?ser.apk* > /dev/null 2>&1
	/sbin/busybox rm -rf /data/dalvik-cache/*chainfire?supersu*.apk* > /dev/null 2>&1

	# extract super user app.
	/sbin/busybox xzcat /res/misc/payload/Superuser.apk.xz > /system/app/Superuser.apk
	/sbin/busybox chown 0.0 /system/app/Superuser.apk
	/sbin/busybox chmod 644 /system/app/Superuser.apk

	# Restore witch if exist
	if [ -e /system/xbin/waswhich-bkp ]; then
		/sbin/busybox rm -f /system/xbin/which > /dev/null 2>&1
		/sbin/busybox cp /system/xbin/waswhich-bkp /system/xbin/which > /dev/null 2>&1
		/sbin/busybox chmod 755 /system/xbin/which > /dev/null 2>&1
	fi;

	if [ -e /system/xbin/boxman ]; then
		/sbin/busybox rm -f /system/xbin/busybox > /dev/null 2>&1
		/sbin/busybox mv /system/xbin/boxman /system/xbin/busybox > /dev/null 2>&1
		/sbin/busybox chmod 755 /system/xbin/busybox > /dev/null 2>&1
		/sbin/busybox mv /system/bin/boxman /system/bin/busybox > /dev/null 2>&1
		/sbin/busybox chmod 755 /system/bin/busybox > /dev/null 2>&1
	fi;

	# Delete payload and kill superuser pid.
	/sbin/busybox rm -rf /res/misc/payload
	/sbin/busybox rm -f /data/.siyah/root_install
	pkill -f "com.noshufou.android.su" > /dev/null 2>&1
fi;
}

# ==============================================================
# TWEAKS: if Screen-ON
# ==============================================================
AWAKE_MODE()
{
	# set CPU-Governor
	echo "${scaling_governor}" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor;

	# set second core online
	echo "on" > /sys/devices/virtual/misc/second_core/second_core_on;

	# boost wakeup!
	if [ $scaling_max_freq \> 800000 ]; then
		echo "${scaling_max_freq}" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq;
		echo "800000" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq;
	else
		echo "1200000" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq;
		echo "800000" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq;
	fi;

	if [ $gesture_tweak == "on" ]; then
		# check if running already
		if [ `pgrep -f "gesture_set.sh" |  wc -l` \< 1 ]; then
			/sbin/busybox sh /data/gesture_set.sh
		fi;
	fi;

	# set lock screen freq to max scalling freq.
	SYSTEM_GOVERNOR=`cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor`;
	if [ $SYSTEM_GOVERNOR == lulzactive ]; then
		echo "${scaling_max_freq}" > /sys/devices/virtual/sec/sec_touchscreen/tsp_touch_freq;
	else
		echo "${tsp_touch_freq}" > /sys/devices/virtual/sec/sec_touchscreen/tsp_touch_freq;
	fi;

	# Bus-Freq for awake state
	echo "${busfreq_up_threshold}" > /sys/devices/system/cpu/cpufreq/busfreq_up_threshold;

	# set I/O-Scheduler
	echo "${scheduler}" > /sys/block/mmcblk0/queue/scheduler;
	echo "${scheduler}" > /sys/block/mmcblk1/queue/scheduler;

	if [[ "$PROFILE" == "performance" ]]; then
		MORE_SPEED=1;
		MORE_BATTERY=0;
		DEFAULT_SPEED=0;
	elif [[ "$PROFILE" == "default" ]]; then
		MORE_SPEED=0;
		DEFAULT_SPEED=1;
		MORE_BATTERY=0;
	else
		MORE_BATTERY=1;
		MORE_SPEED=0;
		DEFAULT_SPEED=0;
	fi;

	if [ $cortexbrain_cpu == on ]; then
		CPU_GOV_TWEAKS;
	fi;

	sleep 6;

	# set cpu
	if [ "${secondcore}" == "hotplug" ]; then
		echo "on" > /sys/devices/virtual/misc/second_core/hotplug_on;
	else
		echo "off" > /sys/devices/virtual/misc/second_core/hotplug_on;
	fi;

	if [ "${secondcore}" == "always-off" ]; then
		echo "off" > /sys/devices/virtual/misc/second_core/second_core_on;
	fi;

	if [ "${secondcore}" == "always-on" ]; then
		echo "on" > /sys/devices/virtual/misc/second_core/second_core_on;
	fi;

	# set CPU speed
	echo "${scaling_min_freq}" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq;
	echo "${scaling_max_freq}" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq;

	# cpu-settings for second core
	echo "${load_h0}" > /sys/module/stand_hotplug/parameters/load_h0;
	echo "${load_l1}" > /sys/module/stand_hotplug/parameters/load_l1;

	# set wifi.supplicant_scan_interval
	setprop wifi.supplicant_scan_interval $supplicant_scan_interval;

	# set default values
	echo "${dirty_expire_centisecs_default}" > /proc/sys/vm/dirty_expire_centisecs;
	echo "${dirty_writeback_centisecs_default}" > /proc/sys/vm/dirty_writeback_centisecs;

	# enable NMI Watchdog to detect hangs
	if [ -e /proc/sys/kernel/nmi_watchdog ]; then
		echo "1" > /proc/sys/kernel/nmi_watchdog; 
	fi;

	# fs settings 
	echo "25" > /proc/sys/vm/vfs_cache_pressure;

	# enable WIFI-driver if screen is on
	if [ $wifiON == 1 ]; then
		if [ $cortexbrain_auto_tweak_wifi == on ]; then
			svc wifi enable;
		fi;
	fi;

	# set the vibrator - force in case it's has been reseted
	echo "${pwm_val}" > /sys/vibrator/pwm_val;

	# auto set brightness
	if [ $cortexbrain_auto_tweak_brightness == on ]; then
		LEVEL=`cat /sys/class/power_supply/battery/capacity`;
		MAX_BRIGHTNESS=`cat /sys/class/backlight/panel/max_brightness`;
		OLD_BRIGHTNESS=`cat /sys/class/backlight/panel/brightness`;
		NEW_BRIGHTNESS=`$(( MAX_BRIGHTNESS*LEVEL/100 ))`;
		if [ $NEW_BRIGHTNESS -le $OLD_BRIGHTNESS ]; then	
			echo "$NEW_BRIGHTNESS" > /sys/class/backlight/panel/brightness;
		fi;
	fi;

	if [ $cortexbrain_battery == on ]; then
		BATTERY_TWEAKS;
	fi;

	log -p i -t $FILE_NAME "*** AWAKE Mode ***";
}

# ==============================================================
# TWEAKS: if Screen-OFF
# ==============================================================
SLEEP_MODE()
{
	# set CPU-Governor
	echo "${deep_sleep}" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor;

	# reduce deepsleep CPU speed, SUSPEND mode
	echo "${scaling_min_suspend_freq}" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_suspend_freq;
	echo "${scaling_max_suspend_freq}" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_suspend_freq;
	echo "${scaling_max_suspend_freq}" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq;

	# set disk I/O sched to noop simple and battery saving.
	echo "noop" > /sys/block/mmcblk0/queue/scheduler;
	echo "noop" > /sys/block/mmcblk1/queue/scheduler;

	if [ $cortexbrain_cpu == on ]; then
		MORE_BATTERY=1;
		MORE_SPEED=0;
		DEFAULT_SPEED=0;
		CPU_GOV_TWEAKS;
	fi;

	# disable second core
	echo "off" > /sys/devices/virtual/misc/second_core/hotplug_on;
	echo "off" > /sys/devices/virtual/misc/second_core/second_core_on;

	# set wifi.supplicant_scan_interval
	if [ $supplicant_scan_interval -lt 180 ]; then
		setprop wifi.supplicant_scan_interval 180;
	fi;

	# Bus Freq for deep sleep
	echo "30" > /sys/devices/system/cpu/cpufreq/busfreq_up_threshold;

	# set settings for battery -> don't wake up "pdflush daemon"
	echo "${dirty_expire_centisecs_battery}" > /proc/sys/vm/dirty_expire_centisecs;
	echo "${dirty_writeback_centisecs_battery}" > /proc/sys/vm/dirty_writeback_centisecs;

	# disable NMI Watchdog to detect hangs
	if [ -e /proc/sys/kernel/nmi_watchdog ]; then
		echo "0" > /proc/sys/kernel/nmi_watchdog;
	fi;

	# set battery value
	echo "10" > /proc/sys/vm/vfs_cache_pressure; # default: 100

	# disable WIFI-driver if screen is off
	wifiOFF=`cat /sys/module/dhd/initstate`;
	if [ "a$wifiOFF" != "a" ]; then
		if [ $cortexbrain_auto_tweak_wifi == on ]; then
			svc wifi disable;
			wifiON=1;
		fi;
	else
		wifiON=0;
	fi;

	if [ $cortexbrain_battery == on ]; then
		BATTERY_TWEAKS;
	fi;

	log -p i -t $FILE_NAME "*** SLEEP mode ***";
}

# ==============================================================
# Background gesture process control
# ==============================================================

GESTURE_FUNCTION_OFF ()
{
	# shutdown gestures loop on screen off, we dont need it.
	pkill -f "gesture_set.sh"
	pkill -f "/sys/devices/virtual/misc/touch_gestures/wait_for_gesture"
}

# ==============================================================
# Background process to check screen state
# ==============================================================

# Dynamic Value do not change/delete
cortexbrain_background_process=1

if [ $cortexbrain_background_process == 1 ] && [ `pgrep -f "/sbin/ext/cortexbrain-tune.sh" |  wc -l` \< 3 ]; then
	(while [ 1 ]; do
		# AWAKE State! all system ON!
		PIDOFCORTEX=`pgrep -f "/sbin/ext/cortexbrain-tune.sh"`;
		for i in $PIDOFCORTEX; do
			echo "-600" > /proc/$i/oom_score_adj;
		done;
		STATE=`$(cat /sys/power/wait_for_fb_wake)`;
		PROFILE=`cat /data/.siyah/.active.profile`;
		. /data/.siyah/$PROFILE.profile;
		AWAKE_MODE;
		sleep 15;

		# SLEEP state! All system to power save!
		STATE=`$(cat /sys/power/wait_for_fb_sleep)`;
		PROFILE=`cat /data/.siyah/.active.profile`;
		. /data/.siyah/$PROFILE.profile;
		echo "${standby_freq}" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq;
		# Install ROOT is requested!
		ROOT_INSTALL_NOW
		GESTURE_FUNCTION_OFF
		CHARGING=`cat /sys/class/power_supply/battery/charging_source`;
		if [ ! "$CHARGING" -ge "1" ]; then
			SLEEP_MODE;
		fi;
	done &);
else
	echo "Cortex background process already running";
fi;

# ==============================================================
# Logic Explanations
#
# This script will manipulate all the system / cpu / battery behavior
# Based on chosen EXTWEAKS profile+tweaks and based on SCREEN ON/OFF state.
#
# When User select battery/default profile all tuning will be toward battery save!
# But user loose performance -20% and get more stable system and more battery left.
#
# When user select performance profile, tuning will be to max performance on screen ON!
# When screen OFF all tuning switched to max power saving! as with battery profile,
# So user gets max performance and max battery save but only on screen OFF.
#
# This script change governors and tuning for them on the fly!
# Also switch on/off hotplug CPU core based on screen on/off.
# This script reset battery stats when battery is 100% charged.
# This script tune Network and System VM settings and ROM settings tuning.
# This script changing default MOUNT options and I/O tweaks for all flash disks and ZRAM.
#
# TODO: add more description, explanations & default vaules ...
#
