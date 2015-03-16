define openshift3::add_dns_entries($host = $title) {
  dnsmasq::hostrecord { $host['hostname']:
    ip => $host['ip'],
  }
}

class openshift3::dns {
  $ose_hosts = parsejson($::ose_hosts)

  class { 'dnsmasq':
    no_hosts => true,    
  }

  openshift3::add_dns_entries { $ose_hosts: }

  # Add wildcard entry for OpenShift 3 apps
  dnsmasq::address { ".cloudapps.$::domain":
    ip => $::ipaddress_eth1,
  }

  # Prevent dhclient from overwriting puppet managed /etc/resolv.conf with DHCP provided DNS servers
  augeas { "/etc/sysconfig/network-scripts/ifcfg-eth0":
    changes => [
      "set /files/etc/sysconfig/network-scripts/ifcfg-eth0/PEERDNS no",
    ],
    notify => Service['network'],
    require => Service['dnsmasq'],
  }

  firewall { '500 Allow UDP DNS requests':
    action => 'accept',
    state  => 'NEW',
    dport  => [53],
    proto  => 'udp',
    before => Service['dnsmasq'],
  }

  firewall { '501 Allow TCP DNS requests':
    action => 'accept',
    state  => 'NEW',
    dport  => [53],
    proto  => 'tcp',
    before => Service['dnsmasq'],
  }
}
