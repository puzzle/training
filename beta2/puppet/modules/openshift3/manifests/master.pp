class openshift3::master {
  include ::openshift3
  include ::openshift3::dns

  $ose_hosts = parsejson($::ose_hosts)
  $master_fqdn = $ose_hosts[0]['hostname']

#  service { 'openshift-master':
#    ensure => running,
#    enable => true,
#    require => Package['openshift-master'],
#  }

#  file { '/etc/sysconfig/openshift-master':
#    ensure  => present,
#    owner  => 'root',
#    group  => 'root',
#    mode   => 0644,
#    content => template('openshift3/sysconfig/openshift-master.erb'),
#    require => Package['openshift-master'],
#    notify => Service['openshift-master'],
#  }

#  file { '/etc/sysconfig/openshift-sdn-master':
#    ensure  => present,
#    owner  => 'root',
#    group  => 'root',
#    mode   => 0644,
#    content => template('openshift3/sysconfig/openshift-sdn-master.erb'),
#    require => Package['openshift-sdn-master'],
#    notify => Service['openshift-sdn-master'],
#  }

#  service { 'openshift-sdn-master':
#    ensure => running,
#    enable => true,
#    require => [ Package['openshift-sdn-master'], Service['openvswitch'] ],
#    before => Service['openshift-sdn-node'],
#  }

#  exec { 'Install registry':
#    cwd     => "/vagrant",
#    command => "/vagrant/puppet/install-registry",
#    creates => "/.registry_installed",
#    timeout => 600,
#    require => [Class['openshift3'], Service['openshift-sdn-master'], Exec['Install router']],
#  }

  vcsrepo { "/root/openshift-ansible":
    ensure   => latest,
    provider => git,
    source   => "https://github.com/detiber/openshift-ansible.git",
    revision => 'v3-beta2',
  }

  file { "/etc/ansible":
    source  => "file:///vagrant/ansible",
    recurse => true,
    require => Package['ansible'],
  }

  augeas { "ansible.cfg":
    lens    => "Puppet.lns",
    incl    => "/root/openshift-ansible/ansible.cfg",
    changes => "set /files/root/openshift-ansible/ansible.cfg/defaults/host_key_checking False",
    require => File['/etc/ansible'],
  }

  exec { 'Run ansible':
    cwd     => "/root/openshift-ansible",
    command => "ansible-playbook playbooks/byo/config.yml",
#    creates => "/.docker_imported",
    timeout => 1000,
    require => [Class['openshift3'], Package['ansible'], File['/root/.ssh/id_rsa'], Ssh_Authorized_Key['ose3'], Augeas['ansible.cfg']],
  }

  user { ['joe', 'alice' ]:
    ensure => present,
  }

#  package { 'httpd-tools':
#    ensure => present,
#  }

  htpasswd { ['joe', 'alice']:
    cryptpasswd => ht_sha1('redhat'),
    target      => '/etc/openshift-passwd',
  }

  service { 'openshift-master':
    require => [Class['openshift3'], Exec['Run ansible']],
  }

  augeas { "openshift-master":
    lens    => "Shellvars.lns",
    incl    => "/etc/sysconfig/openshift-master",
    changes => [
      "set OPENSHIFT_OAUTH_REQUEST_HANDLERS session,basicauth",
      "set OPENSHIFT_OAUTH_HANDLER login",
      "set OPENSHIFT_OAUTH_PASSWORD_AUTH htpasswd",
      "set OPENSHIFT_OAUTH_HTPASSWD_FILE /etc/openshift-passwd",
      "set OPENSHIFT_OAUTH_ACCESS_TOKEN_MAX_AGE_SECONDS 172800",
    ],
    require => File['/etc/ansible'],
    notify => Service['openshift-master'],
  }

  exec { 'Install router':
#    provider => 'shell',
    cwd     => "/root",
    command => "openshift ex router --create --credentials=/var/lib/openshift/openshift.local.certificates/openshift-client/.kubeconfig --images='registry.access.redhat.com/openshift3_beta/ose-${component}:${version}'",
    unless => "bash -l -c 'openshift ex router >/dev/null'",
    timeout => 600,
    require => [Class['openshift3'], Exec['Run ansible']],
  }
}
