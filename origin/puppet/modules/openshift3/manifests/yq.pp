define openshift3::yq ($file, $logoutput = false) {
  case $title {
    /^([0-9a-zA-Z_.\[\]]+)\s*=\s*(-?[0-9]+|".+"|{.+}|true|false)$/:            { $unless = "$1 == $2" }
    /^([0-9a-zA-Z_.\[\]]+)\s*\+=\s*(\[-?[0-9]+\]|\["[^"]+"\])$/:  { $unless = "$1 | contains($2)" }
    default:                                                { fail("Unsupported expression: $title") }
  }

  exec { $title:
    provider => 'shell',
    environment => 'HOME=/root',
    cwd     => "/root",
    command => "yq '${title}' <${file} >${file}.tmp && mv ${file}.tmp ${file}",
    unless => "[ `yq '${unless}' <${file}` == true ]",
    timeout => 600,
    logoutput => $logoutput,
  }
}
