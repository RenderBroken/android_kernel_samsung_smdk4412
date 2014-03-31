cat << CTAG
{
    name:I/O,
    elements:[
    { STitleBar:{
		title:"I/O Settings"
	}},
	{ SOptionList:{
		title:"Internal storage scheduler",
		default:sio,
		action:"bracket-option /sys/block/mmcblk0/queue/scheduler",
		values:[
`
			for IOSCHED in \`cat /sys/block/mmcblk0/queue/scheduler | sed -e 's/\]//;s/\[//'\`; do
			  echo "\"$IOSCHED\","
			done
`
		]
	}},
	{ SSeekBar:{
		title:"Internal storage read-ahead buffer",
		description:"The read-ahead value on the internal phone memory.",
		max:4096, min:128, unit:" kB", step:128,
		default:128,
                action:"generic /sys/devices/virtual/bdi/179:0/read_ahead_kb",
	}},







   ]
}

CTAG
