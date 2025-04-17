
# **mDNSResponder on FreeBSD**  
Using Apple’s mDNSResponder for Zero-Configuration Networking on FreeBSD

---

## Introduction  
This project demonstrates how to configure **mDNSResponder** (`mDNSResponder-2200.140.11`) — Apple’s official implementation of Bonjour — to enable zero-configuration networking on FreeBSD. This particular version matches the one shipped with **macOS Sonoma 14.5**, ensuring maximum compatibility with Apple devices and services.

### Installed via pkg:
```sh
pkg install mDNSResponder-2200.140.11
```

---

## Why mDNSResponder Instead of Avahi?  

Although Avahi is the more common mDNS solution on Linux, mDNSResponder provides notable advantages on FreeBSD systems.

### Performance and Memory Efficiency  
- Known for efficient handling of multicast DNS (mDNS) queries.  
- Lower memory footprint and better performance than Avahi, particularly in larger or heterogeneous networks.

### Compatibility with Apple Devices  
- As Apple’s official implementation of Bonjour, mDNSResponder ensures native compatibility with macOS and iOS.  
- Avahi is a reverse-engineered alternative, which can sometimes lead to subtle compatibility issues.

### Better Multicast DNS Handling  
- More robust handling of mDNS in dual-stack (IPv4/IPv6) environments.  
- Faster service discovery and more reliable behavior during network changes.

### FreeBSD Support  
- Avahi is heavily tied to Linux and may exhibit bugs or inconsistencies on FreeBSD.  
- mDNSResponder has been ported with FreeBSD in mind, offering consistent behavior across Unix-like platforms.

---

## Project Structure  

This setup includes wrapper scripts and `rc.d` service scripts to advertise common network services using mDNSResponder.

### Wrapper Scripts  
These scripts perform actual service registration and execution:

```
Wrapper Scripts
.
├── mdns_afp.sh       # Advertises AFP (Apple File Sharing)
├── mdns_http.sh      # Advertises HTTP services
├── mdns_hostname.sh  # Registers hostname with mDNS
├── mdns_rfb.sh       # Advertises VNC (RFB) services
├── mdns_ssh.sh       # Advertises SSH
└── mdns_wayvnc.sh    # Advertises WayVNC
```

---

### rc.d Daemons  
These allow for FreeBSD-native service management and automatic startup at boot:

```
rc.d Daemons
├── mdns_afp
├── mdns_http
├── mdns_rfb
├── mdns_ssh
├── mdns_wayvnc
├── mdns_ws
├── mdnsd
```

---

### Example `rc.d` Script: `mdns_afp`

```sh
#!/bin/sh
#
# PROVIDE: mdns_afp
# REQUIRE: mdnsd DAEMON
# BEFORE: LOGIN
# KEYWORD: shutdown

. /etc/rc.subr

name="mdns_afp"
rcvar="mdns_afp_enable"
pidfile="/var/run/mdns_afp.pid"
command="/usr/sbin/daemon"
command_args="-p ${pidfile} -f /home/matuzalem/bin/mdns_afp.sh"

load_rc_config $name
: ${mdns_afp_enable:=no}

mdns_afp_stop() {
    if [ -f "${pidfile}" ]; then
        kill "$(cat ${pidfile})" 2>/dev/null
        sleep 1
        rm -f ${pidfile}
    fi
}

mdns_afp_status() {
    if [ -f "${pidfile}" ] && kill -0 "$(cat ${pidfile})" 2>/dev/null; then
        echo "mdns_afp is running (pid $(cat ${pidfile}))"
        return 0
    else
        echo "mdns_afp is not running"
        return 1
    fi
}

stop_cmd="mdns_afp_stop"
status_cmd="mdns_afp_status"

run_rc_command "$1"
```

---

### rc.conf Configuration  

To enable `mdnsd` and the advertised services at boot, add the following lines to `/etc/rc.conf`:

```ini
### Apple File Sharing & mDNSResponder ###
netatalk_enable="YES"
mdnsd_enable="YES"
mdns_afp_enable="YES"
mdns_http_enable="YES"
mdns_rfb_enable="YES"
mdns_ssh_enable="YES"
mdns_wayvnc_enable="YES"
mdns_ws_enable="YES"
```

---

## Usage  

### 1. Start the mDNSResponder Service  
```sh
service mdnsd enable
service mdnsd start
```

### 2. Start Individual Services  
For example, to start AFP advertising:

```sh
service mdns_afp start
service mdns_afp status
```

### 3. Check Service Status  
```sh
ps aux | grep mdns
```

Sample output:

```sh
nobody     1046   0.0  0.0  13476  3000  -  Ss   15:22   0:00.00 /usr/local/sbin/mdnsd
```

---

## Troubleshooting  

### Service Doesn’t Start at Boot  
- Confirm the `REQUIRE: mdnsd` directive is present in each `rc.d` script.  
- Ensure all wrapper scripts are executable:

```sh
chmod +x /home/matuzalem/bin/mdns_*.sh
```

### Services Not Discoverable  
- Confirm that `mdnsd` is running:

```sh
service mdnsd status
```

- Check process list:

```sh
ps aux | grep mdns
```

Example:

```
nobody     1405   0.0  0.0  13476  3060  -  Ss   16:30   0:00.09 /usr/local/sbin/mdnsd
root       1417   0.0  0.0  12732  2152  -  Is   16:30   0:00.00 daemon: /home/matuzalem/bin/mdns_http.sh[1418]
...
```

- Check that no firewall is blocking UDP port 5353 (mDNS traffic).

---

## Why This Matters  

Switching to mDNSResponder on FreeBSD offers:

- Better performance and lower resource usage  
- Seamless compatibility with Apple systems  
- Improved multicast DNS behavior in mixed networking setups  
- More reliable and maintainable service discovery

---

## Contributing  

Suggestions, improvements, or bug reports are welcome. Feel free to open an issue or submit a pull request.

> Note: You should update the script paths or move them to `/usr/local/bin`.

---

## License  

Use freely. Attribution appreciated but not required.
