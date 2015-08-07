class openshift3::router {

  exec { 'Create router service account':
    provider => 'shell',
    environment => 'HOME=/root',
    cwd     => "/root",
    command => 'echo \
      \'{"kind":"ServiceAccount","apiVersion":"v1","metadata":{"name":"router"}}\' \
      | oc create -f -',
    unless => "oc get sa router",
    timeout => 600,
  } ->

  oq { 'Make router service account privileged':
    resource => 'scc/privileged',
    update => '.users = .users + ["system:serviceaccount:default:router"]',
    unless => '.users | contains(["system:serviceaccount:default:router"])',
  }

#  exec { 'Make router service account privileged':
#    provider => 'shell',
#    environment => 'HOME=/root',
#    cwd     => "/root",
#    command => "oq scc/privileged ! '.users = .users + [\"system:serviceaccount:default:router\"]'",
#    unless => "oq scc/privileged ? '.users | contains([\"system:serviceaccount:default:router\"])'",
#    timeout => 600,
#  } ->


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

  exec { 'Install router':
    provider => 'shell',
    environment => 'HOME=/root',
    cwd     => "/root",
#    command => "oadm router --default-cert=cloudapps.router.pem \
    command => "oadm router router --replicas=1 \
--credentials=/etc/openshift/master/openshift-router.kubeconfig \
--images='registry.access.redhat.com/openshift3/ose-\${component}:\${version}' \
--service-account=router",
    unless => "oadm router",
    timeout => 600,
#    require => Exec['Create wildcard certificate'],
#    require => Exec['Make router service account privileged'],
  } ->

#  exec { 'Set router image version':
#    provider => 'shell',
#    environment => 'HOME=/root',
#    cwd     => "/root",
#    command => "oq dc/router ! '.spec.template.spec.containers[0].image = \"registry.access.redhat.com/openshift3/ose-haproxy-router:${::openshift3::version}\"'",
#    unless => "oq dc/router ? '.spec.template.spec.containers[0].image == \"registry.access.redhat.com/openshift3/ose-haproxy-router:${::openshift3::version}\"'",
#    timeout => 600,
#  }

  oq { 'Set router image version':
    resource => 'dc/router',
    update => ".spec.template.spec.containers[0].image = \"registry.access.redhat.com/openshift3/ose-haproxy-router:${::openshift3::version}\"",
    unless => ".spec.template.spec.containers[0].image == \"registry.access.redhat.com/openshift3/ose-haproxy-router:${::openshift3::version}\"",
  }
}
