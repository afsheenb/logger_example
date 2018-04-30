## Kafka

[![Build Status](https://travis-ci.org/MetaCenterCloudPuppet/cesnet-kafka.svg?branch=master)](https://travis-ci.org/MetaCenterCloudPuppet/cesnet-kafka) [![Puppet Forge](https://img.shields.io/puppetforge/v/cesnet/kafka.svg)](https://forge.puppetlabs.com/cesnet/kafka)

#### Table of Contents

1. [Module Description - What the module does and why it is useful](#module-description)
2. [Setup - The basics of getting started with kafka](#setup)
    * [What cesnet-kafka affects](#what-cesnet-kafka-affects)
    * [Setup requirements](#setup-requirements)
3. [Usage - Configuration options and additional functionality](#usage)
    * [Security](#security)
     * [Auth to local mapping](#auth-to-local-mapping)
    * [SSL](#ssl)
    * [IPv6](#ipv6)
    * [Best Practices](#best-practices)
4. [Client Examples](#client-example)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
    * [Module Parameters](#parameters)
6. [Limitations - OS compatibility, etc.](#limitations)
7. [Development - Guide for contributing to the module](#development)

## Module Description

This module installs and configures Apache Kafka brokers.

It expects list of hostnames, where brokers should be running. Broker IDs will be generated according to the ordering of these hostnames.

Puppet module takes list of the zookeeper servers from zookeeper puppet module.

Tested on:

* Debian 7/wheezy: BigTop 1.2.0/Kafka 0.10.1.1 (custom build)
* Debian 8/jessie: BigTop 1.2.0/Kafka 0.10.1.1 (custom build)

## Setup

### What cesnet-kafka affects

* Packages: Kafka server package
* Alternatives:
 * alternatives are used for */etc/kafka/conf* in BigTop-based distributions
 * this module switches to the new alternative by default on Debian, so the original configuration can be kept intact
* Files modified:
 * */etc/default/kafka-server*
 * */etc/kafka/conf/\**: properties, JAAS config files
 * */etc/profile.d/kafka.csh*
 * */etc/profile.d/kafka.sh*
 * */usr/lib/kafka/bin/kafka-server-startup.sh*: added line to load */etc/default/kafka-server*
* Secret Files (keytabs, certificates):
 * */etc/security/server.keystore*: copied to kafka home directory */var/lib/kafka*
 * */etc/security/keytab/kafka.service.keytab*: file owner is changed

### Setup Requirements

There are several known or intended limitations in this module.

Be aware of:

* **Repositories** - no repository is setup, see cesnet-hadoop module Setup Requirements for details

## Usage

**Example 1**: automatic ID assignments

    kafka_brokers = [
      'broker1.example.com',
      'broker2.example.com',
    ]
    zookeeper_hostnames = [
      'zoo1.example.com',
      'zoo2.example.com',
      'zoo3.example.com',
    ]

    class{'kafka':
      hostnames           => $kafka_brokers,
      zookeeper_hostnames => $zookeeper_hostnames,
    }

    node /zoo.\.example'.com/ {
      class{'zookeeper':
        hostnames => $zookeeper_hostnames,
      }
    }

    node /broker.\.example'.com/ {
      include ::kafka::server
    }

    node 'client.example.com' {
      include ::kafka::client
    }

**Example 2**: manual ID assignments

    kafka_brokers = [
      'broker1.example.com',
      'broker2.example.com',
    ]
    zookeeper_hostnames = [
      'zoo1.example.com',
      'zoo2.example.com',
      'zoo3.example.com',
    ]

    node /zoo.\.example\.com/ {
      class{'zookeeper':
        hostnames => $zookeeper_hostnames,
      }
    }

    node 'broker1.example.com' {
      class{'kafka':
        id                  => 1,
        zookeeper_hostnames => $zookeeper_hostnames,
      }
      include ::kafka::server
    }

    node 'broker2.example.com' {
      class{'kafka':
        id                  => 2,
        zookeeper_hostnames => $zookeeper_hostnames,
      }
      include ::kafka::server
    }

    node 'client.example.com' {
      class{'kafka':
        zookeeper_hostnames => $zookeeper_hostnames,
      }
      include ::kafka::client
    }

### Security

It is possible to enable authentication using Kerberos.

Kerberos keytab file needs to be prepared in */etc/security/keytab/kafka.service.keytab* location (can be changed by *keytab* parameter).

Principal name: *kafka/HOSTNAME*

**Example**:

    class{'kafka':
      hostnames           => $kafka_brokers,
      zookeeper_hostnames => $zookeeper_hostnames,
      realm               => 'EXAMPLE.COM',
    }

#### Auth to local mapping

Kerberos principal mapping rules are set as:

* *kafka/&lt;HOST&gt;@&lt;REALM&gt;* -&gt; *kafka*
* *zookeeper/&lt;HOST&gt;@&lt;REALM&gt;* -&gt; *zookeeper*
* *DEFAULT*

This can be overridden by *sasl.kerberos.principal.to.local.rules* server property, which accepts comma separated list of rules.

In case there is no cross-realm Kerberos environment and standard "zookeeper" and "kafka" machine principals are used, you can remove the property:

    class { 'kafka':
      ...
      properties => {
        'server' => {
          'sasl.kerberos.principal.to.local.rules' => '::undef',
        }
      },
    }

### SSL

Transport security can be enabled, independently on the authentication.

**Example**:

    class { 'kafka':
      hostnames                 => $kafka_brokers,
      zookeeper_hostnames       => $zookeeper_hostnames,
      ssl                       => true,
      #ssl_cacerts              => '/etc/security/cacerts',
      ssl_cacerts_password      => 'changeit',
      #ssl_keystore             => '/etc/security/server.keystore',
      ssl_keystore_password     => 'good-password',
      #ssl_keystore_keypassword => undef,
    }
    include ::kafka::server

Note, some Hadoop addons needs to have the key password the same as the keystore password. So it may be needed to leave *ssl_keystore_keypassword* as undef.

### IPv6

IPv6 is working out-of-the-box.

But on IPv4-only hosts with enabled IPv6 locally, you may need to set preference to IPv4 though. Everything is working, but there are unsuccessful connection attempts and exceptions in logs.

**IPv4 example without security**:

    class{'kafka':
      ...
      environment => {
        'client' => {
          'KAFKA_OPTS' => '-Djava.net.preferIPv4Stack=true',
        }
        'server' => {
          'KAFKA_OPTS' => '-Djava.net.preferIPv4Stack=true',
        }
      }
    }

**IPv4 example with security**:

    class{'kafka':
      realm => ...,
      ...
      environment => {
        'client' => {
          'KAFKA_OPTS' => '-Djava.security.auth.login.config=/etc/kafka/conf/jaas-client.conf -Djava.net.preferIPv4Stack=true',
        }
        'server' => {
          'KAFKA_OPTS' => '-Djava.security.auth.login.config=/etc/kafka/conf/jaas-server.conf -Djava.net.preferIPv4Stack=true',
        }
      }
    }

### Best Practices

Some best practices:

* use *log_dirs* parameter and directories on separated disks, or use RAID
* increase file descriptors limit (recommended minimal value is 128000)
* for performance reasons, keep flushing at default values and let OS to flush
* do not co-locate Zookeeper servers with Kafka brokers
* for robustness and scalability use more Kafka brokers

## Client Examples

Used environment:

    zoo=zoo1.example.com:2181,zoo2.example.com:2181/kafka
    brokers=broker1.example.com:9092,broker2.example.com:9092
    #SASL:     brokers=broker1.example.com:9093,broker2.example.com:9093
    #SSL:      brokers=broker1.example.com:9094,broker2.example.com:9094
    #SASL+SSL: brokers=broker1.example.com:9095,broker2.example.com:9095

Create a topic:

    kafka-topics.sh --create --zookeeper $zoo -replication-factor 1 --partitions 1 --topic test

List topics:

    kafka-topics.sh --list --zookeeper $zoo

Describe a topic:

    kafka-topics.sh --describe --zookeeper $zoo

Launch consumer:

    kafka-console-consumer.sh --bootstrap-server $brokers --topic test --from-beginning --consumer.config /etc/kafka/conf/client.properties

Launch producer:

    kafka-console-producer.sh --broker-list $brokers --topic test --producer.config /etc/kafka/conf/client.properties

## Reference

### Classes

* [**`kafka`**](#parameters): Main class
* **`kafka::server`**: Kafka broker
* `kafka::server::config`: Configure Kafka broker
* `kafka::server::install`: Installation of Kafka broker
* `kafka::server::service`: Ensure the Kafka broker service is running
* **`kafka::client`**: Kafka client
* `kafka::client::config`: Stub class
* `kafka::client::install`: Installation of Kafka client
* `kafka::client::service`: Stub class
* `kafka::params`

### Resources

* `kafka::properties`: Generic resource to generate properties files

### Parameters

Parameters of the main configuration class *kafka*.

####`acl_enable`

Enable ACL in Kafka. Default: undef.

Enables internal Kafka ACL. Nothing is permitted after enabling ACL. You need to explicitly set proper ACL.

See */usr/lib/kafka/bin/kafka-acls.sh* utility.

Alternatively *Sentry* can be used for authentication, see *sentry_enable* parameter.

####`alternatives`

Switches the alternatives used for the configuration. Default: 'cluster' (Debian) or undef.

It can be used only when supported (for example with distributions based on BigTop).

####`environment`

Environment variables to set. Default: undef.

Value is a hash with *client*, and *server* keys.

####`hostnames`

Array of Kafka broker hostnames. Default: undef.

Beware changing leads to changing Kafka broker ID, which requires internal data cleanups or manual internal metadata modification.

####`id`

ID of Kafka broker. Default: undef (=autodetect).

*id* is the ID number of the Kafka broker. It must be unique number for each broker.

By default, the ID is generated automatically as order of the node hostname (*::fqdn*) in the *hostnames* array.

Beware changing requires internal data cleanups or manual internal metadata modification.

####`log_dirs`

The directories, where the log data are kept. Default: undef.

For better performance it is recommended to use more directories on separated disks.

####`keytab`

Kerberos keytab file. Default: '/etc/security/keytab/kafka.service.keytab'.

Kerberos keytab file with principal *kafka/HOSTNAME*.

####`properties`

Generic properties to be set for the Kafka brokers. Default: undef.

Value is a hash with *client*, *consumer*, *producer*, and *server* keys.

All keys from *client* are merged into both *consumer* and *producer*.

Some properties are set automatically, "::undef" string explicitly removes given property. Empty string sets the empty value.

####`realm`

Kerberos realm. Default: ''.

Non-empty value will enable security with SASL support.

####`sentry_enable`

Enable Sentry authentication. Default: undef.

Sentry client is required to be configured on all Kafka brokers (*/etc/sentry/conf/sentry-site.xml* file created).

####`ssl`

Enable TLS. Default: undef.

####`ssl_cacerts`

CA certificates file. Default: '/etc/security/cacerts'.

####`ssl_cacerts_password`

CA certificates keystore password. Default: ''.

####`ssl_keystore`

Certificates keystore file. Default: '/etc/security/server.keystore'.

####`ssl_keystore_keypassword`

Certificates keystore key password. Default: undef.

If not specified, `ssl_keystore_password` is used.

####`ssl_keystore_password`

Certificates keystore file password. Default: 'changeit'.

####`zookeeper_hostnames`

Hostnames of zookeeper servers. Default: undef (from *zookeeper::hostnames* or 'localhost').

This parameter is not needed, if all Kafka brokers sits on any of the Zookeeper server node and *zookeeper::hostnames* parameter is used.

## Limitations

No repository is provided. It must be setup externally, or the Kafka packages must be installed already.

*zookeeper\_hostnames* parameter is a complication and optionally it should not be needed. But that would require refactoring of zookeeper puppet module - to separate zookeeper configuration class from zookeeper server setup.

Beside Kerberos, Kafka can be secured using passwords. This is not covered by this puppet module. It would be mostly about different *jaas-\*.conf* files, so it can be easily overridden, if needed.

## Development

* Repository: [https://github.com/MetaCenterCloudPuppet/cesnet-kafka](https://github.com/MetaCenterCloudPuppet/cesnet-kafka)
* Tests:
 * basic: see *.travis.yml*
