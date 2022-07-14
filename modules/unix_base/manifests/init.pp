class unix_base {
  package {['htop', "${globals::openssl_package}"]:
    ensure => latest;
  }

  service {
    ['puppet', 'pxp-agent']:
      enable => false,
      ensure => 'stopped';
  }
}
