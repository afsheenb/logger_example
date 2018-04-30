node /^pb-server-*/ inherits default {


$src= '/usr/src/ozone'
file { [ "$src", "$src/docker", "$src/docker/pbs", "$src/docker/flask"]:
  ensure => directory,
  owner  => 'ubuntu',
  group  => 'ubuntu',
  mode   => 0644,
}


vcsrepo{'/usr/src/ozone/prebid-server':
 provider => git,
 ensure => present,
 revision => 'master',
 source => 'https://e58149d161fce7bf01ef73f4002cb4e03261ee28@github.com/ozone-project/prebid-server.git'
}

include docker

docker::image { 'pbs':
  docker_file => '/usr/src/ozone/docker/pbs/Dockerfile',
  subscribe => File['/usr/src/ozone/docker/pbs/Dockerfile'],
}

file { '/usr/src/ozone/docker/pbs/Dockerfile':
  ensure => file,
  source => 'puppet:///modules/images/pbs/Dockerfile',
}

docker::image { 'flask':
  docker_file => '/usr/src/ozone/docker/flask/Dockerfile',
  subscribe => File['/usr/src/ozone/docker/flask/Dockerfile'],
}

file { '/usr/src/ozone/docker/flask/Dockerfile':
  ensure => file,
  source => 'puppet:///modules/images/flask/Dockerfile',
}

docker::run { 'prebid-server':
  image           => 'pbs',
  ports           => ['8000:8000', '6060:6060'],
  net             => 'host',
  command         => '/bin/bash -c "cd /go/src/github.com/prebid/prebid-server && dep ensure && go build . && ./prebid-server"',
  volumes         => ['/usr/src/ozone/:/go/src/github.com/prebid'],
  dns             => ['8.8.8.8', '8.8.4.4'],
  restart_service => true,
  privileged      => false,
  pull_on_start   => false,
  before_stop     => 'echo "prebid-server container being shut down by Puppet"',
  extra_parameters => [ '--log-opt max-size=500m' ],
}

docker::run { 'postgres':
  image           => 'postgres:9.6',
  net             => 'host',
  dns             => ['8.8.8.8', '8.8.4.4'],
  restart_service => true,
  privileged      => false,
  pull_on_start   => false,
  before_stop     => 'echo "postgres container being shut down by Puppet"',
  extra_parameters => [ '--log-opt max-size=500m' ],
}

docker::run { 'filter':
  image           => 'flask',
  dns             => ['8.8.8.8', '8.8.4.4'],
  volumes         => ['/usr/src/ozone/:/usr/src/ozone/'],
  ports           => ['8082:8082'],
  command         => '/bin/bash -c "cd /usr/src/ozone/filter && python filter.py"',
  restart_service => true,
  privileged      => false,
  pull_on_start   => false,
  before_stop     => 'echo "filter container being shut down by Puppet"',
  extra_parameters => [ '--log-opt max-size=500m' ],
}

docker::run { 'enrich':
  image           => 'flask',
  dns             => ['8.8.8.8', '8.8.4.4'],
  volumes         => ['/usr/src/ozone/:/usr/src/ozone/'],
  command         => '/bin/bash -c "cd /usr/src/ozone/enricher && python enrich.py"',
  ports		  => ['8081:8081'],
  restart_service => true,
  privileged      => false,
  pull_on_start   => false,
  before_stop     => 'echo "enrich container being shut down by Puppet"',
  extra_parameters => [ '--log-opt max-size=500m' ],

}

}
