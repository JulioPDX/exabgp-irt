# ExaBGP Internet Routing Table

Docker image used to play with the internet routing table! Please note, this is for lab purposes only!

In my case this was used with [Containerlab](https://containerlab.srlinux.dev/) to learn and test policies with the internet routing table.

Default ExaBGP configuration.

```text
process announce-routes {
    run python3 fullbgptable.py;
    encoder json;
}

template {
    neighbor AS_65000 {
        router-id 172.16.2.1;
        local-as 65000;
        local-address 172.16.2.1;
    }
}

neighbor 172.16.2.2 {
    inherit AS_65000;
    peer-as 65001;
}

neighbor 172.16.2.3 {
    inherit AS_65000;
    peer-as 65002;
}
```

Configure neighbor node to match one listed

## Simple Topology with External BGP

`simple.clab.yml`

```yaml
name: irt
prefix: ""

topology:

  kinds:
    linux:
      image: juliopdx/exabgp-irt
    srl:
      image: ghcr.io/nokia/srlinux

  nodes:
    ispa:
      kind: srl
    internet: # ifconfig eth1 172.16.2.1 netmask 255.255.255.0 up
      kind: linux
  links:
    - endpoints: ["ispa:e1-1", "internet:eth1"]

```

`sudo containerlab deploy -t simple.clab.yml`

Set linux container eth1 interface to 172.16.2.1 and enable exabgp.

```text
juliopdx@containerlab:~$ docker exec -it internet bash
root@internet:/# ifconfig eth1 172.16.2.1 netmask 255.255.255.0 up
root@internet:/# exabgp bgp.cfg
```

Validate peer and routes on neighbor!

```text
A:ispa# show network-instance default protocols bgp neighbor 172.16.2.1
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
BGP neighbor summary for network-instance "default"
Flags: S static, D dynamic, L discovered by LLDP, B BFD enabled, - disabled, * slow
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
+-------------------+----------------------------+-------------------+-------+----------+----------------+----------------+--------------+----------------------------+
|     Net-Inst      |            Peer            |       Group       | Flags | Peer-AS  |     State      |     Uptime     |   AFI/SAFI   |       [Rx/Active/Tx]       |
+===================+============================+===================+=======+==========+================+================+==============+============================+
| default           | 172.16.2.1                 | internet          | S     | 65000    | established    | 0d:0h:0m:51s   | ipv4-unicast | [50160/50160/1]            |
+-------------------+----------------------------+-------------------+-------+----------+----------------+----------------+--------------+----------------------------+
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Summary:
2 configured neighbors, 1 configured sessions are established,0 disabled peers
0 dynamic peers
--{ running }--[  ]--
A:ispa#
```
