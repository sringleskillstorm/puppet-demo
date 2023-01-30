node default { 
    include apache
  
    file { 'indexPage':
               path => '/var/www/html/index.html',
               ensure => 'file',
               source => 'https://raw.githubusercontent.com/sringleskillstorm/puppet-demo/main/websitev1.html',
          }
  }
