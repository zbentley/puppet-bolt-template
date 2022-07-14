class osx_base {
  Package <| |> -> file {
      ['/usr/local/share/zsh', '/usr/local/share/zsh/site-functions']:
        ensure => directory,
        mode   => '0755';
      "${globals::workstation_homedir}/Desktop/Applications":
        ensure => symlink,
        target => '/Applications';
  }

  service { 'ssh_agent':
      ensure => running,
      enable => true,
      name => 'com.openssh.ssh-agent';
  }
}
