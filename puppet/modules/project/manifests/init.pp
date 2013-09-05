class project 
{
  package { "git-core":
    ensure => present,
  }

  # remove this when ubuntu bundles git version 1.8+
  #
  # need to update git to the latest, default one is version 1.7.10,
  # new version is 1.8+ and it fixes a bug where git submodules use
  # absolute urls instead of relative which causes conflicts with
  # sourcetree since sourcetree can't find the submodule directory
  # due to the path missing since the file locations are synced.
  # 
  # sudo apt-get install python-software-properties
  # sudo add-apt-repository ppa:git-core/ppa
  # sudo apt-get update
  # sudo apt-get install git

  package { "python-software-properties":
    ensure  => installed,
    require => Exec["apt-get update"],
  }

  exec { "git-core ppa":
    command => "add-apt-repository --yes ppa:git-core/ppa && apt-get update",
    creates => "/etc/apt/sources.list.d/git-core-ppa-precise.list",
    before  => Package["git-core"],
    require => Package["python-software-properties"],
  }

  package { "git":
    ensure  => latest,
    require => Exec["git-core ppa"],
  }

  # end bundle fix

  # clean folder only if it is empty
  exec { "clean folder":
    command => "/bin/rm -rf ${params::wwwroot}",
    onlyif  => "test ! -f ${params::wwwroot}/index.php",
  }

  exec { "verify directory":
    command => "/bin/mkdir -p ${params::wwwroot}",
    onlyif  => "test ! -d ${params::wwwroot}",
    require => Exec["clean folder"]
  }

  # Download and extract
  package { "unzip":
    ensure => present,
  }

  exec { "download installer":
    command => "/usr/bin/wget ${params::app_installer}",
    cwd     => "${params::wwwroot}",
    creates => "${params::wwwroot}/${params::app_installer}",
    onlyif  => "test ! -f ${params::wwwroot}/index.php",
    require => Exec["verify directory"],
    timeout => 0,
  }
  -> exec { "extract installer":
    command => "/usr/bin/unzip lemonstand_installer.zip",
    cwd     => "${params::wwwroot}",
    creates => "${params::wwwroot}/index.php",
    onlyif  => "test ! -f ${params::wwwroot}/index.php",
    require => [
      Exec["download installer"],
      Package["unzip"],
    ],
    timeout => 0,
  }
  -> exec { "remove installer":
    command => "/bin/rm lemonstand_installer.zip",
    cwd     => "${params::wwwroot}",
    onlyif  => "test -f ${params::wwwroot}/lemonstand_installer.zip",
    require => Exec["extract installer"],
  }

  $holder = $params::license_holder
  $serial = $params::license_serial
  $dbhost = "localhost"
  $dbname = $params::mysql_database
  $dbuser = $params::mysql_user
  $dbpass = $params::mysql_password
  $backend = $params::backend_url
  $config = $params::config_url
  $firstname = $params::user_firstname
  $lastname = $params::user_lastname
  $email = $params::user_email
  $username = $params::user_username
  $password = $params::user_password
  $defaulttheme = $params::use_default_theme
  $defaulttwig = $params::use_default_theme_twig
  $demodata = $params::use_demo_data
  $encrypt = $params::encypt_key

  file { "custom install script":
    path    => "${params::wwwroot}/custominstall.php",
    ensure  => present,
    owner   => vagrant, 
    group   => vagrant,
    content => template('project/custominstall.php.erb'),
    require => Exec["extract installer"],
  }

  exec { "run custom install":
    command => "/usr/bin/php custominstall.php",
    cwd     => "${params::wwwroot}",
    onlyif  => [
      "test -f ${params::wwwroot}/custominstall.php",
      "test ! -f ${params::wwwroot}/index.php",
    ],
    require => [
      Exec["extract installer"],
      File["custom install script"],
    ],
    timeout => 0,
  }

  exec { "remove custom install":
    command => "/bin/rm custominstall.php",
    cwd     => "${params::wwwroot}",
    onlyif  => "test -f ${params::wwwroot}/custominstall.php",
    require => [
      Exec["extract installer"],
      File["custom install script"],
    ],
  }

  # seed the database
  exec { "load db":
    command => "/usr/bin/mysql -u${params::mysql_user} -p${params::mysql_password} ${params::mysql_database} < /srv/config/db.sql",
    onlyif  => "test -f /srv/config/db.sql",
    # unless  => "/usr/bin/mysql -uroot -p${params::mysql_password} \"use database\"",
    require => Service["mysql"],
  }

  # copy config.dat if present
  exec { "copy config dat":
    command => "/bin/cp /srv/config/config.dat /srv/www/config/config.dat",
    onlyif  => "test ! -f /srv/www/config/config.dat",
    require => [
      Exec["extract installer"],
      Exec["run custom install"],
    ],
  }

  # copy config.php if present
  exec { "copy config":
    command => "/bin/cp /srv/config/config.php /srv/www/config/config.php",
    onlyif  => "test ! -f /srv/www/config/config.php",
    require => [
      Exec["extract installer"],
      Exec["run custom install"],
    ],
  }

  # take a DB backup after installation if no seed file exists
  exec { "database create":
    command => "/usr/bin/mysqldump -u${params::mysql_user} -p${params::mysql_password} ${params::mysql_database} > /srv/config/db.sql",
    onlyif  => "test ! -f /srv/config/db.sql",
    require => Exec["run custom install"],
    timeout => 0,
  }
}