define openshift3::add_dns_entries($host = $title) {
  dnsmasq::hostrecord { $host['hostname']:
    ip => $host['ip'],
  }
}

class openshift3::dns {
  $ose_hosts = parsejson($::ose_hosts)
  $master_ip = $ose_hosts[0]['ip']

  class { 'dnsmasq':
    no_hosts => true,
    listen_address => [$master_ip]
  }

  openshift3::add_dns_entries { $ose_hosts: }

  # Add wildcard entries for OpenShift 3 apps
  dnsmasq::address { ".cloudapps.$::domain":
    ip => $::network_primary_ip,
  }
  dnsmasq::address { ".openshiftapps.com":
    ip => $::network_primary_ip,
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
    notify => Service['dnsmasq'],
  }
}
