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
#    $interfaces = split($::interfaces, ',')

    # Change gateway to public network because the OpenShift ansible playbook identifies the network to use through the gateway
#    $gateway = regsubst(inline_template("<%= scope.lookupvar('::network_${interfaces[1]}') %>"), '\.0$', '.1')
#    augeas { "/etc/sysconfig/network-scripts/network":
#      changes => [
#        "set /files/etc/sysconfig/network/GATEWAY ${gateway}",
#      ],
#      notify => Service['network'],
#    }

    # Prevent dhclient from overwriting puppet managed /etc/resolv.conf with DHCP provided DNS servers
    augeas { "/etc/sysconfig/network-scripts/ifcfg-${::network_primary_interface}":
      changes => [
        "set /files/etc/sysconfig/network-scripts/ifcfg-${::network_primary_interface}/PEERDNS no",
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
