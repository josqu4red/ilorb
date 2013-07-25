# ILORb

ILORb is a library created to ease interaction with HP servers baseboard management cards (ILO), using their XML interface.

It is primarily meant to integrate with Chef config management system, but it can of course be used standalone.

It supports RIB, SERVER and USER commands for ILO 2, 3 and 4 (no other hardware to test on).

 * By default, it will try to query the BMC through HTTP POST (available from ILO version 3)
 * It will fall back to raw XML through TCP socket (SSL-wrapped) for earlier ILO versions

Supported commands and parameters are defined using a little DSL, under [definitions](lib/ilorb/definitions), sorted by "context".


HP, Integrated Lights Out and iLO are trademarks of HP, with whom the author of this software is not affiliated in any way other than using some of their hardware.

## Examples

```ruby
require 'json'
require 'ilorb'

ilo = ILORb::ILO.new(
  :hostname => "10.200.0.1",
  :login => "Admin",
  :password => "SECRET",
#  :protocol => :raw, # for old ILOs, defaults to :http
)

result = ilo.get_network_settings
puts JSON.pretty_generate(result)
```
generates and sends :

```xml
<?xml version="1.0"?>
<ribcl version="2.0">
  <login password="SECRET" user_login="Admin">
    <rib_info mode="read">
      <get_network_settings/>
    </rib_info>
  </login>
</ribcl>
```
result:
```json
{
  "status": {
    "code": 0,
    "message": "No error"
  },
  "get_network_settings": {
    "enable_nic": {
      "@value": "Y"
    },
    "shared_network_port": {
      "@value": "N"
    },
    "vlan_enabled": {
      "@value": "N"
    },
    "vlan_id": {
      "@value": "0"
    },
    "speed_autoselect": {
      "@value": "Y"
    },
    "dhcp_enable": {
      "@value": "N"
    },
    { ... }
  }
}
```

## TODO

  * Tests
  * Use a custom parser instead of Nori, to avoid one-element-hashes and cast responses to actual objects (e.g Y/N to true/false)
  * See for mandatory parameters
  * Add a CLI tool

## Setup

Only tested with MRI >= 1.9.3

Dependencies:
 * nokogiri
 * nori

Install:
 * git clone https://github.com/josqu4red/ilorb
OR
 * gem install ilorb

## Credits

ilorb is inspired by [python-hpilo](https://github.com/seveas/python-hpilo)
