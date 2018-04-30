# == Class kafka::client::config
#
# Stub class
#
class kafka::client::config {
  $environment = $::kafka::_environment['client']
  file { '/etc/profile.d/kafka.sh':
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('kafka/env.sh.erb'),
  }
  file { '/etc/profile.d/kafka.csh':
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('kafka/env.csh.erb'),
  }

  kafka::properties { "${kafka::confdir}/client.properties":
    owner      => 'root',
    group      => 'root',
    mode       => '0644',
    properties => $::kafka::_properties['client'],
  }
  kafka::properties { "${kafka::confdir}/consumer.properties":
    owner      => 'root',
    group      => 'root',
    mode       => '0644',
    properties => $::kafka::_properties['consumer'],
  }
  kafka::properties { "${kafka::confdir}/producer.properties":
    owner      => 'root',
    group      => 'root',
    mode       => '0644',
    properties => $::kafka::_properties['producer'],
  }

  if $::kafka::realm and $::kafka::realm != '' {
    file { "${::kafka::confdir}/jaas-client.conf":
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => template('kafka/jaas-client.conf.erb'),
    }
  } else {
    file { "${::kafka::confdir}/jaas-client.conf":
      ensure => 'absent',
    }
  }
}
