# Class: kafka::client
#
# Kafka client
#
class kafka::client {
  class { '::kafka::client::install': }
  -> class { '::kafka::client::config': }
  -> Class['::kafka::client']
}
