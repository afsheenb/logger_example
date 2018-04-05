node /^ebdeploy-*/ inherits default {

$src= '/usr/src/rankscience'
file { [ "$src", "$src/docker", "$src/docker/copernicus", "$src/docker/cassini", "$src/docker/rs-python"]:
  ensure => directory,
  owner  => 'ubuntu',
  group  => 'ubuntu',
  mode   => 0644,
}

vcsrepo{'/usr/src/rankscience/copernicus-dev':
  provider => git,
  ensure => present,
  revision => 'production',
  source => 'https://ee3eaf0689c209db6ddda7c2036e50254012c090@github.com/rankscience/copernicus.git'
}

vcsrepo{'/usr/src/rankscience/copernicus-staging':
  provider => git,
  ensure => present,
  revision => 'staging',
  source => 'https://ee3eaf0689c209db6ddda7c2036e50254012c090@github.com/rankscience/copernicus.git'
}

vcsrepo{'/usr/src/rankscience/cassini-production':
  provider => git,
  ensure => present,
  revision => 'production',
  source => 'https://ee3eaf0689c209db6ddda7c2036e50254012c090@github.com/rankscience/cassini.git'
}

vcsrepo{'/usr/src/rankscience/cassini-staging':
  provider => git,
  ensure => present,
  revision => 'staging',
  source => 'https://ee3eaf0689c209db6ddda7c2036e50254012c090@github.com/rankscience/cassini.git'
}

vcsrepo{'/usr/src/rankscience/gh-webhook':
  provider => git,
  ensure => present,
  revision => 'master',
  source => 'https://ee3eaf0689c209db6ddda7c2036e50254012c090@github.com/rankscience/gh-webhook.git'
}

docker::image { 'rs-python':
  docker_file => '/usr/src/rankscience/docker/rs-python/Dockerfile',
  subscribe => File['/usr/src/rankscience/docker/rs-python/Dockerfile'],
}

file { '/usr/src/rankscience/docker/rs-python/Dockerfile':
  ensure => file,
  source => 'puppet:///modules/images/rs-python/Dockerfile',
}


accounts::user { 'evan':
  comment => 'Evan Hsia',
  groups  => [
    'admin',
  ],
  uid     => '1110',
  gid     => '1110',
  sshkeys => ['ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCicSu8a24HeabNcX8BF2+zneQwGGR9nEgt3gI6oAhn04N+EsMRsIZedqUGVKsvgAmAkasVX1Np478jokP8fYuyiGPqqBwJ0+quIdZpx/kfNSXatauHJw9/T+Ajju0noenpJhAdacQcbgGLDuWomMFs9Y80pZ2E9vutRGfjUdnB/r+WGOELGr3zv3GAT+VTdjUtXBSMjMAmCDDTTpLj7XRsu4kEgTG3QJvGA0P77EX73fQc7LTX4r8efo1CDRWUeO33xG3/iYd+c1Saz/ZT+UtBPsnUF8JYQ+rYuStYjwxa2NwaY9NtoDbqOGi21h07fPcPD2XGGVHpLWfGOSM/Ie0f evan',
  ],
}

include docker

docker::run { 'eb_webhook':
  image           => 'rs-python',
  command         => '/bin/sh -c "apt-get -y remove python-pip; easy_install pip; pip install awsebcli; pip install gitpython; python /rankscience/gh-webhook/copernicus_handler.py"',
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

}
