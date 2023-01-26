node default { 
  class { 'ntp':
        servers => ['nist-time-server.eoni.com','nist1-lv.ustiming.org','ntp-nist.ldsbc.edu']
  }

  class {'apache2': }

  file { 'webbpage':
             path => '/var/www/html/index.html',
             ensure => 'file',
             source => 'puppet://index.html',
        }
}
