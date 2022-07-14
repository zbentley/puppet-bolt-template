class globals (String $workstation_user, String $target) {
  $_hiera_probe = lookup('toplevel_key')  # Just for example
  if ($facts['os']['family'] == 'Darwin') {
    if $globals::workstation_user == 'root' {
      fail("Workstation user of root won't work on OSX")
    }

    $workstation_homedir = "/Users/${workstation_user}"
    $openssl_package = "openssl@1.1"
    $exec_settings = {
      environment => [
        "HOME=${workstation_homedir}",
        "USER=${workstation_user}",
        'HOMEBREW_NO_AUTO_UPDATE=1',
        'HOMEBREW_NO_INSTALL_CLEANUP=1',  # I like running cleanup myself, manually, rather than slowing down installs.
        "SDKROOT=${facts['osx_sdkroot']}",
        "MACOSX_DEPLOYMENT_TARGET=${facts['os']['release']['major']}.${facts['os']['release']['major']}"
      ],
      group => "staff",
    }

    Osx_default {
      user => $globals::workstation_user,
    }

    Package {
      provider => brew,
    }

    Package <| provider == tap |> -> Package <| provider == homebrew |>
    Package <| provider == tap |> -> Package <| provider == brew |>
    Package <| provider == tap |> -> Package <| provider == brewcask |>

    $file_settings = {
      group => 'staff',
      owner => $globals::workstation_user
    }
  } else {
    $exec_settings = {
      environment => ["USER=${workstation_user}"]
    }
    $workstation_homedir = "/home/${workstation_user}"
    $openssl_package = "openssl"
    $file_settings = {
      owner => $globals::workstation_user
    }
  }

  notify {"Executing bolt for workstation user ${workstation_user} (homedir: ${workstation_homedir}); hiera probe: ${_hiera_probe}": }
  Exec {
    path => [
      "${globals::workstation_homedir}/bin",
      '/opt/puppetlabs/bin',
      '/usr/local/bin',
      '/usr/bin',
      '/bin',
      '/usr/sbin',
      '/sbin',
    ],
    * => $exec_settings,
    # logoutput => true
  }
  File {
    * => $file_settings,
  }

  # Run the main entry point. This must be done here since the resource defaults ('Exec {' and the like above) only
  # apply "downward". Resource defaults should generally be avoided for that reason, but in this case we use them to
  # provide a common substrate to all of the rest of our Puppet code, so it's desirable.
  class {"entry_points::${target}": }
}
