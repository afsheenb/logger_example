class sysctl {
    file { "/etc/sysctl.conf":
        owner => root,
        group => root,
        mode => 644,
        content => template("sysctl/sysctl.erb"),
    }
}
