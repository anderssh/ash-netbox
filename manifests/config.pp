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
  String $secret_key,
) {

  $software_directory = "${install_root}/netbox"
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
      'secret_key'            => $secret_key,
    }),
    owner   => $user,
    group   => $group,
    mode    => '0644',
  }
}
