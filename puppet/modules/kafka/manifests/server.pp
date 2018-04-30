# Class: kafka::server
#
# Kafka broker
#
class kafka::server {
  class { '::kafka::server::install': }
  -> class { '::kafka::server::config': }
  ~> class { '::kafka::server::service': }
  -> Class['::kafka::server']
}
