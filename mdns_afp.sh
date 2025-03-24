#!/bin/sh
# Advertise the AFP service with dns-sd
# dns-sd -B _afpovertcp._tcp
exec /usr/local/bin/dns-sd -R "VMWareBSD" _afpovertcp._tcp local 548
