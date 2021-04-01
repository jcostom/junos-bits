#!/usr/bin/env python3

import requests
import xmltodict
import json

USER="autobot"
PWD="juniper123"
DEVICES = ["switch1","switch2"]

FILTER = """
<get-config>
    <source>
        <running/>
    </source>
    <filter type="subtree">
        <configuration>
            <system>
                <login/>
            </system>
        </configuration>
    </filter>
</get-config>
"""

print("----------------------------------------------------------------------")

for device in DEVICES:
    reply = requests.post("http://{}:3001/rpc".format(device),data=FILTER,
        auth=requests.auth.HTTPBasicAuth(USER, PWD),
        headers={"Accept": "application/xml","Content-Type": "application/xml"})
    
    print("Device {} has the following locally-defined users:\n".format(device))
    
    # I'm literally the worst at maninpulating XML, so I'm going to totally cheat
    # by converting it to JSON. #winning

    # Chop off superfluous top & bottom
    # goodStuff = '\n'.join(reply.text.split('\n')[4:-3])
    replyDict = xmltodict.parse('\n'.join(reply.text.split('\n')[4:-3]))
    for username in replyDict['configuration']['system']['login']['user']:
        print(username['name'])

    print("----------------------------------------------------------------------")

