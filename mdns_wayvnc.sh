#!/bin/sh
# Advertise the matuzalem wayvnc service using dns-sd
exec /usr/local/bin/dns-sd -R "VMWareBSD" _vnc._tcp local 5900
