define openshift3::oq ($resource, $update, $unless) {
  exec { $title:
    provider => 'shell',
    environment => 'HOME=/root',
    cwd     => "/root",
    command => "oc get '${resource}' -o json | jq '$update' | oc update '${resource}' -f -",
    unless => "oc get '${resource}' -o json | [ `jq '$unless'` == true ]",
    timeout => 600,
#    require => Exec['Create router service account'],
  }
}
