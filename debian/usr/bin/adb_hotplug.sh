#!/bin/sh
# it is for adb hotplug and udc missed issue...
# just tmp solution by udev rules.
#
# SoC-agnostic: x3 uses gadget g1 + UDC b2000000.dwc3,
# x5 uses gadget g_comp + UDC 35300000.usb. Discover both
# dynamically instead of hardcoding.

# pick the first available UDC controller name
for u in /sys/class/udc/*; do
	[ -e "$u" ] || continue
	udc_name=$(basename "$u")
	break
done

[ -n "$udc_name" ] || exit 0

# re-bind any gadget instance whose UDC is currently empty
for gad_udc in /sys/kernel/config/usb_gadget/*/UDC; do
	[ -e "$gad_udc" ] || continue
	cur=$(cat "$gad_udc" 2>/dev/null)
	if [ -z "$cur" ]; then
		echo "$udc_name" > "$gad_udc" 2>/dev/null
	fi
done
