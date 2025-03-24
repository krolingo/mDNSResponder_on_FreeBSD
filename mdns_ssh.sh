#!/bin/sh
# Advertise the "VMWareBSD" service as a screen sharing service
exec /usr/local/bin/dns-sd -R "VMWareBSD" _ssh._tcp local 22



