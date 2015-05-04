Exec { path => '/sbin:/bin:/usr/sbin:/usr/bin', }

Package { 
    allow_virtual => true,
}

node 'ose3-master.example.com' {
  include openshift3::master

  class { 'openshift3::node': is_master => true }
}

node /ose3-node\d+.example.com/ {
  include openshift3::node
}
