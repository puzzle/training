class openshift3::master {
  include ::openshift3
  include ::openshift3::dns

  $ose_hosts = parsejson($::ose_hosts)
  $master_fqdn = $ose_hosts[0]['hostname']

  service { 'openshift-master':
    ensure => running,
    enable => true,
    require => Package['openshift-master'],
  }

  file { '/etc/sysconfig/openshift-master':
    ensure  => present,
    owner  => 'root',
    group  => 'root',
    mode   => 0644,
    content => template('openshift3/sysconfig/openshift-master.erb'),
    require => Package['openshift-master'],
    notify => Service['openshift-master'],
  }

  file { '/etc/sysconfig/openshift-sdn-master':
    ensure  => present,
    owner  => 'root',
    group  => 'root',
    mode   => 0644,
    content => template('openshift3/sysconfig/openshift-sdn-master.erb'),
    require => Package['openshift-sdn-master'],
    notify => Service['openshift-sdn-master'],
  }

  service { 'openshift-sdn-master':
    ensure => running,
    enable => true,
    require => [ Package['openshift-sdn-master'], Service['openvswitch'] ],
  }

  exec { 'Install router':
    cwd     => "/vagrant",
    command => "/vagrant/puppet/install-router",
    creates => "/.router_installed",
    timeout => 600,
    require => [Service['openvswitch'], Service['openshift-sdn-master'], Service['openshift-master'], Service['docker'], Docker::Image['registry.access.redhat.com/openshift3_beta/ose-haproxy-router']],
#    require => [Service['openvswitch'], Service['openshift-sdn-master'], Service['openshift-sdn-node'], Service['openshift-master'], Service['docker'], Docker::Image['registry.access.redhat.com/openshift3_beta/ose-haproxy-router']],
  }

  exec { 'Install registry':
    cwd     => "/vagrant",
    command => "/vagrant/puppet/install-registry",
    creates => "/.registry_installed",
    timeout => 600,
    require => [Docker::Image['registry.access.redhat.com/openshift3_beta/ose-docker-registry'], Exec['Install router']],
#    require => [Service['openvswitch'], Service['openshift-sdn-master'], Service['openshift-sdn-node'], Service['openshift-master'], Service['docker'], Docker::Image['registry.access.redhat.com/openshift3_beta/ose-haproxy-router']],
  }
}
