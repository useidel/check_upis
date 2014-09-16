check_upis
==========

Very simple Nagios plugin to check the power status and temperature of UPiS (an USV for the Raspberry Pi)

root@raspbpi:~# 
root@raspbpi:~# ./check_upis.sh 

Usage: check_upis.sh -<p|t|h>

root@raspbpi:~# 
root@raspbpi:~# 
root@raspbpi:~# ./check_upis.sh -p
UPiS OK - USB | USB (USB Power)
root@raspbpi:~# 
root@raspbpi:~# 
root@raspbpi:~# ./check_upis.sh -t
Temperature OK - 40 'C | 40
root@raspbpi:~# 
root@raspbpi:~# 

