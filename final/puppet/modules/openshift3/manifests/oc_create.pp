define openshift3::oc_create ($resource, $definition) {
  exec { $title:
    provider => 'shell',
    environment => 'HOME=/root',
    cwd     => "/root",
    command => "echo '$definition' | oc create -f -",
    unless => "oc get $resource",
    timeout => 600,
  }
}
