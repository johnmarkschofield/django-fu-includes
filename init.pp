stage { 'init':
    before => Stage['first']
}

stage { 'first':
    before => Stage['middle'],
}

stage {'middle':
    after => Stage['first'],
    before => Stage['last'],
}

stage {'last':
    after => Stage['middle']
}



class {'init':
    stage => init,

    exec { "update-package-list":
        command => "apt-get update",
        path => "/usr/bin",
    }

    exec { "update-packages":
        command => 'DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" dist-upgrade',
        require => Exec["update-package-list"],
        path => "/usr/bin",
        provider => shell,
        logoutput => "on_failure",
    }

}


class {'first':
    stage => first,

    package { "build-essential":
        ensure => installed,
    }

    package {"python-pip":
        ensure => installed,
    }

    package {'puppet':
        ensure => installed,
    }

    package {"git":
        ensure => installed,
    }

    package {"libevent-dev":
        ensure => installed,
    }

    package {'python-dev':
        ensure => installed,
    }

    package {"postgresql":
        ensure => installed,
    }

    package {'postgresql-server-dev-all':
        ensure => installed,
    }

    package{'supervisor':
        ensure => installed,
    }

    service {'postgresql':
        ensure => running,
    }

    service {'supervisor':
        ensure => running,
        require => File['/etc/supervisor/conf.d/www.conf'],
    }
}


class {'middle':
    stage => middle,

    exec {"inst_virtualenv":
        command => 'pip install virtualenv',
        path => "/usr/bin",
    }

    file {'/etc/postgresql/9.1/main/pg_hba.conf':
        source => '/vagrant/devserver/pg_hba.conf',
        owner => postgres,
        group => postgres,
        mode => 0640,
        backup => false,
        notify => Service['postgresql'],
        require => Package['postgresql'],
    }

    file {'/etc/supervisor/conf.d/www.conf':
        source => '/vagrant/devserver/supervisor-runlocal',
        backup => false,
        owner => root,
        group => root,
        mode => 0755,
        require => Package['supervisor'],
        notify => Service['supervisor'],
    }

    file {'/vagrant/vagrant_runlocal.bash':
        mode => 0755,
        backup => false,
    }

}



class {'last':

    exec {"fix_permissions_python":
        command => "chmod -R a+r /usr/local/lib/",
        path => "/bin",
    }

    exec {'create_www_virtualenv':
        command => "virtualenv /home/vagrant/www",
        user => vagrant,
        group => vagrant,
        path => '/usr/local/bin',
        creates => '/home/vagrant/www',
        require => Exec['fix_permissions_python'],
    }

    exec{"install_requirements":
        command => "/home/vagrant/www/bin/pip install -r /vagrant/requirements.txt",
        user => vagrant,
        group => vagrant,
        require => Exec["create_www_virtualenv"],
    }

    exec{'create-database':
        command => 'psql -U postgres -l | grep www || bash /vagrant/mhbp_reset_local_db.bash',
        path => '/usr/bin:/bin',
        require => Exec['install_requirements'],
    }

    exec {"run_www":
        command => "/usr/bin/supervisorctl update ; /usr/bin/supervisorctl start www",
        require => Exec['create-database'],
    }
}









