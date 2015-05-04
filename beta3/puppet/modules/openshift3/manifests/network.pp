class openshift3::network {
  service { 'NetworkManager':
   ensure => stopped,
   enable => false,
  }

  service { 'network':
    ensure => running,
    enable => true,
    require => [ Service['NetworkManager'] ],
  }

  if $::vagrant {
    # Change gateway to public network because the OpenShift ansible playbook identifies the network to use through the gateway
    $gateway = regsubst($::network_eth1, '\.0$', '.1')
    augeas { "/etc/sysconfig/network-scripts/network":
      changes => [
        "set /files/etc/sysconfig/network/GATEWAY ${gateway}",
      ],
      notify => Service['network'],
    }

    # Prevent dhclient from overwriting puppet managed /etc/resolv.conf with DHCP provided DNS servers
    augeas { "/etc/sysconfig/network-scripts/ifcfg-eth0":
      changes => [
        "set /files/etc/sysconfig/network-scripts/ifcfg-eth0/PEERDNS no",
      ],
      notify => Service['network'],
    }

    file { '/etc/hosts':
      ensure  => present,
       owner  => 'root',
      group  => 'root',
      mode   => 0644,
      content => template("openshift3/etc/hosts.erb"),
      before => Service['network'],
    }
  }
}
