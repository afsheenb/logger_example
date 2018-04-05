node /^telescope-*/ inherits default {

class { '::cloudwatchlogs': region => 'us-west-2' }

cloudwatchlogs::log { 'Messages':
  path => '/var/log/messages',
}
cloudwatchlogs::log { 'Secure':
  path => '/var/log/secure',
}


include haproxy-config

$src= '/usr/src/rankscience'
file { [ "$src", "$src/docker", "$src/docker/telescope", "$src/docker/haproxy", "$src/docker/nginx", "$src/docker/lens"]:
  ensure => directory,
  owner  => 'ubuntu',
  group  => 'ubuntu',
  mode   => 0644,
}



vcsrepo{'/usr/src/rankscience/haproxy-confd':
 provider => git,
 ensure => present,
 revision => 'master',
 source => 'https://cfd3e255774fa8744669b573474b0bcff6b30f22@github.com/rankscience/haproxy-confd.git'
}


vcsrepo{'/usr/src/rankscience/telescope':
 provider => git,
 ensure => present,
 revision => 'master',
 source => 'https://cfd3e255774fa8744669b573474b0bcff6b30f22@github.com/rankscience/telescope.git'
}

vcsrepo{'/usr/src/rankscience/lens-dev':
 provider => git,
 ensure => present,
 revision => 'master',
 source => 'https://cfd3e255774fa8744669b573474b0bcff6b30f22@github.com/rankscience/lens.git'
}

vcsrepo{'/usr/src/rankscience/prism-stage':
 provider => git,
 ensure => present,
 revision => 'master',
 source => 'https://cfd3e255774fa8744669b573474b0bcff6b30f22@github.com/rankscience/prism.git'
}

vcsrepo{'/usr/src/rankscience/prism-prod':
 provider => git,
 ensure => present,
 revision => 'master',
 source => 'https://cfd3e255774fa8744669b573474b0bcff6b30f22@github.com/rankscience/prism.git'
}

vcsrepo{'/usr/src/rankscience/galileo-dev':
 provider => git,
 ensure => present,
 revision => 'master',
 source => 'https://cfd3e255774fa8744669b573474b0bcff6b30f22@github.com/rankscience/galileo.git'
}

vcsrepo{'/usr/src/rankscience/galileo-stage':
 provider => git,
 ensure => present,
 revision => 'master',
 source => 'https://cfd3e255774fa8744669b573474b0bcff6b30f22@github.com/rankscience/galileo.git'
}

vcsrepo{'/usr/src/rankscience/galileo-prod':
 provider => git,
 ensure => present,
 revision => 'master',
 source => 'https://cfd3e255774fa8744669b573474b0bcff6b30f22@github.com/rankscience/galileo.git'
}

vcsrepo{'/usr/src/rankscience/transforms':
 provider => git,
 ensure => present,
 revision => 'master',
 source => 'https://cfd3e255774fa8744669b573474b0bcff6b30f22@github.com/rankscience/transforms.git'
}

include pm2
include docker

docker::image { 'telescope':
  docker_file => '/usr/src/rankscience/docker/telescope/Dockerfile',
  subscribe => File['/usr/src/rankscience/docker/telescope/Dockerfile'],
}

file { '/usr/src/rankscience/docker/telescope/Dockerfile':
  ensure => file,
  source => 'puppet:///modules/images/telescope/Dockerfile',
}

docker::image { 'haproxy-confd':
  docker_file => '/usr/src/rankscience/docker/haproxy/Dockerfile',
  subscribe => File['/usr/src/rankscience/docker/haproxy/Dockerfile'],
}

file { '/usr/src/rankscience/docker/haproxy/Dockerfile':
  ensure => file,
  source => 'puppet:///modules/images/haproxy/Dockerfile',
}

docker::image { 'nginx':
  docker_file => '/usr/src/rankscience/docker/nginx/Dockerfile',
  subscribe => File['/usr/src/rankscience/docker/nginx/Dockerfile'],
}

file { '/usr/src/rankscience/docker/nginx/Dockerfile':
  ensure => file,
  source => 'puppet:///modules/images/nginx/Dockerfile',
}


docker::image { 'lens':
  docker_file => '/usr/src/rankscience/docker/lens/Dockerfile',
  subscribe => File['/usr/src/rankscience/docker/lens/Dockerfile'],
}

file { '/usr/src/rankscience/docker/lens/Dockerfile':
  ensure => file,
  source => 'puppet:///modules/images/lens/Dockerfile',
}


docker::run { 'prism-stage':
  image           => 'telescope',
  command         => '/bin/sh -c "cd /rankscience/prism-stage; yarn install; yarn build; /rankscience/pm2/deploy-stage.sh"',
  ports           => ['8091:5050'],
  net             => 'host',
  volumes         => ['/usr/src/rankscience/:/rankscience'],
  env             => ['PRISM_PORT=8091','TELENV=prism-stage','GALILEO_HOST=172.17.0.1','GALILEO_PORT=8092','AWS_ACCESS_KEY_ID=AKIAI4W5M3VHGEOQP4EQ', 'AWS_SECRET_ACCESS_KEY=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', 'GALILEO_TRANSFORMS_PATH=/rankscience/transforms'],
  dns             => ['8.8.8.8', '8.8.4.4'],
  restart_service => true,
  privileged      => false,
  pull_on_start   => false,
  before_stop     => 'echo "prism-dev container being shut down by Puppet"',
  extra_parameters => [ '--cpuset-cpus=0,3' ],
}

docker::run { 'galileo-stage':
  image           => 'telescope',
  command         => '/bin/sh -c "cd /rankscience/galileo-stage; yarn install; yarn build; /rankscience/pm2/deploy-stage.sh"',
  ports           => ['8092:6060'],
  net             => 'host',
  volumes         => ['/usr/src/rankscience/:/rankscience'],
  env             => ['GALILEO_PORT=8092','TELENV=galileo-stage','AWS_ACCESS_KEY_ID=AKIAI4W5M3VHGEOQP4EQ', 'AWS_SECRET_ACCESS_KEY=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', 'GALILEO_TRANSFORMS_PATH=/rankscience/transforms'],
  dns             => ['8.8.8.8', '8.8.4.4'],
  restart_service => true,
  privileged      => false,
  pull_on_start   => false,
  before_stop     => 'echo "galileo-stage container being shut down by Puppet"',
  extra_parameters => [ '--cpuset-cpus=1,2' ],
}

docker::run { 'prism-prod':
  image           => 'telescope',
  command         => '/bin/sh -c "cd /rankscience/prism-prod; yarn install; yarn build; /rankscience/pm2/deploy.sh"',
  ports           => ['8001:5050'],
  net             => 'host',
  volumes         => ['/usr/src/rankscience/:/rankscience'],
  env             => ['PRISM_PORT=8001','TELENV=prism-prod','GALILEO_HOST=127.0.0.1','PRISM_PORT=8001','AWS_ACCESS_KEY_ID=AKIAI4W5M3VHGEOQP4EQ', 'AWS_SECRET_ACCESS_KEY=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', 'GALILEO_TRANSFORMS_PATH=/rankscience/transforms'],
  dns             => ['8.8.8.8', '8.8.4.4'],
  restart_service => true,
  privileged      => false,
  pull_on_start   => false,
  before_stop     => 'echo "prism-stage container being shut down by Puppet"',
  extra_parameters => [ '--cpuset-cpus=4,5' ],
}

docker::run { 'galileo-prod':
  image           => 'telescope',
  command         => '/bin/sh -c "cd /rankscience/galileo-prod; yarn install; yarn build; /rankscience/pm2/deploy.sh"',
  ports           => ['8002:6060'],
  net             => 'host',
  volumes         => ['/usr/src/rankscience/:/rankscience'],
  env             => ['GALILEO_PORT=8002','TELENV=galileo-prod','AWS_SECRET_ACCESS_KEY=5f8PAfSvkPyh5Lti7Ju32WEWlUFGX2poapoki8SD', 'GALILEO_TRANSFORMS_PATH=/rankscience/transforms'],
  dns             => ['8.8.8.8', '8.8.4.4'],
  restart_service => true,
  privileged      => false,
  pull_on_start   => false,
  before_stop     => 'echo "galileo-prod container being shut down by Puppet"',
  extra_parameters => [ '--cpuset-cpus=6,7' ],
}

docker::run { 'transforms':
  image           => 'telescope',
  volumes         => ['/usr/src/rankscience/:/rankscience'],
  command         => '/bin/sh -c "cd /rankscience; ./telescope/pull-transforms.sh"',
  net             => 'host',
  env             => ['AWS_ACCESS_KEY_ID=AKIAI4W5M3VHGEOQP4EQ', 'AWS_SECRET_ACCESS_LEY=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'],
  dns             => ['8.8.8.8', '8.8.4.4'],
  restart_service => true,
  privileged      => false,
  pull_on_start   => false,
  before_stop     => 'echo "transforms-prod container being shut down by Puppet"',
  extra_parameters => [ '--cpuset-cpus=0' ],
}

docker::run { 'haproxy-confd':
  image           => 'haproxy-confd',
  volumes         => ['/usr/src/rankscience/:/rankscience'],
  command         => '/bin/bash -c "/usr/local/sbin/haproxy -f /rankscience/haproxy-prod-config/haproxy.conf"',
  ports           => ['80:80','8080:8008'],
  net             => 'host',
  dns             => ['8.8.8.8', '8.8.4.4'],
  restart_service => true,
  privileged      => false,
  pull_on_start   => false,
  before_stop     => 'echo "haproxy container being shut down by Puppet"',
  extra_parameters => [ '--cpuset-cpus=1,2' ],
}

}
