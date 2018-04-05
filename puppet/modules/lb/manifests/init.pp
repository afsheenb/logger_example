class lb {

package { 'nginx':   ensure => 'installed' }

    file { "/etc/nginx/sites-available/lb":
        owner => root,
        group => root,
        mode => 644,
        content => template("lb/lb.conf.erb"),
    }
    
}
