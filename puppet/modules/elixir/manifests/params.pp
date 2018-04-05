# == Class elixir::params
#
# This class is meant to be called from elixir
# It sets variables according to platform
#
class elixir::params {
  $version = '1.3.3'
  case $::osfamily {
    'Debian': {}
    default: {
      fail("${::operatingsystem} not supported")
    }
  }
}
