class openshift3::master {
  include ::openshift3

  if $::vagrant {
    include ::openshift3::dns

    user { ['joe', 'alice' ]:
      ensure => present,
      managehome => true,
    }

    htpasswd { ['joe', 'alice']:
      cryptpasswd => ht_sha1('redhat'),
      target      => '/etc/openshift-passwd',
    }
  }

  vcsrepo { "/root/openshift-ansible":
    ensure   => latest,
    provider => git,
    source   => "https://github.com/detiber/openshift-ansible.git",
    revision => 'v3-beta4',
  }

  file { "/etc/ansible":
    ensure => "directory",
    owner  => "root",
    group  => "root",
    mode   => 755,
  }

  file { "/etc/ansible/hosts":
    content => template("openshift3/ansible/hosts.erb"),
    require => Package['ansible'],
    owner  => "root",
    group  => "root",
    mode   => 644,
  }

  augeas { "ansible.cfg":
    lens    => "Puppet.lns",
    incl    => "/root/openshift-ansible/ansible.cfg",
    changes => "set /files/root/openshift-ansible/ansible.cfg/defaults/host_key_checking False",
    require => Vcsrepo['/root/openshift-ansible'],
  }

   $_ansible_require = [Class['openshift3'], Service['docker'], Package['ansible'],Augeas['ansible.cfg']]
   if $::vagrant {
      $ansible_require = concat($_ansible_require, File['/root/.ssh/id_rsa'], Ssh_Authorized_Key['ose3'])
   } else {
      $ansible_require = $_ansible_require
   }

  exec { 'Run ansible':
    cwd     => "/root/openshift-ansible",
    command => "ansible-playbook playbooks/byo/config.yml",
    timeout => 1000,
    require => $ansible_require,
  }

  exec { 'Edit master.yaml':
    cwd     => "/etc/openshift",
    command => "sed -i -e 's/name: deny_all/name: apache_auth/' -e 's/kind: DenyAllPasswordIdentityProvider/kind: HTPasswdPasswordIdentityProvider/' -e '/kind: HTPasswdPasswordIdentityProvider/i \\      file: \\/etc\\/openshift-passwd' /etc/openshift/master/master-config.yaml",
    timeout => 60,
    require => Exec['Run ansible'],
    notify => Service['openshift-master'],
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
    command => "osadm router --create --credentials=/etc/openshift/master/openshift-router.kubeconfig --images='registry.access.redhat.com/openshift3_beta/ose-\${component}:\${version}'",
    unless => "osadm router",
    timeout => 600,
    require => [Service['openshift-master'], Exec['Run ansible'], Exec['Wait for master']],
  }

  exec { 'Install registry':
    provider => 'shell',
    environment => 'HOME=/root',
    cwd     => "/root",
    command => "osadm registry --create --credentials=/etc/openshift/master/openshift-registry.kubeconfig --images='registry.access.redhat.com/openshift3_beta/ose-\${component}:\${version}'",
    unless => "osadm registry",
    timeout => 600,
    require => Exec['Install router'],
  }
}
