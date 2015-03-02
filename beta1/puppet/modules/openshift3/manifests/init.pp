class openshift3 ($ssh_key = undef) {
  $ose_hosts = parsejson($::ose_hosts)

#  yumrepo { "centos-extras":
#    name => 'centos-extras',
#    baseurl => "http://mirror.centos.org/centos/7/extras/x86_64/",
#    enabled => 1,
#    gpgcheck => 1,
#    gpgkey => "http://mirror.centos.org/centos/RPM-GPG-KEY-CentOS-7",
#  }
 
  package { ['deltarpm', 'wget', 'vim-enhanced', 'net-tools', 'bind-utils', 'tmux', 'git', 'openvswitch', 'iptables-services', 'bridge-utils', 'iptables' ]:
    ensure => present,
  }

  package { ['openshift-sdn', 'openshift-master', 'tuned-profiles-openshift-node', 'openshift-sdn-master', 'openshift', 'openshift-node', 'openshift-sdn-node']:
    ensure => present,
#    require => Yumrepo['centos-extras'],
  }

  service { 'firewalld':
   ensure => stopped,
   enable => false,
  }

  service { 'NetworkManager':
   ensure => stopped,
   enable => false,
  }

  service { 'network':
    ensure => running,
    enable => true,
    require => [ Service['NetworkManager'] ],
  }

  service { 'openvswitch':
    ensure => running,
    enable => true,
    require => [ Package['openvswitch'], Service['network'], Service['firewalld'] ],
  }

  service { 'iptables':
    ensure => running,
    enable => true,
    require => Package['iptables'],
  }

  file { '/etc/sysconfig/iptables':
    ensure  => present,
    owner  => 'root',
    group  => 'root',
    mode   => 0600,
    source => "puppet:///modules/openshift3/sysconfig/iptables",
    require => Package['iptables-services'],
    notify => Service['iptables'],
  }

  file { '/root/.bash_profile':
    ensure  => present,
    owner  => 'root',
    group  => 'root',
    mode   => 0644,
    source => "puppet:///modules/openshift3/root/.bash_profile",
  }

  if defined(Service['dnsmasq']) {
    $resolv_require = [ Service['dnsmasq'] ]
  } else {
    $resolv_require = []
  }

  class { 'resolv_conf':
    domainname => '.',
    nameservers => [$ose_hosts[0]['ip'], '8.8.8.8', '8.8.4.4'],  # Use Google Public DNS as forwarder
    require => $resolv_require,
  }

  class { 'docker':
    extra_parameters => "--insecure-registry $::network_eth1/$::netmask_eth1",
#    socket_bind => 'fd://',
  }

  docker::image { 'registry.access.redhat.com/openshift3_beta/ose-haproxy-router': }
  docker::image { 'registry.access.redhat.com/openshift3_beta/ose-deployer': }
  docker::image { 'registry.access.redhat.com/openshift3_beta/ose-sti-builder': }
  docker::image { 'registry.access.redhat.com/openshift3_beta/ose-docker-builder': }
  docker::image { 'registry.access.redhat.com/openshift3_beta/ose-pod': }
  docker::image { 'registry.access.redhat.com/openshift3_beta/ose-docker-registry': }

  ssh_authorized_key { "${ssh_key[name]}":
    user => 'root',
    type => $ssh_key[type],
    key  => $ssh_key[key],
  }
}
