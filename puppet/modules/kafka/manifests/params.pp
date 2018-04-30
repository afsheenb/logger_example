# == Class kafka::params
#
# This class is meant to be called from kafka.
# It sets variables according to platform.
#
class kafka::params {
  case $::osfamily {
    default: {
      $confdir = '/etc/kafka/conf'
      $envfile_server = '/etc/default/kafka-server'
      $homedir = '/var/lib/kafka'
      $package_name = 'kafka-server'
      $package_client_name = 'kafka'
      $service_name = 'kafka-server'
    }
  }

  $cacerts = '/etc/security/cacerts'
  $cacerts_password = ''
  $keystore = '/etc/security/server.keystore'
  $keystore_password = 'changeit'
  $keystore_keypassword = undef
}
