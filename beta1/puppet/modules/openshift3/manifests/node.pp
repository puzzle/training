class openshift3::node {
  include ::openshift3

  $ose_hosts = parsejson($::ose_hosts)
  $master_fqdn = $ose_hosts[0]['hostname']

  class { 'rsync': package_ensure => 'present' }

  file { '/etc/sysconfig/openshift-node':
    ensure  => present,
    owner  => 'root',
    group  => 'root',
    mode   => 0644,
    content => template('openshift3/sysconfig/openshift-node.erb'),
    require => Package['openshift-node'],
    notify => Service['openshift-sdn-node'],
  }

  file { '/etc/sysconfig/openshift-sdn-node':
    ensure  => present,
    owner  => 'root',
    group  => 'root',
    mode   => 0644,
    content => template('openshift3/sysconfig/openshift-sdn-node.erb'),
    require => Package['openshift-sdn-node'],
    notify => Service['openshift-sdn-node'],
  }

  service { 'openshift-sdn-node':
    ensure => running,
    enable => true,
    require => [Package['openshift-sdn-node'], Service['openvswitch'], Class['resolv_conf']],
  }

  file { '/root/.ssh':
    ensure  => directory,
    owner  => 'root',
    group  => 'root',
    mode   => 0700,
  }

  file { '/root/.ssh/id_rsa':
    ensure  => present,
    owner  => 'root',
    group  => 'root',
    mode   => 0600,
    source => '/vagrant/.ssh/id_rsa',
  }

  file { '/root/.ssh/id_rsa.pub':
    ensure  => present,
    owner  => 'root',
    group  => 'root',
    mode   => 0600,
    source => '/vagrant/.ssh/id_rsa.pub',
  }

  rsync::get { '/var/lib/openshift':
    source => "${master_fqdn}:/var/lib/openshift/openshift.local.certificates",
    options => '-a -e "ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"',
  }

  file { '/root/node.json':
    ensure  => present,
    owner  => 'root',
    group  => 'root',
    mode   => 0644,
    content => template('openshift3/root/node.json.erb'),
  }

  exec { 'osc create -f /root/node.json':
    unless => "osc get nodes | grep -q ${::fqdn}",
    require => [Service['openshift-sdn-node'], Service['docker'], File['/root/node.json']],
  }
}
