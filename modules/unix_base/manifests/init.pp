class unix_base {
  package {['htop', "${globals::openssl_package}"]:
    ensure => latest;
  }
}
