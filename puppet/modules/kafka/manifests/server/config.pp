# == Class kafka::server::config
#
# Configure Kafka broker
#
class kafka::server::config {
  include ::stdlib

  $environment = $::kafka::_environment['server']
  file { $::kafka::envfile_server:
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('kafka/env.sh.erb'),
  }

  kafka::properties { "${::kafka::confdir}/server.properties":
    owner      => 'kafka',
    group      => 'kafka',
    mode       => '0640',
    properties => $::kafka::_properties['server'],
  }

  if ($::kafka::log_dirs) {
    ensure_resource('file', $::kafka::log_dirs, {
      ensure => directory,
      owner  => 'kafka',
      group  => 'kafka',
      mode   => '0755',
    })
  }

  # fix buggy startup script (BigTop 1.2.0)
  file_line { 'kafka-server-start.sh':
    ensure => present,
    path   => '/usr/lib/kafka/bin/kafka-server-start.sh',
    line   => ". ${::kafka::envfile_server}",
    after  => '^#.*/bin/bash',
  }

  if $::kafka::realm and $::kafka::realm != '' {
    $keytab = $::kafka::keytab
    $principal = "kafka/${::fqdn}@${::kafka::realm}"

    file { $keytab:
      owner => 'kafka',
      group => 'kafka',
      mode  => '0400',
    }

    file { "${::kafka::confdir}/jaas-server.conf":
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => template('kafka/jaas-server.conf.erb'),
    }
  } else {
    file { "${::kafka::confdir}/jaas-server.conf":
      ensure => 'absent',
    }
  }

  if $::kafka::ssl {
    file { "${::kafka::homedir}/keystore.server":
      owner  => 'kafka',
      group  => 'kafka',
      mode   => '0640',
      source => $::kafka::ssl_keystore,
    }
  }
}
