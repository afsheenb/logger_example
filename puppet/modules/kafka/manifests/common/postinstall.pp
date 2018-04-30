# == Class kafka::common::postinstall
#
# Preparation steps after installation. It switches kafka-conf alternative, if enabled.
#
class kafka::common::postinstall {
  ::hadoop_lib::postinstall{'kafka':
    alternatives => $::kafka::alternatives,
  }
}
