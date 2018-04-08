#!/bin/bash

source /opt/crankshaft/crankshaft_default_env.sh
source /boot/crankshaft/crankshaft_env.sh

CS_BRIGHTNESS_FILE=/boot/crankshaft/brightness
LVL=`cat ${BRIGHTNESS_FILE}`

case $1 in
	level)
		echo $LVL
		;;
	save)
		if [ -f ${BRIGHTNESS_FILE} ]; then
			cat ${BRIGHTNESS_FILE} > ${CS_BRIGHTNESS_FILE}
		fi
		;;
	restore)
		if [ -f ${CS_BRIGHTNESS_FILE} ]; then
			cat ${CS_BRIGHTNESS_FILE} > ${BRIGHTNESS_FILE}
		else
			echo ${BR_MAX} > ${BRIGHTNESS_FILE}
		fi
		;;
	up)
		if [ $((${LVL} + ${BR_STEP})) -le ${BR_MAX} ]; then
			echo $((${LVL} + ${BR_STEP})) > ${BRIGHTNESS_FILE}
		fi
		;;
	down)
		if [ $((${LVL} - ${BR_STEP})) -ge ${BR_MIN} ]; then
			echo $((${LVL} - ${BR_STEP})) > ${BRIGHTNESS_FILE}
		fi
		;;
	set)
		echo $2 > ${BRIGHTNESS_FILE}
		;;
	set_min)
		echo ${BR_MIN} > ${BRIGHTNESS_FILE}
		;;
	set_max)
		echo ${BR_MAX} > ${BRIGHTNESS_FILE}
		;;
	get_file_location)
		echo ${BRIGHTNESS_FILE}
		;;
esac

exit 0
