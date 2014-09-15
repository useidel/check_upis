#!/bin/bash
# UPiS mount plugin for Nagios
# Written by Udo Seidel
# Last Modified: 15-Sep-2014
#
# Description:
#
# This plugin will check the status of a UPiS connected to the RPi
#
# Location of the sudo and i2cget command (if not in path)
SUDO="/usr/bin/sudo"
I2CGET="/usr/sbin/i2cget"

# sudo is needed if i2cget cannot be executed by the nagios 
# user context w/o sudo granted priviledges


# Don't change anything below here

# Nagios return codes
STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3
STATE_DEPENDENT=4

if [ ! -x "${I2CGET}" ]
then
	echo "UNKNOWN: $I2CGET not found or is not executable by the nagios user"
	EXITSTATUS=$STATE_UNKNOWN
	exit $EXITSTATUS
fi

PROGNAME=`basename $0`

print_usage() {
	echo "Usage: $PROGNAME "
	echo ""
	echo ""
}

print_help() {
	print_usage
	echo ""
	echo "This plugin will check the power status of an locally attached UPiS."
	echo ""
	exit 0
}


#EXITSTATUS=${STATE_UNKNOWN} #default

while test -n "$1"; do
	case "$1" in
		--help)
			print_help
			exit $STATE_OK
			;;
		-h)
			print_help
			exit $STATE_OK
			;;
		*)
			print_help
			exit $STATE_OK
	esac
done


# Run basic showmount and find our status
I2CGET_OUTPUT=`${SUDO} ${I2CGET} -y 1 0x6A 0 2>&1`
# 1=EPR (External Power)
# 2=USB (USB Power)
# 3=RPI (RPI USB Power)
# 4=BAT (Battery Power)
# 5=LPR (Low Power)

if [ $? -ne 0 ]
then
EXITSTATUS=${STATE_CRITICAL}
else
EXITSTATUS=${STATE_OK}
fi

# Remove the wildcards as they cause a complete listing of CWD
# Uncomment the following 2 lines if you wish to have a list of shares
# in your Nagios output
CLEANED_I2CGET_OUTPUT=`sudo ${I2CGET} -y 1 0x6A 0 |sed -e 's/0x0//g'|awk '{print $1}' 2>&1`
#echo ${CLEANED_I2CGET_OUTPUT}

case ${CLEANED_I2CGET_OUTPUT} in
	1)
		EXITSTATUS=${STATE_OK}
		echo "UPiS OK - EPR | EPR (External Power)"
		;;
	2)
		EXITSTATUS=${STATE_OK}
		echo "UPiS OK - USB | USB (USB Power)"
		;;
	3)
		EXITSTATUS=${STATE_OK}
		echo "UPiS OK - RPI | RPI (RPI USB Power)"
		;;
	4)
		EXITSTATUS=${STATE_WARNING}
		echo "UPiS WARNING - BAT | BAT (Battery Power)"
		;;
	5)
		EXITSTATUS=${STATE_CRITICAL}
		echo "UPiS CRITICAL - LPR | LPR (Low Power)"
		;;
	*)
		EXITSTATUS=${STATE_UNKNOWN}
		echo "UPiS UNKNOWN | UPiS Status Unknown"
		;;
esac
		

exit $EXITSTATUS

