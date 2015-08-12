define openshift3::oc_replace ($namespace = undef, $resource, $logoutput = false) {
  case $title {
    /^([0-9a-zA-Z_.\[\]]+)\s*=\s*(-?[0-9]+|".+"|{.+}|true|false)$/:            { $unless = "$1 == $2" }
    /^([0-9a-zA-Z_.\[\]]+)\s*\+=\s*(\[-?[0-9]+\]|\["[^"]+"\])$/:  { $unless = "$1 | contains($2)" }
    default:                                                { fail("Unsupported expression: $title") }
  }

  if $namespace {
    $namespace_opt = "--namespace=${namespace}"
  } else {
    $namespace_opt =""
  }

  exec { $title:
    provider => 'shell',
    environment => 'HOME=/root',
    cwd     => "/root",
    command => "oc get ${namespace_opt} '${resource}' -o json | jq '$title' | oc replace ${namespace_opt} '${resource}' -f -",
    unless => "oc get ${namespace_opt} '${resource}' -o json | [ `jq '$unless'` == true ]",
    timeout => 600,
    logoutput => $logoutput,
  }
}
