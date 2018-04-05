node puppet inherits default {

include docker

accounts::user { 'robert':
  comment => 'Robert Wilson',
  ensure => 'present',
  groups  => [
    'admin',
  ],
  uid     => '1103',
  gid     => '1103',
  sshkeys => [
'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCgsJ/4jVLrlZ738q/zsLn8FqNEgEPZL/hLGBcY8RYR/JefY53A5rHicdG0VBVBNDN6teDoBH5zwKoHlLiE6R+dru2/QX8BoMKMSK1E/404rTJIhM+NBnMKSp1eLp1OpbomEj83xOoUrwJWHc/9uRLE/dHnmLRn7yq4eWIbWwxpe09uzOJwXmTafpn8MnhBK8vT/MOg92FRddopv0+abStEsGztCMhhGx+Q/njfoMga+Mel536AhknaNB4m7ZrxRO+QPA89Wbj+pvLZUf++ycyzc0ErUQ90P0mu5k2/rH9xOkkA4TNNKo5+3A/cH/25FODNfUmjEiwzQp79yZgVhyucWU8x7EE+hwd4TXawWHHIt7cMrHOMP5/7AdE8WoWIqEvRkt+YOPoq+MbbjLOpm8yVeKE6TRPDHi1yqWXT5PIjtmT1WxZDsiy0SOz+NciD+mSBG/1S96kcIIG1UeRDCjSROv0g0K7HGnwaPd07Nik4Sx0TqBD0nB+5ab07MCzUXHTmeXaMRU/ZRoXOit9g/KdV+LLs45x8k3hUw0gnjwUVng0tnIJzv6CigM9uvfm5xgV+JSqBp7ukXDv7o/64+ugkP5igOLdAi40ubqBSvNQIzv17ruPrfxIlZCfX8j7AqmCIqrQy1mfknW0sAaGRiPnR/r3+v1UqKXhs8aj5nuG+gw== robert@rankscience.com',
  ],
}


$src= '/usr/src/rankscience'
file { [ "$src", "$src/docker", "$src/docker/rs-python"]:
  ensure => directory,
  owner  => 'ubuntu',
  group  => 'ubuntu',
  mode   => 0644,
}

vcsrepo{'/usr/src/rankscience/gh-webhook':
 provider => git,
 ensure => present,
 revision => 'master',
 source => 'https://ee3eaf0689c209db6ddda7c2036e50254012c090@github.com/rankscience/gh-webhook.git'
}

vcsrepo{'/usr/src/rankscience/limbo':
 provider => git,
 ensure => present,
 revision => 'master',
 source => 'https://ee3eaf0689c209db6ddda7c2036e50254012c090@github.com/rankscience/limbo.git'
}

vcsrepo{'/usr/src/rankscience/dynamodb-continuous-backup':
 provider => git,
 ensure => present,
 revision => 'master',
 source => 'https://ee3eaf0689c209db6ddda7c2036e50254012c090@github.com/awslabs/dynamodb-continuous-backup.git'
}



docker::image { 'rs-python':
  docker_file => '/usr/src/rankscience/docker/rs-python/Dockerfile',
  subscribe => File['/usr/src/rankscience/docker/rs-python/Dockerfile'],
}

file { '/usr/src/rankscience/docker/rs-python/Dockerfile':
  ensure => file,
  source => 'puppet:///modules/images/rs-python/Dockerfile',
}


include docker

docker::run { 'webhook':
  image           => 'rs-python',
  command         => '/bin/sh -c "python /rankscience/gh-webhook/handler.py"',
  ports           => ['8080:8080'],
  net             => 'host',
  env             => ['SLACK_TOKEN=xoxb-186940053666-tE8fzlIJLypRfeItvU8sA5dl'],
  volumes         => ['/usr/src/rankscience/:/rankscience', '/root/:/root/'],
  dns             => ['8.8.8.8', '8.8.4.4'],
  restart_service => true,
  privileged      => false,
  pull_on_start   => false,
  before_stop     => 'echo "webhook container being shut down by Puppet"',
}

docker::run { 'chatbot':
  image           => 'rs-python',
  command         => '/bin/sh -c "cd /rankscience/limbo && make run"',
  net             => 'host',
  env             => ['SLACK_TOKEN=xoxb-186940053666-tE8fzlIJLypRfeItvU8sA5dl'],
  volumes         => ['/usr/src/rankscience/:/rankscience', '/root/:/root/'],
  dns             => ['8.8.8.8', '8.8.4.4'],
  restart_service => true,
  privileged      => false,

}

}

