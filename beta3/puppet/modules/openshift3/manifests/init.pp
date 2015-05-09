class openshift3 ($ssh_key = undef) {
  stage { 'first':
    before => Stage['main'],
  }

  class { 'openshift3::network':
    stage => first
  }

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
  package { ['deltarpm', 'wget', 'vim-enhanced', 'net-tools', 'bind-utils', 'tmux', 'git', 'iptables-services' ]:
    ensure => present,
  }

#  package { ['openshift-sdn', 'openshift-master', 'tuned-profiles-openshift-node', 'openshift-sdn-master', 'openshift', 'openshift-node', 'openshift-sdn-node']:
#    ensure => present,
#    require => Yumrepo['centos-extras'],
#  }


  # Workaround missing source support for yum provider
  exec { 'Install ansible':
    provider => 'shell',
    environment => 'HOME=/root',
    cwd     => "/root",
    command => "yum -y --enablerepo=epel install https://kojipkgs.fedoraproject.org//packages/ansible/1.8.4/1.el7/noarch/ansible-1.8.4-1.el7.noarch.rpm",
    unless => "rpm -q ansible",
    timeout => 120,
    require => Yumrepo['epel'],
  }  

  package { 'ansible':
    ensure => present,
    install_options => '--enablerepo=epel',
    require => [Yumrepo['epel'], Exec['Install ansible']],
  }

#  service { 'firewalld':
#   ensure => stopped,
#   enable => false,
#  }

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

  class { 'docker':
    extra_parameters => "--insecure-registry 0.0.0.0/0 --selinux-enabled",
  }

  exec { 'Import docker images':
#    cwd     => "/vagrant",
#    command => "/vagrant/puppet/import-docker",
    command => "/bin/true",
    creates => "/.docker_imported",
    timeout => 1000,
    require => Service['docker'],
  }

  docker::image { [
    'registry.access.redhat.com/openshift3_beta/ose-haproxy-router:v0.4.3.2',
    'registry.access.redhat.com/openshift3_beta/ose-deployer:v0.4.3.2',
    'registry.access.redhat.com/openshift3_beta/ose-sti-builder:v0.4.3.2',
    'registry.access.redhat.com/openshift3_beta/ose-docker-builder:v0.4.3.2',
    'registry.access.redhat.com/openshift3_beta/ose-pod:v0.4.3.2',
    'registry.access.redhat.com/openshift3_beta/ose-docker-registry:v0.4.3.2',
    'registry.access.redhat.com/openshift3_beta/sti-basicauthurl:latest',
#    'openshift/ruby-20-centos',
#    'mysql',
#    'openshift/hello-openshift',
    ]:
    require => Exec['Import docker images'],
  }

  if $::vagrant {
    ssh_authorized_key { "${ssh_key[name]}":
      user => 'root',
      type => $ssh_key[type],
      key  => $ssh_key[key],
    }
  }
}
