class pm2 {
    file { "/usr/src/rankscience/pm2":
        owner => root,
        group => root,
        mode => 644,
        ensure => directory,
    }
    file { "/usr/src/rankscience/pm2/galileo-dev.config.js":
        owner => root,
        group => root,
        mode => 644,
        content => template("pm2/galileo.dev.pm2.rb"),
    }
    file { "/usr/src/rankscience/pm2/prism-dev.config.js":
        owner => root,
        group => root,
        mode => 644,
        content => template("pm2/prism.dev.pm2.rb"),
    }
    file { "/usr/src/rankscience/pm2/galileo-stage.config.js":
        owner => root,
        group => root,
        mode => 644,
        content => template("pm2/galileo.stage.pm2.rb"),
    }
    file { "/usr/src/rankscience/pm2/prism-stage.config.js":
        owner => root,
        group => root,
        mode => 644,
        content => template("pm2/prism.stage.pm2.rb"),
    }
    file { "/usr/src/rankscience/pm2/prism-prod.config.js":
        owner => root,
        group => root,
        mode => 644,
        content => template("pm2/prism.prod.pm2.rb"),
    }
    file { "/usr/src/rankscience/pm2/galileo-prod.config.js":
        owner => root,
        group => root,
        mode => 644,
        content => template("pm2/galileo.prod.pm2.rb"),
    }
    file { "/usr/src/rankscience/pm2/deploy.sh":
        owner => root,
        group => root,
        mode => 775,
        content => template("pm2/deploy.rb"),
    }
    
    file { "/usr/src/rankscience/pm2/deploy-stage.sh":
        owner => root,
        group => root,
        mode => 775,
        content => template("pm2/deploy-stage.rb"),
    }
    file { "/usr/src/rankscience/pm2/deploy-lens-stage.sh":
        owner => root,
        group => root,
        mode => 775,
        content => template("pm2/deploy-lens-stage.rb"),
    }
    file { "/usr/src/rankscience/pm2/deploy-lens-prod.sh":
        owner => root,
        group => root,
        mode => 775,
        content => template("pm2/deploy-lens-prod.rb"),
    }
    
    file { "/usr/src/rankscience/pm2/deploy-galileo-stage.sh":
        owner => root,
        group => root,
        mode => 775,
        content => template("pm2/deploy-galileo-stage.rb"),
    }

    file { "/usr/src/rankscience/pm2/deploy-galileo-prod.sh":
        owner => root,
        group => root,
        mode => 775,
        content => template("pm2/deploy-galileo-prod.rb"),
    }

}
