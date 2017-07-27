

# set global path variable for project
# http://www.puppetcookbook.com/posts/set-global-exec-path.html
include 'docker'
include 'ruby'

Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/", "/usr/local/bin", "/usr/local/sbin" ] }

class { 'epel::install': }
class { 'git::install': }

class {'docker::compose':
  ensure => present,
}

package{'ruby-devel':
    ensure => present,
}

::bundler::install { '/var/app/mde_bench':
  user       => 'root',
  group      => 'root',
  deployment => false
}