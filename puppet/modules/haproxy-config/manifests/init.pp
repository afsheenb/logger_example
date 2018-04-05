class haproxy-config {
    file { "/usr/src/rankscience/haproxy-prod-config":
        owner => root,
        group => root,
        mode => 644,
        ensure => directory,
    }
    file { "/usr/src/rankscience/haproxy-prod-config/haproxy.conf":
        owner => root,
        group => root,
        mode => 644,
        content => template("haproxy-config/haproxy.conf.rb"),
    }
    
    file { "/usr/src/rankscience/haproxy-prod-config/haproxy-test.conf":
        owner => root,
        group => root,
        mode => 644,
        content => template("haproxy-config/haproxy.test.conf.rb"),
    }
}
