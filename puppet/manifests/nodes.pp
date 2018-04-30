node default {
include hosts
include ntp

file { '/home/ubuntu/.ssh/authorized_keys':
    content => template('authkeys/authorized_keys.erb'),
    owner   => ubuntu,
    group   => ubuntu,
    mode    => 600,
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


package { 'git':   ensure => 'installed' }
package { 'htop':   ensure => 'installed' }
package { 's3cmd':   ensure => 'installed' }

include sudo
include sudo::configs

sudo::conf { 'admin':
  priority => 10,
  content  => "%admin ALL=(ALL) NOPASSWD: ALL",
}

}

