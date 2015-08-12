class openshift3::master {
  include ::openshift3

  package { 'openshift-master':
    ensure => latest,
  }

  if $::vagrant {
    include ::openshift3::dns

    user { ['joe', 'alice' ]:
      ensure => present,
      managehome => true,
    }

    htpasswd { ['joe', 'alice']:
      cryptpasswd => '$apr1$LB4KhoUd$2QRUqJTtbFnDeal80WI2R/',
      target      => '/etc/openshift/openshift-passwd',
      require     => Exec ['Run ansible'],
    }
  }

  vcsrepo { "/root/openshift-ansible":
    ensure   => latest,
    provider => git,
    source   => "https://github.com/openshift/openshift-ansible.git",
    revision => 'v3.0.0',
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

   $_ansible_require = [Class['openshift3'], Package['ansible'],Augeas['ansible.cfg']]
#   $_ansible_require = [Class['openshift3'], Service['docker'], Package['ansible'],Augeas['ansible.cfg']]
   if $::vagrant {
      $ansible_require = concat($_ansible_require, File['/root/.ssh/id_rsa'], Ssh_Authorized_Key['ose3'])
   } else {
      $ansible_require = $_ansible_require
   }

  exec { 'Run ansible':
    cwd     => "/root/openshift-ansible",
    command => "ansible-playbook playbooks/byo/config.yml",
#    command => "true",
    timeout => 1000,
    require => $ansible_require,
  } ->

  docker::image { [
#    'registry.access.redhat.com/openshift3/ose-haproxy-router:v3.0.0.1',
    "registry.access.redhat.com/openshift3/ose-deployer",
#    'registry.access.redhat.com/openshift3/ose-sti-builder:v3.0.0.1',
#    'registry.access.redhat.com/openshift3/ose-docker-builder:v3.0.0.1',
    "registry.access.redhat.com/openshift3/ose-pod",
#    'registry.access.redhat.com/openshift3/ose-docker-registry:v3.0.0.1',
#    'registry.access.redhat.com/openshift3/sti-basicauthurl:latest',
#    'openshift/ruby-20-centos',
#    'mysql',
#    'openshift/hello-openshift',
    ]:
    image_tag => "v${::openshift3::version}",
#    require => Exec['Run ansible'],    
  } ->

#  exec { 'Edit master.yaml':
#    cwd     => "/etc/openshift",
#    command => "sed -i -e 's/name: deny_all/name: apache_auth/' -e 's/kind: DenyAllPasswordIdentityProvider/kind: HTPasswdPasswordIdentityProvider/' -e '/kind: HTPasswdPasswordIdentityProvider/i \\      file: \\/etc\\/openshift-passwd' /etc/openshift/master/master-config.yaml",
#    timeout => 60,
#    require => Exec['Run ansible'],
#    notify => Service['openshift-master'],
#  }

#  service { 'openshift-master':
#    require => [Class['openshift3'], Exec['Run ansible']],
#  }

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
#    require => Service["openshift-master"],
    command => "/usr/bin/wget --spider --tries 60 --retry-connrefused --no-check-certificate https://localhost:8443/",
  }

  class { 'openshift3::router':
    require => [Class['openshift3'], Exec['Wait for master']],
  }

#  exec { "Create wildcard certificate":
#    provider => 'shell',
#    environment => ['HOME=/root', 'CA=/etc/openshift/master'],
#    cwd     => "/root",
#    command => "oadm create-server-cert --signer-cert=\$CA/ca.crt \
#      --signer-key=\$CA/ca.key --signer-serial=\$CA/ca.serial.txt \
#      --hostnames='*.cloudapps.example.com' \
#      --cert=cloudapps.crt --key=cloudapps.key && cat cloudapps.crt cloudapps.key \$CA/ca.crt > cloudapps.router.pem",
#    creates => '/root/cloudapps.router.pem',
#    require => [Service['openshift-master'], Exec['Run ansible'], Exec['Wait for master']],
#  }

#  exec { 'Install router':
#    provider => 'shell',
#    environment => 'HOME=/root',
#    cwd     => "/root",
##    command => "oadm router --default-cert=cloudapps.router.pem \
#    command => "oadm router \
#--credentials=/etc/openshift/master/openshift-router.kubeconfig \
#--images='registry.access.redhat.com/openshift3/ose-\${component}:\${version}'",
#    unless => "oadm router",
#    timeout => 600,
#    require => Exec['Create wildcard certificate'],
#  }

  exec { 'Install registry':
    provider => 'shell',
    environment => 'HOME=/root',
    cwd     => "/root",
    command => "mkdir -p /mnt/registry && oadm registry --config=/etc/openshift/master/admin.kubeconfig \
      --credentials=/etc/openshift/master/openshift-registry.kubeconfig \
      --images='registry.access.redhat.com/openshift3/ose-\${component}:\${version}'", # \
#      --mount-host=/mnt/registry",
    unless => "oadm registry",
    timeout => 600,
    require => Class['openshift3::router'],
  }
}
