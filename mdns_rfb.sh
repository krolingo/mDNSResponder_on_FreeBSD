#!/bin/sh
# Advertise the "VMWareBSD Screen Sharing" service as a screen sharing service
# dns-sd -B _rfb._tcp local
exec /usr/local/bin/dns-sd -R "VMWareBSD Screen Sharing" _rfb._tcp local 5900



