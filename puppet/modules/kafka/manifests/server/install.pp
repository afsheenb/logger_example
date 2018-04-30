# == Class kafka::server::install
#
# Installation of Kafka broker.
#
class kafka::server::install {
  include ::stdlib

  if ($::kafka::package_name) {
    contain kafka::common::postinstall
    ensure_packages($::kafka::package_name)
    Package[$::kafka::package_name] -> Class['kafka::common::postinstall']
  }
}
