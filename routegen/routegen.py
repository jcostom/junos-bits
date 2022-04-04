#!/usr/bin/env python3

import argparse
from random import randint

parser = argparse.ArgumentParser(
    prog='routegen.py',
    description='Generate static route statements to load into a router for PoC Testing.' # noqa E501
)

parser.add_argument('--count', type=int, default=100, action='store',
                    help="How many routes to generate.")
parser.add_argument('--rtr', default='juniper', action='store',
                    help="Router type: [juniper|cisco], default is juniper.")
parser.add_argument('--gw', action='store', default='10.255.255.254',
                    help="Gateway for routes generated, default is 10.255.255.254.") # noqa E501
args = parser.parse_args()


def main():
    for i in range(args.count):
        ip = ".".join(
            ['10', str(randint(0, 255)), str(randint(0, 255)), str(randint(0, 255))] # noqa E501
        )
        if args.rtr == 'juniper':
            print("set routing-options static route {}/32 {}".format(ip, args.gw)) # noqa E501
        elif args.rtr == 'cisco':
            print("ip route {} 255.255.255.255 {}".format(ip, args.gw))
        else:
            pass


if __name__ == "__main__":
    main()
