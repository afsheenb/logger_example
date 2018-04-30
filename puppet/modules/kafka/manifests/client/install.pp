# == Class kafka::client::install
#
# Installation of Kafka client
#
class kafka::client::install {
  include ::stdlib

  if ($::kafka::package_client_name) {
    contain kafka::common::postinstall
    ensure_packages($::kafka::package_client_name)
    Package[$::kafka::package_client_name] -> Class['kafka::common::postinstall']
  }
}
