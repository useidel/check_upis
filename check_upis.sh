#!/bin/bash
# UPiS mount plugin for Nagios
# Written by Udo Seidel
#
# Description:
#
# This plugin will check the status of a UPiS connected to the RPi
#
# Location of the sudo and i2cget command (if not in path)
SUDO="/usr/bin/sudo"
I2CGET="/usr/sbin/i2cget"
BC="/usr/bin/bc"
MYTEST=""

# sudo is needed if i2cget cannot be executed by the nagios 
# user context w/o sudo granted priviledges


# Nagios return codes
STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3
STATE_DEPENDENT=4

EXITSTATUS=$STATE_UNKNOWN #default


PROGNAME=`basename $0`

print_usage() {
	echo 
	echo "Usage: $PROGNAME -<p|t|h>"
	echo 
}

print_help() {
	print_usage
	echo 
	echo "This plugin will check the power and temperature status of an locally attached UPiS."
	echo 
	exit 0
}

if [ "$#" -ne 1 ]; then
	print_usage
	exit 1
else
	MYARG=$1
fi

check_i2cget() {
if [ ! -x "$I2CGET" ]
then
        echo "UNKNOWN: $I2CGET not found or is not executable by the nagios user"
        EXITSTATUS=$STATE_UNKNOWN
        exit $EXITSTATUS
fi
}


check_power() {
I2CGET_ARG="-y 1 0x6A 0x00"
# Run basic showmount and find our status
I2CGET_OUTPUT=`$SUDO $I2CGET $I2CGET_ARG 2>&1`

if [ $? -ne 0 ]
then
EXITSTATUS=$STATE_CRITICAL
else
EXITSTATUS=$STATE_OK
fi

CLEANED_I2CGET_OUTPUT=`sudo $I2CGET $I2CGET_ARG |sed -e 's/0x0//g'|awk '{print $1}' 2>&1`

case $CLEANED_I2CGET_OUTPUT in
	1)
		EXITSTATUS=$STATE_OK
		echo "UPiS OK - EPR | EPR (External Power)"
		;;
	2)
		EXITSTATUS=$STATE_OK
		echo "UPiS OK - USB | USB (USB Power)"
		;;
	3)
		EXITSTATUS=$STATE_OK
		echo "UPiS OK - RPI | RPI (RPI USB Power)"
		;;
	4)
		EXITSTATUS=$STATE_WARNING
		echo "UPiS WARNING - BAT | BAT (Battery Power)"
		;;
	5)
		EXITSTATUS=$STATE_CRITICAL
		echo "UPiS CRITICAL - LPR | LPR (Low Power)"
		;;
	*)
		EXITSTATUS=$STATE_UNKNOWN
		echo "UPiS UNKNOWN | UPiS Status Unknown"
		;;
esac
}

bcdbyte2dec() {
# convert the hex output to a proper dec number
if [ ! -x "$BC" ]
then
        echo "UNKNOWN: $BC not found or is not executable by the nagios user"
        EXITSTATUS=$STATE_UNKNOWN
        exit $EXITSTATUS
fi


DEC=`echo "ibase=16; $1" |bc -l`
A=$((DEC/16))
A=$((A&15))
B=$((DEC&15))
RESULT=`echo "10*$A+$B"|bc -l`

}

check_temperature() {
I2CGET_ARG="-y 1 0x6A 0x0B"
# Run basic showmount and find our status
I2CGET_OUTPUT=`$SUDO $I2CGET $I2CGET_ARG 2>&1`

if [ $? -ne 0 ]
then
EXITSTATUS=$STATE_CRITICAL
else
EXITSTATUS=$STATE_OK
fi

CLEANED_I2CGET_OUTPUT=`sudo $I2CGET $I2CGET_ARG |sed -e 's/0x//g'|awk '{print $1}' 2>&1`

bcdbyte2dec $CLEANED_I2CGET_OUTPUT

echo "Temperature OK - $CLEANED_I2CGET_OUTPUT 'C | $CLEANED_I2CGET_OUTPUT"
}
		

case "$MYARG" in
	-h)
		print_help
		exit $STATE_UNKNOWN
		;;
	-p)
		check_i2cget
		check_power
		;;
	-t)
		check_i2cget
		check_temperature
		;;
	*)
		print_help
		exit $STATE_UNKNOWN
esac


exit $EXITSTATUS

