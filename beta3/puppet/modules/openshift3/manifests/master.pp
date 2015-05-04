class openshift3::master {
  include ::openshift3
  include ::openshift3::dns

  $ose_hosts = parsejson($::ose_hosts)
  $master_fqdn = $ose_hosts[0]['hostname']

  vcsrepo { "/root/openshift-ansible":
    ensure   => latest,
    provider => git,
    source   => "https://github.com/detiber/openshift-ansible.git",
    revision => 'v3-beta3',
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
    timeout => 1000,
    require => [Class['openshift3'], Service['docker'], Package['ansible'], File['/root/.ssh/id_rsa'], Ssh_Authorized_Key['ose3'], Augeas['ansible.cfg']],
  }

  user { ['joe', 'alice' ]:
    ensure => present,
    managehome => true,
  }

  htpasswd { ['joe', 'alice']:
    cryptpasswd => ht_sha1('redhat'),
    target      => '/etc/openshift-passwd',
  }

  service { 'openshift-master':
    require => [Class['openshift3'], Exec['Run ansible']],
  }

#  augeas { "openshift-master":
#    lens    => "Shellvars.lns",
#    incl    => "/etc/sysconfig/openshift-master",
#    changes => [
#      "set OPENSHIFT_OAUTH_REQUEST_HANDLERS session,basicauth",
#      "set OPENSHIFT_OAUTH_HANDLER login",
#      "set OPENSHIFT_OAUTH_PASSWORD_AUTH htpasswd",
#      "set OPENSHIFT_OAUTH_HTPASSWD_FILE /etc/openshift-passwd",
#      "set OPENSHIFT_OAUTH_ACCESS_TOKEN_MAX_AGE_SECONDS 172800",
#    ],
#    require => Exec['Run ansible'],
#    notify => Service['openshift-master'],
#  }

  exec {"Wait for master":
    require => Service["openshift-master"],
    command => "/usr/bin/wget --spider --tries 30 --retry-connrefused --no-check-certificate https://localhost:8443/",
  }

  exec { 'Install router':
    provider => 'shell',
    environment => 'HOME=/root',
    cwd     => "/root",
    command => "osadm router --create --credentials=/var/lib/openshift/openshift.local.certificates/openshift-client/.kubeconfig --images='registry.access.redhat.com/openshift3_beta/ose-\${component}:\${version}'",
    unless => "osadm router",
    timeout => 600,
    require => [Service['openshift-master'], Exec['Run ansible'], Exec['Wait for master']],
  }

  exec { 'Install registry':
    provider => 'shell',
    environment => 'HOME=/root',
    cwd     => "/root",
    command => "osadm registry --create --credentials=/var/lib/openshift/openshift.local.certificates/openshift-registry/.kubeconfig --images='registry.access.redhat.com/openshift3_beta/ose-\${component}:\${version}'",
    unless => "osc describe service docker-registry",
    timeout => 600,
    require => Exec['Install router'],
  }
}
