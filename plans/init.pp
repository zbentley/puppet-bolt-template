plan template (
  Boolean $noop,
  String $user,
  TargetSpec $target
) {
  run_task('puppet_agent::install', $target, collection => 'puppet-nightly')
  apply_prep($target)
  $results = apply($target, _noop => $noop, _catch_errors => true) {
    class {'globals':
      workstation_user => $user,
      target => $target;
    }
  }
  $results.each |$result| {
    if $result.report {
      $result.report['logs'].each |$log| {
        out::message("${log['level'].upcase}: ${log['source']} : ${log['message']}")
      }
    }
  }
  return $results
}
