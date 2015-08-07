class openshift3 ($ssh_key = undef) {
  stage { 'first':
    before => Stage['main'],
  }

  class { 'openshift3::network':
    stage => first
  }

  if $::operatingsystem == 'RedHat' {
    rhsm_repo { 'rhel-server-7-ose-beta-rpms': 
      ensure  => absent,
    }

    rhsm_repo { ['rhel-7-server-rpms', 'rhel-7-server-extras-rpms', 'rhel-7-server-optional-rpms', 'rhel-7-server-ose-3.0-rpms']: 
      ensure  => present,
    }
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
  package { ['deltarpm', 'wget', 'vim-enhanced', 'net-tools', 'bind-utils', 'git', 'iptables-services', 'bridge-utils' ]:
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

  if $::vagrant {
    exec { 'Import docker images':
      cwd     => "/vagrant",
      command => "/vagrant/puppet/import-docker",
      creates => "/.docker_imported",
      timeout => 1000,
      require => Service['docker'],
      before => Docker::Image <| |>,
    }
  }

  docker::image { [
    'registry.access.redhat.com/openshift3/ose-haproxy-router:v3.0.0.1',
    'registry.access.redhat.com/openshift3/ose-deployer:v3.0.0.1',
    'registry.access.redhat.com/openshift3/ose-sti-builder:v3.0.0.1',
    'registry.access.redhat.com/openshift3/ose-docker-builder:v3.0.0.1',
    'registry.access.redhat.com/openshift3/ose-pod:v3.0.0.1',
    'registry.access.redhat.com/openshift3/ose-docker-registry:v3.0.0.1',
#    'registry.access.redhat.com/openshift3/sti-basicauthurl:latest',
#    'openshift/ruby-20-centos',
#    'mysql',
#    'openshift/hello-openshift',
    ]:
  }

  if $::vagrant {
    ssh_authorized_key { "${ssh_key[name]}":
      user => 'root',
      type => $ssh_key[type],
      key  => $ssh_key[key],
    }
  }
}
