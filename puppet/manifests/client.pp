node /^pb-client-*/ inherits default {


$src= '/usr/src/ozone'
file { [ "$src", "$src/docker", "$src/docker/npm"]:
  ensure => directory,
  owner  => 'ubuntu',
  group  => 'ubuntu',
  mode   => 0644,
}


vcsrepo{'/usr/src/ozone/Prebid.js':
 provider => git,
 ensure => present,
 revision => 'master',
 source => 'https://github.com/prebid/Prebid.js.git'
}

vcsrepo{'/usr/src/ozone/static':
 provider => git,
 ensure => present,
 revision => 'master',
 source => 'https://e58149d161fce7bf01ef73f4002cb4e03261ee28@github.com/ozone-project/static.git'
}

vcsrepo{'/usr/src/ozone/phantomas':
 provider => git,
 ensure => present,
 revision => 'master',
 source => 'https://github.com/macbre/phantomas.git'
}

include docker

file { '/usr/src/ozone/docker/npm/Dockerfile':
  ensure => file,
  source => 'puppet:///modules/images/npm/Dockerfile',
}

docker::image { 'npm':
  docker_file => '/usr/src/ozone/docker/npm/Dockerfile',
  subscribe => File['/usr/src/ozone/docker/npm/Dockerfile'],
}


}
