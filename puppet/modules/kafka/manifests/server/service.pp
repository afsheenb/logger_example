# == Class kafka::server::service
#
# Ensure the Kafka broker service is running.
#
class kafka::server::service {
  if $::kafka::service_name {
    service { $::kafka::service_name:
      ensure     => running,
      enable     => true,
      hasstatus  => true,
      hasrestart => true,
    }
  }
}
