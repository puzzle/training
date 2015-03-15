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

  firewall { '500 Allow UDP DNS requests':
    action => 'accept',
    state  => 'NEW',
    dport  => [53],
    proto  => 'udp',
    require => Package['iptables-services'],
    before => Service['dnsmasq'],
  }

  firewall { '501 Allow TCP DNS requests':
    action => 'accept',
    state  => 'NEW',
    dport  => [53],
    proto  => 'tcp',
    require => Package['iptables-services'],
    before => Service['dnsmasq'],
  }
}
