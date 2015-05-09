Exec { path => '/sbin:/bin:/usr/sbin:/usr/bin', }

#Package { 
#    allow_virtual => true,
#}

if $::vagrant {
  $ose_hosts = parsejson($::ose_hosts)
  $master_fqdn = $ose_hosts[0]['hostname']
} else {
  $master_fqdn = 'victory.rz.puzzle.ch'
}

node 'ose3-master.example.com' {
  include openshift3::master
  include openshift3::node
}

node /ose3-node\d+.example.com/ {
  include openshift3::node
}

node 'victory.rz.puzzle.ch' {
  include openshift3::master
  include openshift3::node
}
