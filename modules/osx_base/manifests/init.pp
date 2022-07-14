class osx_base {
  Package <| provider == tap |> -> Package <| provider == homebrew |>
  Package <| provider == tap |> -> Package <| provider == brew |>
  Package <| provider == tap |> -> Package <| provider == brewcask |>
  Package <| |> -> file {
      ['/usr/local/share/zsh', '/usr/local/share/zsh/site-functions']:
        ensure => directory,
        mode   => '0755';
      "${globals::workstation_homedir}/Desktop/Applications":
        ensure => symlink,
        target => '/Applications';
  }
}
