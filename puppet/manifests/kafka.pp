node /^kafka-*/ inherits default {


include docker

$src= '/usr/src/ozone'
file { [ "$src", "$src/docker", "$src/docker/kafka", "$src/docker/secor"]:
  ensure => directory,
  owner  => 'ubuntu',
  group  => 'ubuntu',
  mode   => 0644,
}

vcsrepo{'/usr/src/ozone/confluentinc/cp-docker-images':
 provider => git,
 ensure => present,
 revision => 'master',
 source => 'https://github.com/confluentinc/cp-docker-images.git'
}

vcsrepo{'/usr/src/ozone/ozone-code':
 provider => git,
 ensure => present,
 revision => 'master',
 source => 'https://e58149d161fce7bf01ef73f4002cb4e03261ee28@github.com/ozone-project/ozone-code.git'
}



file { '/usr/src/ozone/docker/kafka/Dockerfile':
  ensure => file,
  source => 'puppet:///modules/images/kafka/Dockerfile',
}

docker::image { 'kafka':
  docker_file => '/usr/src/ozone/docker/kafka/Dockerfile',
  subscribe => File['/usr/src/ozone/docker/kafka/Dockerfile'],
}


file { '/usr/src/ozone/docker/secor/Dockerfile':
  ensure => file,
  source => 'puppet:///modules/images/secor/Dockerfile',
}

docker::image { 'secor':
  docker_file => '/usr/src/ozone/docker/secor/Dockerfile',
  subscribe => File['/usr/src/ozone/docker/secor/Dockerfile'],
}

docker::run { 'secor-reqs':
  image           => 'secor',
  dns             => ['8.8.8.8', '8.8.4.4'],
  volumes         => ['/usr/src/ozone/:/usr/src/ozone/'],
  command         => '/bin/bash -c "cd /usr/src/ozone/ozone-code/secor && mvn package && tar -zxvf target/secor-0.26-SNAPSHOT-bin.tar.gz -C /secor_bin/ && cd /secor_bin/ && java -ea -Dsecor_group=secor_backup -Dlog4j.configuration=log4j.prod.properties -Dconfig=/usr/src/ozone/ozone-code/secor/secor.reqs.properties -cp secor-0.26-SNAPSHOT.jar:lib/* com.pinterest.secor.main.ConsumerMain"',
  restart_service => true,
  privileged      => false,
  pull_on_start   => false,
  before_stop     => 'echo "secor-reqs container being shut down by Puppet"',
  extra_parameters => [ '--log-opt max-size=500m' ],

}

docker::run { 'secor-bids':
  image           => 'secor',
  dns             => ['8.8.8.8', '8.8.4.4'],
  volumes         => ['/usr/src/ozone/:/usr/src/ozone/'],
  command         => '/bin/bash -c "cd /usr/src/ozone/ozone-code/secor && mvn package && tar -zxvf target/secor-0.26-SNAPSHOT-bin.tar.gz -C /secor_bin/ && cd /secor_bin/ && java -ea -Dsecor_group=secor_backup -Dlog4j.configuration=log4j.prod.properties -Dconfig=/usr/src/ozone/ozone-code/secor/secor.resp.properties -cp secor-0.26-SNAPSHOT.jar:lib/* com.pinterest.secor.main.ConsumerMain"',
  restart_service => true,
  privileged      => false,
  pull_on_start   => false,
  before_stop     => 'echo "secor-bids container being shut down by Puppet"',
  extra_parameters => [ '--log-opt max-size=500m' ],

}

docker::run { 'kafka':
  image           => 'kafka',
  dns             => ['8.8.8.8', '8.8.4.4'],
  ports           => ['9092:9092'],
  expose          => ['9092'],
  net             => 'host',
  env     => ['KAFKA_ADVERTISED_LISTENERS=plaintext://kafka-01.pootl.net:9092', 'KAFKA_ZOOKEEPER_CONNECT=localhost'],
  volumes         => ['/usr/src/ozone/:/usr/src/ozone/'],
  command         => '/bin/bash -c "cp -ar /usr/src/ozone/confluentinc/cp-docker-images/debian/kafka/include/etc/confluent/docker/* /etc/confluent/docker/ && /etc/confluent/docker/run"',
  restart_service => true,
  privileged      => false,
  pull_on_start   => false,
  before_stop     => 'echo "kafka container being shut down by Puppet"',
  extra_parameters => [ '--log-opt max-size=500m' ],

}

docker::run { 'zookeeper':
  image           => 'zookeeper',
  dns             => ['8.8.8.8', '8.8.4.4'],
  ports           => ['2181:2181'],
  expose          => ['2181'],
  net             => 'host',
  env             => ['ZOOKEEPER_CLIENT_PORT=2181'],
  volumes         => ['/usr/src/ozone/:/usr/src/ozone/'],
  restart_service => true,
  privileged      => false,
  pull_on_start   => false,
  before_stop     => 'echo "kafka container being shut down by Puppet"',
  extra_parameters => [ '--log-opt max-size=500m' ],

}


}


