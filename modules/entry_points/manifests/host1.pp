class entry_points::host1 {
  include unix_base

  if ($facts['os']['family'] == 'Darwin') {
      include osx_base
  }

  package {'dropbox':
    provider => brewcask;
  } -> osx_login_item {
    'Dropbox':
      ensure  => present,
      path    => '/Applications/Dropbox.app';
  }

  # I like Dropbox on my desktop; if you don't, delete the below.
  file {
    "${globals::workstation_homedir}/Desktop/Dropbox":
      ensure => "${globals::workstation_homedir}/Dropbox";
  }
}
