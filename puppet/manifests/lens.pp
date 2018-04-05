node /^lens-*/ inherits default {

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
 source => 'https://ee3eaf0689c209db6ddda7c2036e50254012c090@github.com/rankscience/haproxy-confd.git'
}

vcsrepo{'/usr/src/rankscience/telescope':
 provider => git,
 ensure => present,
 revision => 'master',
 source => 'https://ee3eaf0689c209db6ddda7c2036e50254012c090@github.com/rankscience/telescope.git'
}

vcsrepo{'/usr/src/rankscience/paraphrase':
 provider => git,
 ensure => present,
 revision => 'master',
 source => 'https://ee3eaf0689c209db6ddda7c2036e50254012c090@github.com/rankscience/paraphrase.git'
}

vcsrepo{'/usr/src/rankscience/lens-stage':
 provider => git,
 ensure => present,
 revision => 'staging',
 source => 'https://ee3eaf0689c209db6ddda7c2036e50254012c090@github.com/rankscience/lens.git'
}

vcsrepo{'/usr/src/rankscience/lens-prod':
 provider => git,
 ensure => present,
 revision => 'production',
 source => 'https://ee3eaf0689c209db6ddda7c2036e50254012c090@github.com/rankscience/lens.git'
}

vcsrepo{'/usr/src/rankscience/galileo-stage':
 provider => git,
 ensure => present,
 revision => 'staging',
 source => 'https://ee3eaf0689c209db6ddda7c2036e50254012c090@github.com/rankscience/galileo.git'
}

vcsrepo{'/usr/src/rankscience/galileo-prod':
 provider => git,
 ensure => present,
 revision => 'production',
 source => 'https://ee3eaf0689c209db6ddda7c2036e50254012c090@github.com/rankscience/galileo.git'
}

vcsrepo{'/usr/src/rankscience/transforms':
 provider => git,
 ensure => present,
 revision => 'master',
 source => 'https://ee3eaf0689c209db6ddda7c2036e50254012c090@github.com/rankscience/transforms.git'
}

vcsrepo{'/usr/src/rankscience/aleph':
 provider => git,
 ensure => present,
 revision => 'master',
 source => 'https://ee3eaf0689c209db6ddda7c2036e50254012c090@github.com/rankscience/aleph.git'
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

docker::image { 'lens':
  docker_file => '/usr/src/rankscience/docker/lens/Dockerfile',
  subscribe => File['/usr/src/rankscience/docker/lens/Dockerfile'],
}

file { '/usr/src/rankscience/docker/lens/Dockerfile':
  ensure => file,
  source => 'puppet:///modules/images/lens/Dockerfile',
}


docker::run { 'lens-stage':
  image           => 'lens',
  command         => '/bin/sh -c "cd /rankscience/paraphrase; git pull; lein install; echo \'installed paraphrase!\'; cd /rankscience/aleph; git pull; lein install; echo \'installed aleph, time to start the deploy script!\'; cd /rankscience/pm2; ./deploy-lens-stage.sh"',
  ports           => ['8091:5050'],
  net             => 'host',
  volumes         => ['/usr/src/rankscience/:/rankscience'],
  env             => ['LENS_PORT=8091','LENS_GALILEO_PORT=8092','TELENV=lens-stage','AWS_ACCESS_KEY_ID=AKIAI4QT5AGCNZAEZ7WQ','AWS_SECRET_ACCESS_KEY=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', 'GALILEO_TRANSFORMS_PATH=/rankscience/transforms', 'GIT_COMMITTER_NAME=MrMeeseeks', 'GIT_COMMITTER_EMAIL=nobody@rankscience.com', 'LENS_SENTRY_DSN=https://3e7cccb43d6e427ea38395e28dfe9549:2815a696ab0d4bb487a1eba73fd69d87@sentry.io/169361','SENTRY_DSN=https://3e7cccb43d6e427ea38395e28dfe9549:2815a696ab0d4bb487a1eba73fd69d87@sentry.io/169361', 'DEPLOY_NOP=1', 'LENS_HOST_INTERVAL=72000'],
  dns             => ['8.8.8.8', '8.8.4.4'],
  restart_service => true,
  privileged      => false,
  pull_on_start   => false,
  before_stop     => 'echo "lens-dev container being shut down by Puppet"',
  extra_parameters => [ '--log-opt max-size=500m' ],
}

docker::run { 'galileo-stage':
  image           => 'telescope',
  command         => '/bin/sh -c "cd /rankscience/galileo-stage; yarn install; yarn build; /rankscience/pm2/deploy-galileo-stage.sh"',
  ports           => ['8092:6060'],
  net             => 'host',
  volumes         => ['/usr/src/rankscience/:/rankscience'],
  env             => ['GALILEO_PORT=8092','TELENV=galileo-stage','AWS_ACCESS_KEY_ID=AKIAI4W5M3VHGEOQP4EQ', 'AWS_SECRET_ACCESS_KEY=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', 'GALILEO_TRANSFORMS_PATH=../transforms','DEPLOY_NOOP=1'],
  dns             => ['8.8.8.8', '8.8.4.4'],
  restart_service => true,
  privileged      => false,
  pull_on_start   => false,
  before_stop     => 'echo "galileo-stage container being shut down by Puppet"',
}

docker::run { 'lens-prod':
  image           => 'lens',
  command         => '/bin/sh -c "cd /rankscience/paraphrase; git pull; lein install; echo \'installed paraphrase!\'; cd /rankscience/aleph; git pull; lein install; echo \'installed aleph, time to start the deploy script!\'; cd /rankscience/pm2; ./deploy-lens-prod.sh"',
  ports           => ['8001:5050'],
  net             => 'host',
  volumes         => ['/usr/src/rankscience/:/rankscience'],
  env             => ['LENS_PORT=8001','TELENV=lens-prod','LENS_GALILEO_PORT=8002','AWS_ACCESS_KEY_ID=AKIAI4QT5AGCNZAEZ7WQ', 'AWS_SECRET_ACCESS_KEY=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', 'GALILEO_TRANSFORMS_PATH=/rankscience/transforms', 'GIT_COMMITTER_NAME=MrMeeseeks', 'GIT_COMMITTER_EMAIL=nobody@rankscience.com', 'LENS_SENTRY_DSN=https://3e7cccb43d6e427ea38395e28dfe9549:2815a696ab0d4bb487a1eba73fd69d87@sentry.io/169361','SENTRY_DSN=https://3e7cccb43d6e427ea38395e28dfe9549:2815a696ab0d4bb487a1eba73fd69d87@sentry.io/169361','DEPLOY_NOOP=0'],
  dns             => ['8.8.8.8', '8.8.4.4'],
  restart_service => true,
  privileged      => false,
  pull_on_start   => false,
  extra_parameters => [ '--log-opt max-size=500m' ],
  before_stop     => 'echo "lens-prod container being shut down by Puppet"',
}

docker::run { 'galileo-prod':
  image           => 'telescope',
  command         => '/bin/sh -c "cd /rankscience/galileo-prod; yarn install; yarn build; /rankscience/pm2/deploy-galileo-prod.sh"',
  ports           => ['8002:6060'],
  net             => 'host',
  volumes         => ['/usr/src/rankscience/:/rankscience'],
  env             => ['GALILEO_PORT=8002','TELENV=galileo-prod','AWS_ACCESS_KEY_ID=AKIAI4W5M3VHGEOQP4EQ', 'AWS_SECRET_ACCESS_KEY=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', 'GALILEO_TRANSFORMS_PATH=../transforms', 'DEPLOY_NOOP=0'],
  dns             => ['8.8.8.8', '8.8.4.4'],
  restart_service => true,
  privileged      => false,
  pull_on_start   => false,
  before_stop     => 'echo "galileo-prod container being shut down by Puppet"',
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
}

docker::run { 'haproxy-confd':
  image           => 'haproxy-confd',
  volumes         => ['/usr/src/rankscience/:/rankscience'],
  command         => '/bin/bash -c "ln -s /rankscience/haproxy-confd/confd /etc/confd; sleep 20; confd --node http://172.17.0.1:4001"',
  ports           => ['80:80','8080:8008'],
  net             => 'host',
  dns             => ['8.8.8.8', '8.8.4.4'],
  restart_service => true,
  privileged      => false,
  pull_on_start   => false,
  before_stop     => 'echo "haproxy container being shut down by Puppet"',
}

docker::run { 'etcd':
  image           => 'quay.io/coreos/etcd:v2.3.0-alpha.1',
  command         => '-name etcd0 --listen-client-urls http://172.17.0.1:2379,http://172.17.0.1:4001 --advertise-client-urls http://172.17.0.1:2379,http://172.17.0.1:4001',
  volumes         => ['/usr/src/rankscience/:/rankscience'],
  ports           => ['4001:4001','2379:2379', '7001:7001'],
  net             => 'host',
  dns             => ['8.8.8.8', '8.8.4.4'],
  restart_service => true,
  privileged      => false,
  pull_on_start   => false,
  before_stop     => 'echo "etcd container being shut down by Puppet"',
}


}
