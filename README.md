# **mDNSResponder on FreeBSD**  
Using Apple's mDNSResponder for Zero-Configuration Networking on FreeBSD

---

## 🚀 **Introduction**  
This project configures **mDNSResponder** (`mDNSResponder-2200.140.11`) — Apple's official implementation of Bonjour — to provide zero-configuration networking on FreeBSD. This version is the **same as the one used in macOS Sonoma 14.5**, ensuring excellent compatibility with Apple devices and services.  

### Installed from pkg
`pkg install mDNSResponder-2200.140.11`

---

## 💡 **Why mDNSResponder Instead of Avahi?**  
While Avahi is the most common mDNS solution on Linux, mDNSResponder offers several advantages on FreeBSD:

### ✅ **Performance and Low Memory Usage**  
- mDNSResponder is known for its **efficient handling** of multicast DNS (mDNS) queries.  
- Lower memory footprint and better performance than Avahi, especially in large or mixed networks.  

---

### ✅ ** Probably Superior Compatibility with Apple Ecosystem**  
- mDNSResponder is Apple's official implementation of Bonjour, ensuring **native compatibility** with macOS and iOS devices.  
- Avahi is a reverse-engineered alternative that can lead to subtle compatibility issues with Apple products.  

---

### ✅ **Better Multicast DNS Handling**  
- mDNSResponder has superior handling of multicast DNS queries in **mixed IPv4 and IPv6 environments**.  
- Faster service discovery and better handling of network changes compared to Avahi.  

---

### ✅ **Cross-Platform and Better FreeBSD Support (less buggy for sure)**  
- Avahi is more tied to Linux and may have **compatibility issues** when used on FreeBSD.  
- mDNSResponder has been adapted for FreeBSD and provides consistent behavior across Unix-like systems.  

---

## ⚙️ **Project Structure**  
The project uses a set of wrapper scripts and `rc.d` services to register various network services with mDNSResponder:

### **Wrapper Scripts**  
These scripts handle the actual service registration and execution:

```
Wrapper Scripts
.
├── mdns_afp.sh       # Advertises AFP (Apple File Sharing) over mDNS
├── mdns_http.sh      # Advertises HTTP services over mDNS
├── mdns_hostname.sh  # Registers the hostname with mDNS
├── mdns_rfb.sh       # Advertises VNC (RFB) services over mDNS
├── mdns_ssh.sh       # Advertises SSH over mDNS
└── mdns_wayvnc.sh    # Advertises WayVNC over mDNS
```

---

### **rc.d Daemons**  
The rc.d scripts allow the services to start at boot and be managed by FreeBSD's service framework:

```
rc.d daemons
├── mdns_afp
├── mdns_http
├── mdns_rfb
├── mdns_ssh
├── mdns_wayvnc
├── mdns_ws
├── mdnsd
```

---

### **Example rc.d Script: `mdns_afp`**
Here’s an example `rc.d` script for the AFP service:

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

### **rc.conf Configuration**  
To enable mDNSResponder and related services at boot, add the following lines to `/etc/rc.conf`:

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

## 🧪 **How to Use**  
### 1. Start the mDNSResponder Service  
Enable and start `mdnsd`:

```sh
service mdnsd enable
service mdnsd start
```

---

### 2. Start Individual mDNS Services  
Example for AFP:

```sh
service mdns_afp start
service mdns_afp status
```

---

### 3. Check mDNS Status  
Confirm mDNS services are running:

```sh
ps aux | grep mdns
```

Example output:

```sh
nobody     1046   0.0  0.0  13476  3000  -  Ss   15:22   0:00.00 /usr/local/sbin/mdnsd
```

---

## 🛠️ **Troubleshooting**  
### 🔥 **Service Fails to Start at Boot**  
- Ensure the `REQUIRE: mdnsd` directive is set in each `rc.d` script.  
- Make sure the wrapper scripts are executable:  

```sh
chmod +x /home/matuzalem/bin/mdns_*.sh
```

---

### 🔥 **mDNS Service Not Discoverable**  
- Confirm `mdnsd` is running:  

```sh
service mdnsd status
```
### Services
ps aux | grep mdns

```
nobody     1405   0.0  0.0  13476  3060  -  Ss   16:30    0:00.09 /usr/local/sbin/mdnsd
root       1417   0.0  0.0  12732  2152  -  Is   16:30    0:00.00 daemon: /home/matuzalem/bin/mdns_http.sh[1418] (daemon)
root       1423   0.0  0.0  12732  2156  -  Is   16:30    0:00.00 daemon: /home/matuzalem/bin/mdns_rfb.sh[1424] (daemon)
root       1427   0.0  0.0  12732  2148  -  Is   16:30    0:00.00 daemon: /home/matuzalem/bin/mdns_ssh.sh[1428] (daemon)
root       1431   0.0  0.0  12732  2152  -  Is   16:30    0:00.00 daemon: /home/matuzalem/bin/mdns_wayvnc.sh[1432] (daemon)
root       1435   0.0  0.0  12732  2152  -  Is   16:30    0:00.00 daemon: /home/matuzalem/bin/mdns_hostname.sh[1436] (daemon)
root       1487   0.0  0.0  12732  2160  -  Is   16:30    0:00.00 daemon: /home/matuzalem/bin/mdns_afp.sh[1488] (daemon)
matuzalem  2512   0.0  0.0  12796  2376  0  S+   16:37    0:00.00 grep --color mdns
```

- Check for firewall rules blocking multicast DNS (UDP port 5353).  

---

## 🌍 **Why This Maybe Could Possible Matter To Someone**  
By using mDNSResponder instead of Avahi on FreeBSD, you get:  
✔️ Better performance and memory usage  
✔️ Native compatibility with macOS and iOS  
✔️ Better handling of mixed IPv4/IPv6 environments  
✔️ Cleaner and more reliable service discovery  

---

## 👨‍💻 **Contributing**  
Feel free to open an issue or submit a pull request if you encounter any issues or have suggestions for improvements. 😎
Also, you will need to change the username or move your scripts to /usr/local/bin.

---

## 🚀 **License**  
Use as you please.
