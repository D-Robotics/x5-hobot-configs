#!/bin/bash

LOG_ERR=3
LOG_WARN=4
LOG_NOTICE=5
LOG_INFO=6
LOG_DEBUG=7
ops_module=("20510500.sif_qos" "7" "7"
	"20510280.isp_qos" "7" "7"
	"20510100.dw230_qos" "7" "7"
	"20540080.gpu3d_qos" "0" "0"
	"20520000.bpu_qos" "0" "0"
	"20540000.gpu2d_qos" "0" "0"
	"20550100.gmac_qos" "0" "0"
	"20510000.bt1120_qos" "0" "0"
	"20510080.dc8000_qos" "0" "0"
	"20530000.video_qos" "0" "0"
	"20530080.jpeg_qos" "0" "0")

function write_read_check_list() {
	local _i=0
	local _read_v=
	local _base_path="/sys/bus/platform/drivers/noc_qos"
	local _readp_path="read_priority_qos_ctrl/priority"
	local _writep_path="write_priority_qos_ctrl/priority"

	for (( _i=0;_i<${#ops_module[@]};_i+=3 )); do
		local _module=${ops_module[$_i]}
		local _read_qos=${ops_module[$_i+1]}
		local _write_qos=${ops_module[$_i+2]}
		if [ ! -f ${_base_path}/${_module}/${_readp_path} ] ||
		   [ ! -f ${_base_path}/${_module}/${_writep_path} ];then
			echo -n "<$LOG_WARN>${_module} QoS not initialized! Skipping!" > /dev/kmsg
			continue
		fi
		echo ${_read_qos} > ${_base_path}/${_module}/${_readp_path}
		_read_v=$(cat ${_base_path}/${_module}/${_readp_path})
		if [[ "${_read_qos}" != "${_read_v: -1}" ]]; then
			echo -n "<$LOG_ERR>Config ${_module} read qos fail(${_read_qos} != ${_read_v: -1}), please check it" > /dev/kmsg
		fi

		echo ${_write_qos} > ${_base_path}/${_module}/${_writep_path}
		_read_v=$(cat ${_base_path}/${_module}/${_writep_path})
		if [[ "${_write_qos}" != "${_read_v: -1}" ]]; then
			echo -n "<$LOG_ERR>Config ${_module} write qos fail(${_write_qos} != ${_read_v: -1}), please check it" > /dev/kmsg
		fi
		echo -n "<$LOG_INFO>Config ${_module} qos read: ${_read_qos} write: ${_write_qos} done" > /dev/kmsg
	done
}

case "$1" in
	start)
		write_read_check_list
		;;
	stop)
		;;
	restart)
		;;
	*)
		echo "Usage: $0 {start}"
		exit 1
		;;
esac

exit 0
