class s3cfg {
    file { "/home/ubuntu/.s3cfg":
        owner => ubuntu,
        group => ubuntu,
        mode => 644,
        content => template("s3cfg/s3cfg.rb"),
    }
}
