class openshift3 ($ssh_key = undef) {
  $ose_hosts = parsejson($::ose_hosts)

#  yumrepo { "centos-extras":
#    name => 'centos-extras',
#    baseurl => "http://mirror.centos.org/centos/7/extras/x86_64/",
#    enabled => 1,
#    gpgcheck => 1,
#    gpgkey => "http://mirror.centos.org/centos/RPM-GPG-KEY-CentOS-7",
#  }

  yumrepo { "epel":
    descr => 'Extra Packages for Enterprise Linux 7',
    baseurl => "http://download.fedoraproject.org/pub/epel/7/x86_64",
    enabled => 0,
    gpgcheck => 1,
    gpgkey => "https://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-7",
  }

# , 'openvswitch', 'iptables-services', 'bridge-utils', 'iptables'
  package { ['deltarpm', 'wget', 'vim-enhanced', 'net-tools', 'bind-utils', 'tmux', 'git' ]:
    ensure => present,
  }

#  package { ['openshift-sdn', 'openshift-master', 'tuned-profiles-openshift-node', 'openshift-sdn-master', 'openshift', 'openshift-node', 'openshift-sdn-node']:
#    ensure => present,
#    require => Yumrepo['centos-extras'],
#  }

  package { 'ansible':
    ensure => present,
    install_options => '--enablerepo=epel',
    require => Yumrepo['epel'],
  }

#  service { 'firewalld':
#   ensure => stopped,
#   enable => false,
#  }

  service { 'NetworkManager':
   ensure => stopped,
   enable => false,
  }

  service { 'network':
    ensure => running,
    enable => true,
    require => [ Service['NetworkManager'] ],
  }

#  service { 'openvswitch':
#    ensure => running,
#    enable => true,
#    require => [ Package['openvswitch'], Service['network'], Service['firewalld'] ],
#  }

#  service { 'iptables':
#    ensure => running,
#    enable => true,
#    require => Package['iptables'],
#  }

#  file { '/etc/sysconfig/iptables':
#    ensure  => present,
#    owner  => 'root',
#    group  => 'root',
#    mode   => 0600,
#    source => "puppet:///modules/openshift3/sysconfig/iptables",
#    require => Package['iptables-services'],
#    notify => Service['iptables'],
#  }

#  file { '/root/.bash_profile':
#    ensure  => present,
#    owner  => 'root',
#    group  => 'root',
#    mode   => 0644,
#    source => "puppet:///modules/openshift3/root/.bash_profile",
#  }

  file { '/etc/hosts':
    ensure  => present,
    owner  => 'root',
    group  => 'root',
    mode   => 0644,
    content => template("openshift3/etc/hosts.erb"),
    before => Service['network'],
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
    extra_parameters => "--insecure-registry 0.0.0.0/0 --selinux-enabled",
  }

  exec { 'Import docker images':
    cwd     => "/vagrant",
    command => "/vagrant/puppet/import-docker",
    creates => "/.docker_imported",
    timeout => 1000,
    require => Service['docker'],
  }

  docker::image { [
    'registry.access.redhat.com/openshift3_beta/ose-haproxy-router',
    'registry.access.redhat.com/openshift3_beta/ose-deployer',
    'registry.access.redhat.com/openshift3_beta/ose-sti-builder',
    'registry.access.redhat.com/openshift3_beta/ose-docker-builder',
    'registry.access.redhat.com/openshift3_beta/ose-pod',
    'registry.access.redhat.com/openshift3_beta/ose-docker-registry',
#    'openshift/ruby-20-centos',
#    'mysql',
#    'openshift/hello-openshift',
    ]:
    require => Exec['Import docker images'],
  }

  ssh_authorized_key { "${ssh_key[name]}":
    user => 'root',
    type => $ssh_key[type],
    key  => $ssh_key[key],
  }
}
