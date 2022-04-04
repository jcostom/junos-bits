#!/usr/bin/env perl
# 
# I wrote this over 10 years ago. It's time to retire this folks.
# Seriously. Use the Python version.
# Plus, this one could be considered "harmful", since
# it uses the "1.1.1.1" as the default for the gateway,
# as was once common practice in labs. In modern times,
# this isn't the case any longer. Please don't do that.
# It's not nice to stomp on Cloudflare's IPs. 
# 

# require 5.8.0;
# 
# use Getopt::Long;
# 
# my $count = 100;
# my $rtr = "juniper";
# my $gw = "1.1.1.1";
# 
# # Grab Options from CLI
# GetOptions (
# 	'count=i' 	=>	\$count,
# 	'rtr=s'	=>	\$rtr,
# 	'gw=s'	=>	\$gw,
# 	'help!'	=>	\$help,
# ) or $help = 1;
# 
# # Display usage Message
# if ($help) {
# 	print "Usage: $0 [args]\n\n";
# 	print "Arguments:\n";
# 	print "--count=number of routes [default 100]\n";
# 	print "--rtr=[juniper|cisco] [default juniper]\n";
# 	print "--gw=gateway for routes [default 1.1.1.1]\n";
# 	print "--help (Displays This Message)\n\n";
# 	exit 0;
# }
# 
# while ( $count-- ) {
# 	my @ip = (
# 		int( 1 + rand 223 ),
# 		map int rand( 256 ), 1 .. 3
# 	);
# 
# 	local $" = '.';
# 	if ($rtr eq "juniper") {
# 		print "set routing-options static route @ip/32 next-hop $gw\n";
# 	} else {
# 		print "ip route @ip 255.255.255.255 $gw\n";
# 	}
# }
# 
# __END__
# 