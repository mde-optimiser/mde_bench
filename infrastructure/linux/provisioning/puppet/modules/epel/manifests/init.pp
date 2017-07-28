class epel::install {
  package {
    ['epel-release']: 
    ensure => installed,
  }
}
