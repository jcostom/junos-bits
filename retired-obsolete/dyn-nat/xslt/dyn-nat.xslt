<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:junos="http://xml.juniper.net/junos/*/junos"
    xmlns:xnm="http://xml.juniper.net/xnm/1.1/xnm" xmlns:ext="http://xmlsoft.org/XSLT/namespace"
    xmlns:jcs="http://xml.juniper.net/junos/commit-scripts/1.0">

    <xsl:import href="../import/junos.xsl"/>

    <!-- dyn-nat.xslt:
            This script is used as an event script to modify a NAT configuration.
            It is called whenever a DHCP assigned interface changes address and it modifies the 
            NAT configuration accordingly
    -->

    <!-- Argument declaration -->
    <xsl:variable name="arguments">
        <argument>
            <name>message</name>
            <description>Event message</description>
        </argument>
    </xsl:variable>
    <xsl:param name="message"/>

    <!-- Open a persistent connection -->
    <xsl:variable name="connection" select="jcs:open()"/>
    <!-- $configuration: Stores the relevant sections of the config -->
    <xsl:variable name="get-config-rpc">
        <rpc>
            <get-configuration>
                <configuration>
                    <security>
                        <nat>
                            <destination>
                                <rule-set/>
                            </destination>
                            <static>
                                <rule-set/>
                            </static>
                        </nat>
                    </security>
                </configuration>
            </get-configuration>

        </rpc>
    </xsl:variable>
    <xsl:variable name="configuration" select="jcs:execute($connection, $get-config-rpc)"/>

    <!-- Extract the required info from the event message -->
    <xsl:variable name="splitMessage"
        select="jcs:regex('^EVENT Add (.+)\.([0-9]+) index ([0-9]+) ([0-9.]+)\/[0-9]+ ->',$message)"/>
    <xsl:variable name="ifd" select="$splitMessage[2]"/>
    <xsl:variable name="unit" select="$splitMessage[3]"/>
    <xsl:variable name="ifl-ip" select="$splitMessage[5]"/>
    <xsl:variable name="ifl" select="concat($ifd,'.',$unit)"/>

    <xsl:template match="/">
        <op-script-results>

 <!--           <xsl:value-of select="jcs:output(concat('IFD: ',$ifd))"/>
            <xsl:value-of select="jcs:output(concat('Unit: ',$unit))"/>
            <xsl:value-of select="jcs:output(concat('IFL-IP: ',$ifl-ip))"/>
            <xsl:value-of select="jcs:output(concat('Message: ',$message))"/>-->

            <!-- Do we have anyting to do? -->
            <xsl:choose>
                <xsl:when
                    test="$configuration//dest-nat-rule-match[apply-macro[name='match-interface']/data[value = $ifl]] or 
                    $configuration//static-nat-rule-match[apply-macro[name='match-interface']/data[value = $ifl]]"> 
                    
                    <xsl:variable name="connection" select="jcs:open()"/>
                    
                    <!-- Open a private config -->
                    <xsl:variable name="rpc-configure-private">
                        <rpc>
                            <open-configuration>
                                <private/>
                            </open-configuration>
                        </rpc>
                    </xsl:variable>
                    <xsl:value-of select="jcs:execute($connection, $rpc-configure-private)"/>
                  
                    <!-- Process the Destination NAT config
                        Static NAT could also be done here, but the RPC is different enough
                        that it is simpler to just duplicate the code than to handle all the differences -->
                    <xsl:for-each
                        select="$configuration//dest-nat-rule-match[apply-macro[name='match-interface']/data[value = $ifl]]">
                        <xsl:variable name="rule" select="../name"/>
                        <xsl:variable name="rule-set" select="../../name"/>

                        <!-- Create the update RPC changing the metric -->
                        <xsl:variable name="config-update-rpc">
                            <rpc>
                                <load-configuration>
                                    <configuration>
                                        <security>
                                            <nat>
                                                <destination>
                                                  <rule-set>
                                                  <name>
                                                  <xsl:value-of select="$rule-set"/>
                                                  </name>
                                                  <rule>
                                                  <name>
                                                  <xsl:value-of select="$rule"/>
                                                  </name>
                                                  <dest-nat-rule-match>
                                                  <destination-address>
                                                  <dst-addr><xsl:value-of select="$ifl-ip"/>/32</dst-addr>
                                                  </destination-address>
                                                  </dest-nat-rule-match>
                                                  </rule>
                                                  </rule-set>
                                                </destination>
                                            </nat>
                                        </security>
                                    </configuration>
                                </load-configuration>
                            </rpc>
                        </xsl:variable>

                        <!-- Load the updated config -->
                        <xsl:value-of select="jcs:execute($connection, $config-update-rpc)"/>

                        <!-- Log the change -->
                        <xsl:value-of
                            select="jcs:syslog(12,concat('Dest nat rule ',
                            $rule,
                            ' changed because address ',
                            $ifl-ip,
                            ' has been assigned to ifl ',
                            $ifl
                            ))"/>


                    </xsl:for-each>
                    
                    <xsl:for-each
                        select="$configuration//static-nat-rule-match[apply-macro[name='match-interface']/data[value = $ifl]]">
                        <xsl:variable name="rule" select="../name"/>
                        <xsl:variable name="rule-set" select="../../name"/>
                        
                        <!-- Create the update RPC changing the metric -->
                        <xsl:variable name="config-update-rpc">
                            <rpc>
                                <load-configuration>
                                    <configuration>
                                        <security>
                                            <nat>
                                                <static>
                                                    <rule-set>
                                                        <name>
                                                            <xsl:value-of select="$rule-set"/>
                                                        </name>
                                                        <rule>
                                                            <name>
                                                                <xsl:value-of select="$rule"/>
                                                            </name>
                                                            <static-nat-rule-match>
                                                                <destination-address>
                                                                    <dst-addr><xsl:value-of select="$ifl-ip"/>/32</dst-addr>
                                                                </destination-address>
                                                            </static-nat-rule-match>
                                                        </rule>
                                                    </rule-set>
                                                </static>
                                            </nat>
                                        </security>
                                    </configuration>
                                </load-configuration>
                            </rpc>
                        </xsl:variable>
                        
                        <!-- Load the updated config -->
                        <xsl:value-of select="jcs:execute($connection, $config-update-rpc)"/>
                        
                        <!-- Log the change -->
                        <xsl:value-of
                            select="jcs:syslog(12,concat('Static nat rule ',
                            $rule,
                            ' changed because address ',
                            $ifl-ip,
                            ' has been assigned to ifl ',
                            $ifl
                            ))"/>
                        
                        
                    </xsl:for-each>
                    
 
                    <!-- Commit the config changes -->
                    <xsl:variable name="commit-config-rpc">
                        <rpc>
                            <commit-configuration/>
                        </rpc>
                    </xsl:variable>
                    <xsl:value-of select="jcs:execute($connection, $commit-config-rpc)"/>
<!--                    <xsl:value-of select="jcs:output('Commit Configuration')"/>-->
                    
                </xsl:when>

                <!-- Nothing to do -->
                <xsl:otherwise>
                    <xsl:value-of
                        select="jcs:syslog(12,concat('Address renew event received for IFL ',
                        $ifl,
                        ' but there is nothing to change'                        
                        ))"
                    />
                </xsl:otherwise>
            </xsl:choose>


        </op-script-results>
    </xsl:template>

</xsl:stylesheet>
