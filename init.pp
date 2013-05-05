package { "build-essential":
    ensure => installed,
}

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

# host {'www':
#     ip => '127.0.0.1',
# }

package {"python-pip":
    ensure => installed,
    require => Exec['update-packages'],
}

package {'puppet':
    ensure => installed,
}

exec {"inst_virtualenv":
    command => 'pip install virtualenv',
    require => Package['python-pip'],
    path => "/usr/bin",
}

exec {"fix_permissions_python":
    command => "chmod -R a+r /usr/local/lib/",
    require => Exec['inst_virtualenv'],
    path => "/bin",
}

exec {'create_www_virtualenv':
    command => "virtualenv /home/vagrant/www",
    user => vagrant,
    group => vagrant,
    path => '/usr/local/bin',
    creates => '/home/vagrant/www',
    require => [Exec['update-packages'], Exec['inst_virtualenv']],
}

package {"git":
    ensure => installed,
    require => Package['python-dev']
}

package {"libevent-dev":
    ensure => installed,
    require => Package['python-dev'],
}

package {'python-dev':
    ensure => installed,
}

package {"postgresql":
    ensure => installed,
    require => Package['postgresql-server-dev-all']
}

package {'postgresql-server-dev-all':
    ensure => installed,
}

exec{"install_requirements":
    command => "/home/vagrant/www/bin/pip install -r /vagrant/requirements.txt",
    user => vagrant,
    group => vagrant,
    require => [Exec["create_www_virtualenv"], Package["git"], Package['postgresql']],
}

package{'supervisor':
    ensure => installed,
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

service {'postgresql':
    ensure => running,
    require => File['/etc/postgresql/9.1/main/pg_hba.conf'],
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

service {'supervisor':
    ensure => running,
    require => File['/etc/supervisor/conf.d/www.conf'],
}

exec{'create-database':
    command => 'psql -U postgres -l | grep www || bash /vagrant/mhbp_reset_local_db.bash',
    path => '/usr/bin:/bin',
    require => [Service['postgresql'], Exec['install_requirements']],
}


exec {"run_www":
    command => "/usr/bin/supervisorctl update ; /usr/bin/supervisorctl start www",
    require => [Service['postgresql'], File['/etc/supervisor/conf.d/www.conf'], File['/vagrant/vagrant_runlocal.bash'], Exec['install_requirements']],
}

