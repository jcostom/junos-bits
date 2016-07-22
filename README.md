# junos-bits
Junos config bits, commit &amp; event scripts

* dyn-nat - Pato's old event script to mimic the old ScreenOS behavior of VIP using external IP (ie port forwarding)

* hub-and-spoke-srx-vpn - Hub & Spoke IPsec VPN configurations with a hub site and 2 DHCP-addressed satellite locations.  Uses OSPF with BFD between tunnel interfaces.

* routegen - Perl script to generate a large number of /32 static routes.  Useful for loading up the RIB to check route scale.  Randomly generated, so no guarantee as to uniqueness.

* srx300-switching - Starter configuration for an SRX300 using Ethernet Switching.
