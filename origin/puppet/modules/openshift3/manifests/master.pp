class openshift3::master {
  include ::openshift3

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
    revision => 'master',
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
      $ansible_require = concat($_ansible_require, File['/root/.ssh/id_rsa'], Ssh_Authorized_Key['ose3'], Class['openshift3::dns'])
   } else {
      $ansible_require = $_ansible_require
   }

  # '.dnsConfig.bindAddress = "10.0.2.15:53"'


  if $::vagrant {
    file_line { 'Set DNS bind address':
      path => '/root/openshift-ansible/roles/openshift_master/templates/master.yaml.v1.j2',
      line => "  bindAddress: ${::network_primary_ip}:{{ openshift.master.dns_port }}",
      match => "^  bindAddress: {{ openshift.master.bind_addr }}:{{ openshift.master.dns_port }}$",
#      require => Exec['Run ansible'],
      require => Vcsrepo["/root/openshift-ansible"],
      before => Exec['Run ansible'],
    }

#    bindAddress: {{ openshift.master.bind_addr }}:{{ openshift.master.dns_port }}

#    yq { ".dnsConfig.bindAddress = \"${::network_primary_ip}:53\"":
#      file => '/etc/openshift/master/master-config.yaml',
#      notify => Service['openshift-master'],
#      require => Exec['Run ansible'],
#    } ->
  }

  exec { 'Run ansible':
    cwd     => "/root/openshift-ansible",
    command => "ansible-playbook playbooks/byo/config.yml",
    timeout => 1000,
#    logoutput => true,
    require => $ansible_require,
  } ->

  package { 'openshift-master':
    ensure => latest,
#    notify => Service['openshift-master'],
  } ~>

  service { 'openshift-master':
    enable => true,
    require => Package['openshift-master'],
  }

  package { 'openshift-node':
    ensure => latest,
    notify => Service['openshift-node'],
  } ~>

  service { 'openshift-node':
    enable => true,
    require => Package['openshift-node'],
  } ->

  docker::image { [
    "${::openshift3::component_prefix}-deployer",
    "${::openshift3::component_prefix}-pod",
    "${::openshift3::component_prefix}-haproxy-router",
    "${::openshift3::component_prefix}-docker-registry",
    "${::openshift3::component_prefix}-docker-builder",
    "${::openshift3::component_prefix}-sti-builder",
#    "registry.access.redhat.com/openshift3/ose-deployer",
#    'registry.access.redhat.com/openshift3/ose-sti-builder:v3.0.0.1',
#    'registry.access.redhat.com/openshift3/ose-docker-builder:v3.0.0.1',
#    "registry.access.redhat.com/openshift3/ose-pod",
#    'registry.access.redhat.com/openshift3/ose-docker-registry:v3.0.0.1',
#    'registry.access.redhat.com/openshift3/sti-basicauthurl:latest',
##    'openshift/ruby-20-centos',
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
#--credentials=/etc/openshift/master/openshift-router.kubeconfig", # \
## --images='registry.access.redhat.com/openshift3/ose-\${component}:\${version}'",
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
      --images='${::openshift3::component_images}'", # \
#      --mount-host=/mnt/registry",
    unless => "oadm registry",
    timeout => 600,
    require => Class['openshift3::router'],
  }
}
