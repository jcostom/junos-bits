# Sample SRX300 Config using Switching

## Requirements Met By This Config

* Static Address on WAN port (ge-0/0/0.0)
* Remainder of Ports (ge-0/0/[1-7]) used as Ethernet Switch Ports
  * VLAN 3 used
  * All access Ports
  * IRB interface configured on VLAN 3 (irb.3)
* Using dhcp-local-server (ie JDHCP) to serve up addresses on LAN-side
* Application Identification is configured

## Worth Noting

* Don't use vlan-id 1 on Junos 15.1X49-D50.  There's an issue with MAC learning.  There's a PR filed, and it will get fixed.  But, for the moment, use another vlan-id for your LAN-side.
* Make sure you configure the L2 Learning mode parameter on the SRX.  In its default state, the SRX is set for Transparent Bridging mode.  If you want to change this to Ethernet Switching mode, you'll need to configure as follows:
```
{master:0}
user@srx300> show configuration protocols
l2-learning {
    global-mode switching;
}
```
* Ethernet Switching on SRX300 is in an early state.  Care must be taken at the moment, as xSTP is not available yet, as of this writing.  Current Junos at the time of this writing is 15.1X49-D50.  As always, "read the docs to be safe."
