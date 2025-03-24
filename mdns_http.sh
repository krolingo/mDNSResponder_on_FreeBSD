#!/bin/sh
# Advertise the Web Service HTTP with dns-sd
# dns-sd -B http._tcp
exec /usr/local/bin/dns-sd -R "VMWareBSD" _http._tcp local 80
