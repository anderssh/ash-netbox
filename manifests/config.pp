# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include netbox::config
class netbox::config (
  String $user,
  String $group,
  Stdlib::Absolutepath $install_root,
  Array[Stdlib::Host] $allowed_hosts,
  String $database_name,
  String $database_user,
  String $database_password,
  Stdlib::Host $database_host,
  Integer $database_port,
  Integer $database_conn_max_age,
  Hash $redis_options,
  Hash $email_options,
  String $secret_key,
  String $banner_top,
  String $banner_bottom,
  String $banner_login,
  String $base_path,
  String $superuser_username,
  String $superuser_email,
) {
  $should_create_superuser = false;
  $software_directory = "${install_root}/netbox"
  $venv_dir = "${software_directory}/venv"

  $config_file = "${software_directory}/netbox/netbox/configuration.py"

  file { $config_file:
    content => epp('netbox/configuration.py.epp', {
      'allowed_hosts'         => $allowed_hosts,
      'database_name'         => $database_name,
      'database_user'         => $database_user,
      'database_password'     => $database_password,
      'database_host'         => $database_host,
      'database_port'         => $database_port,
      'database_conn_max_age' => $database_conn_max_age,
      'redis_options'         => $redis_options,
      'email_options'         => $email_options,
      'secret_key'            => $secret_key,
      'banner_top'            => $banner_top,
      'banner_bottom'         => $banner_bottom,
      'banner_login'          => $banner_login,
      'base_path'             => $base_path,
    }),
    owner   => $user,
    group   => $group,
    mode    => '0644',
  }

  Exec {
    cwd         => $software_directory,
    path        => [ "${venv_dir}/bin", '/usr/bin', '/usr/sbin' ],
    environment => ["VIRTUAL_ENV=${venv_dir}"],
    provider    => shell,
    user        => $user,
  }

  exec { 'database migration':
    onlyif  => "${venv_dir}/bin/python3 netbox/manage.py showmigrations | grep '\[ \]'",
    command => "${venv_dir}/bin/python3 netbox/manage.py migrate --no-input",
    require => File[$config_file];
  }
  ~> exec { 'create superuser':
    onlyif  => $should_create_superuser,
    command => "${venv_dir}/bin/python3 netbox/manage.py createsuperuser --username ${superuser_username} --email ${superuser_email} --no-input",
  }
  exec { 'collect static files':
    command     => "${venv_dir}/bin/python3 netbox/manage.py collectstatic --no-input",
    subscribe   => File[$config_file],
    refreshonly => true,
  }
}
