define openshift3::add_dns_entries($host = $title) {
  dnsmasq::hostrecord { $host['hostname']:
    ip => $host['ip'],
  }
}

class openshift3::dns {
  $ose_hosts = parsejson($::ose_hosts)

  class { 'dnsmasq':
    no_hosts => true,
    listen_address => ['127.0.0.1', $ipaddress_eth0, $ipaddress_eth1]
  }

  openshift3::add_dns_entries { $ose_hosts: }

  # Add wildcard entries for OpenShift 3 apps
  dnsmasq::address { ".cloudapps.$::domain":
    ip => $::ipaddress_eth1,
  }
  dnsmasq::address { ".openshiftapps.com":
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

  file { '/etc/dnsmasq.d/dnsmasq-extra.conf':
    ensure  => present,
    owner  => 'root',
    group  => 'root',
    mode   => 0600,
    content => template("openshift3/etc/dnsmasq-extra.conf.erb"),
  }
}
