node default {
include sysctl
include hosts
include ::ntp

package { 'datadog-agent':
    ensure => absent,
    require => Service["datadog-agent"],
}

service { 'datadog-agent':
    ensure     => stopped,
    enable     => false,
    hasstatus  => true,
}

file { '/home/ubuntu/.ssh/authorized_keys':
    content => template('authkeys/authorized_keys.erb'),
    owner   => ubuntu,
    group   => ubuntu,
    mode    => 600,
}

accounts::user { 'max':
  comment => 'Max Countryman',
  groups  => [
    'admin',
  ],
  uid     => '1101',
  gid     => '1101',
  sshkeys => [
    'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDM6eymdHtu/F8pgAvUApl+nKKqj5ZhuEgk79yRX1MjowSwsmNeUhUZPhmZmKLrIVzi8t1ZMkOGb8lotfIi3WwqZBzOBQ/XVx+UuQ8Ivek0byB5wKgcwVtuF+knSq9mC5aQ3MVIUhVMkGe4m1uUZH6ZTDtJU1ecNcVs8/y22hQPrJzWGUNYjvplQMXHeLislufWB7TbJwSWr3p6WN1L4s2F5/YfiOBCXIvo618yn+vyIOdh2VwfvCj77jlePQo9Mykj7SHEr3fRz2dsMCLT2gREKZy/3hRYT2ybHvkTn1LZZHdyO3JFNCP4f4uFxHo3OzJa8lgAaaxt74wmZ6XRscyb maxc@me.com',
  ],
}

accounts::user { 'afsheenb':
  comment => 'Afsheen Bigdeli',
  groups  => [
    'admin',
  ],
  uid     => '1100',
  gid     => '1100',
  sshkeys => [
    'ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBKWC7wtPnfCmClFf1vZe4La1QcUwBHDt7mNv/9lCUssf0egwU4zqhB2urmSkbSoq19JbU2/q8gKOwrodSSEVBeY= afsheenb@shamshir',
  ],
}


accounts::user { 'rodaan':
  comment => 'Rodaan Peralta-Rabang',
  groups  => [
    'admin',
  ],
  uid     => '1102',
  gid     => '1102',
  sshkeys => [
    'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDAbsMlazv9ugFQ9GMVZ0eyt5bEOQE5MqEtpuGsMreXVJKoCnKkDmI5cLNSJsuppZw6YbGF2prLefslxmvDNdM4ZkqOAsU5TN4LyIuFZZwb0wNPkHbOwkZijWRez439fCu1Fg7oGOATniBNWl1Zc232Ki+K1/67rtkSZguYzW/JFxZNPc1g3xBbjhzOXuzJLaOgVEWo9LJwFdggWKtMWb3e/TDhr0De9I0wRAM18FNROZiQ2wP5fgL9S8voyV/gPoT3gNwlXAGYzcqqLe1bK5iWT5GdawfIn2uf0ErMdzxdsnI4rq5U/w1qMfhY9/dF5IOM/axkqotZhQ+p5tOKOOW/ rodaan@rankscience.com',
  ],
}

accounts::user { 'dillon':
  comment => 'Dillon Forest',
  groups  => [
    'admin',
  ],
  uid     => '1104',
  gid     => '1104',
  sshkeys => [
  'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC8eyp0CuMtsTJNXNnvF2J3hHCavtK4HsdzTzsmpCDKxTJC7m6+TuG1IXlCAimLEZk46fkyiy7vpDyBQ8et+EPZVCu8F00ywoEnSGOtjMVW3YY8bw+AZVBme5rXgqhSxSJFJhiooKe1VDIcQSIER8FxqYmtNjYFtLsVfyvAEnnDubcB35sVMMADOFaiqSwQVMiSi+VG0+OyQjWr6ZFDYEtYbUiAN7zoVRrnjy07lqJ3S6I3iDlLFxF+99hyDn/vq6TeopMgWjNi/2SS3s0oTReZg7FHCFLewUzpQflyahx7cXv0zFJKgVs+etoYcT5wOZRe0rc3+c4HxNekhJ+1ualxVoza8DtYtpV0j1hjSnQdmXbj7GQdeYs46DUfGKCFFICYYAr6RDGClSOg3idKvoAcxZ9778JxmcqsmrJ2kLbSfos+hcNdzaMeRNMzngrur6ai5e/TlQMw9ZKGI6zojAo78jgidr1zzJVVTWCd592NyUT/VoNNIC4AqnrqFdWhvG9Hm5P7X5VXpJ7OhR87z4EY9LUND5wk/sJHJBVU1Hi6lXJ5k+u99gH5ucFebUZtHoo8dx8hJ7j1Zfzc2Eh6cqgIS5EDbCPxbWAqC+S/Q+lfyNCggW7RCkYxe5bKNJ09Vq0rW7Bxz3jf09tyfMAi1nL7N48e/72ESokz1trF+hlsbw== dillon@rankscience.com',
  ],
}




include ulimit
ulimit::rule {
    'soft_file':
      ulimit_domain => '*',
      ulimit_type   => 'soft',
      ulimit_item   => 'nofile',
      ulimit_value  => '999999';
    'hard_file':
      ulimit_domain => '*',
      ulimit_type   => 'hard',
      ulimit_item   => 'nofile',
      ulimit_value  => '999999';
    'soft_file_root':
      ulimit_domain => 'root',
      ulimit_type   => 'soft',
      ulimit_item   => 'nofile',
      ulimit_value  => '999999';
    'hard_file_root':
      ulimit_domain => 'root',
      ulimit_type   => 'hard',
      ulimit_item   => 'nofile',
      ulimit_value  => '999999';
  }



awscli::profile { 'default':
  aws_access_key_id     => 'AKIAI4W5M3VHGEOQP4EQ',
  aws_secret_access_key => '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'
}

package { 'git':   ensure => 'installed' }
package { 'htop':   ensure => 'installed' }
package { 's3cmd':   ensure => 'installed' }
package { 'make':   ensure => 'installed' }
package { 'build-essential':   ensure => 'installed' }

include sudo
include sudo::configs


sudo::conf { 'admin':
  priority => 10,
  content  => "%admin ALL=(ALL) NOPASSWD: ALL",
}

}
