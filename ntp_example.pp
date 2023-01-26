node default { 
  class { 'ntp':
        servers => ['nist-time-server.eoni.com','nist1-lv.ustiming.org','ntp-nist.ldsbc.edu']
  }

  class {'apache2': }

  file { 'webbpage':
             path => '/var/www/html/index.html',
             ensure => 'file',
             source => 'https://github.com/sringleskillstorm/puppet-demo/blob/b25b16165c294ca6a2d8c727667f25be5f310ec7/ntp_example.pp',
        }
}
