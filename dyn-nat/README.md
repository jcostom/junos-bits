# dyn-nat.xslt

This is Pato's old script that watches for dynamic IP events, and alters an SRX destination NAT config to be updated with the new external IP.

This mimics the old ScreenOS behavior that allowed you to create a VIP using the firewall's external IP address (i.e. a port forwarding setup).

Example destination NAT rule (assumes your external interface is ge-0/0/7.0, and that you've got a pool named "web-server" already defined):

```
rule https-web {
    match {
        apply-macro match-interface {
            interface ge-0/0/7.0;
        }
        destination-address external.ip.goes.here/32;
        destination-port 443;
    }
    then {
        destination-nat {
            pool {
                web-server;
            }
        }
    }
}
```
The secret sauce is (obviously) applied using the apply-macro statement in the match conditions.

I've been using this script for years.  The fact that it's been working since Junos 9.x is a testament to the quality of Pato's code!
