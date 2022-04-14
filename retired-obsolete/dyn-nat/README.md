# dyn-nat.xslt

This is Pato's old script that watches for dynamic IP events, and alters an SRX destination NAT config to be updated with the new external IP.

This mimics the old ScreenOS behavior that allowed you to create a VIP using the firewall's external IP address (i.e. a port forwarding setup).

## Installing and configuring

1. Drop the script in /var/db/scripts/event
2. Add it to the event-options config on your SRX:

```
event-options {
    policy ip-renew {
        events SYSTEM;
        attributes-match {
            SYSTEM.message matches "EVENT Add";
        }
        then {
            event-script dyn-nat.xslt {
                arguments {
                    message "{$$.message}";
                }
            }
        }
    }
    event-script {
        file dyn-nat.xslt;
    }
}
```

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

I'm expecting to need/want to rewrite this in Python some time in 2016-2017, when everything gets on-box Python & PyEZ (16.x?), given the strategic direction of moving away from SLAX and XSLT in favor of Python.
