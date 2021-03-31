#!/usr/bin/env python3

import requests
from xml.etree import ElementTree as ET

USER="autobot"
PWD="juniper123"
DEVICES = ["switch1"]

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

for device in DEVICES:
    reply = requests.post("http://{}:3001/rpc".format(device),data=FILTER,
        auth=requests.auth.HTTPBasicAuth(USER, PWD),
        headers={"Accept": "application/xml","Content-Type": "application/xml"})

    XML_lines = "\n".join(reply.text.splitlines()[3:-1])
    root = ET.fromstring(XML_lines)

    print("\nDevice: {} has the following usernames in its local DB:"
          .format(device))
    names = root.findall('.//user')
    for name in names:
        username = name.find('name').text
        print(username)
