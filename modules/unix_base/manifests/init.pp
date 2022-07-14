class unix_base {
  package {['htop', "${globals::openssl_package}"]:
    ensure => latest;
  }

  service {
    ['puppet', 'pxp-agent']:
      enable => false,
      ensure => 'stopped';
    'ssh_agent':
      ensure => running,
      enable => true,
      name     => $facts['os']['family'] ? {
        'Darwin' => 'com.openssh.ssh-agent',
        default => 'sshd',
      };
  }
}
