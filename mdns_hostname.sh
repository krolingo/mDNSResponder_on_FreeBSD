#!/bin/sh
# Advertise the server hostname as a Bonjour workstation service
# dns-sd -B _workstation._tcp local
# Get the current hostname (e.g. "myserver.local")
host=$(hostname)

# Use a dummy port (here 9, the discard port, as the service doesn’t actually run a network service)
exec /usr/local/bin/dns-sd -R "$host" _workstation._tcp local 9
