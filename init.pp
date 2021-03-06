
node default {

  # declare stage orders
  stage { 'A' : before  => Stage['B'] }
  stage { 'B' : require => Stage['A'] }
  stage { 'C' : require => Stage['B'] }
  stage { 'D' : require => Stage['C'] }


  # set class stages
  class {
    'init'   : stage => A;
    'first'  : stage => B;
    'middle' : stage => C;
    'last'   : stage => D;
  }

}

class init {

    exec { "update-package-list":
        command => "apt-get update",
        require => File['/etc/apt/sources.list'],
        path => "/usr/bin",
    }

    exec { "update-packages":
        command => 'DEBIAN_FRONTEND=noninteractive apt-get -y dist-upgrade',
        require => Exec["update-package-list"],
        path => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
        provider => shell,
        logoutput => "on_failure",
        user => root,
        group => root,
        timeout => 900,
    }

    package {'memcached':
        ensure => installed,
        require => Exec['update-package-list'],
    }

    package {'libmemcached-dev':
        ensure => installed,
        require => Exec['update-package-list'],
    }

    exec {'install_postgres_apt_key':
        command => 'wget --quiet -O - http://apt.postgresql.org/pub/repos/apt/ACCC4CF8.asc | sudo apt-key add -',
        path => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
        provider => shell,
        logoutput => "on_failure",
        user => root,
        group => root,
        timeout => 900,
    }

    file{'/etc/apt/sources.list':
        source => '/vagrant/devserver/sources.list',
        owner => root,
        group => root,
        mode => 0644,
        backup => false,
        require => Exec['install_postgres_apt_key'],
    }

}

class first {

    package { "build-essential":
        ensure => installed,
    }

    package {"curl":
        ensure => installed,
    }

    package {"emacs23-nox":
        ensure => installed,
    }

    package {"python-pip":
        ensure => installed,
    }

    package {"git":
        ensure => installed,
    }

    package {"puppet":
        ensure => installed,
    }

    package {"libevent-dev":
        ensure => installed,
    }

    package {'python-dev':
        ensure => installed,
    }

    package {"postgresql-9.2":
        ensure => installed,
    }

    package {'postgresql-client-9.2':
        ensure => installed,
    }

    package {'postgresql-server-dev-9.2':
        ensure => installed,
    }

    package{'supervisor':
        ensure => installed,
    }

    exec{"/usr/bin/wget -qO- https://toolbelt.heroku.com/install-ubuntu.sh | /bin/sh":
    }
}


class middle {

    exec { 'utf8 postgres':
        command => 'pg_dropcluster --stop 9.2 main ; pg_createcluster --start --locale en_US.UTF-8 9.2 main',
        unless  => 'sudo -u postgres psql -t -c "\l" | grep template1 | grep -q UTF',
        path    => ['/bin', '/sbin', '/usr/bin', '/usr/sbin'],
    }


    service {'postgresql':
        ensure => running,
    }

    service {'supervisor':
        ensure => running,
    }

    exec {"inst_virtualenv":
        command => 'pip install virtualenv',
        path => "/usr/bin",
    }

    file {'/etc/postgresql/9.2/main/pg_hba.conf':
        source => '/vagrant/devserver/pg_hba.conf',
        owner => postgres,
        group => postgres,
        mode => 0640,
        backup => false,
        notify => Service['postgresql'],
        require => Exec['utf8 postgres'],
    }

    file {'/etc/supervisor/conf.d/www.conf':
        source => '/vagrant/devserver/supervisor-runlocal',
        backup => false,
        owner => root,
        group => root,
        mode => 0755,
        notify => Service['supervisor'],
    }

    file {'/vagrant/devserver/runlocal.bash':
        mode => 0755,
        backup => false,
    }
}



class last {

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
        timeout => 900,
    }

    exec{'reset-database':
        command => 'bash /vagrant/devserver/resetdb_local.bash',
        path => '/usr/bin:/bin',
        require => Exec['install_requirements'],
    }

    exec {"run_www":
        command => "/usr/bin/supervisorctl update ; /usr/bin/supervisorctl start www",
        require => Exec['reset-database'],
    }
}


