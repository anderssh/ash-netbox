# @summary Manage Netbox
#
# Install, configure and run Netbox
#
# @param version
#   The version of Netbox. This must match the version in the
#   tarball. This is used for managing files, directories and paths in
#   the service.
#
# @param user
#   The user owning the Netbox installation files, and running the
#   service.
#
# @param group
#   The group owning the Netbox installation files, and running the
#   service.
#
# @param download_url
#   Where to download the binary installation tarball from.
#
# @param download_checksum
#   The expected checksum of the downloaded tarball. This is used for
#   verifying the integrity of the downloaded tarball.
#
# @param download_checksum_type
#   The checksum type of the downloaded tarball. This is used for
#   verifying the integrity of the downloaded tarball.
#
# @param download_tmp_dir
#   Temporary directory for downloading the tarball.
#
# @param install_root
#   The root directory of the netbox installation.
#
# @param var_directory
#   The root of the writable paths used by netbox. netbox will create
#   directories beneath this path.  This will implicitly add netbox
#   properties for working directories and repositories.
#
#
# @param handle_database [Boolean]
#   Should the PostgreSQL database be handled by this module. Defaults to true.
#
# @example Defaults
#   include netbox
#
# @example Downloading from a different repository
#   class { 'netbox':
#     version           => 'x.y.z',
#     download_url      => 'https://my.local.repo.example.com/apache/netbox/netbox-x.y.z.tar.gz',
#     download_checksum => 'abcde...',
#   }
#
class netbox (
  String $secret_key,
  String $version = '2.7.10',
  String $download_url = 'https://github.com/netbox-community/netbox/archive/v2.7.10.tar.gz',
  String $download_checksum = '21743eda8f633761fd9a16c28658235e7ee9a79b15353770b4b1fe0d133a26e5',
  Stdlib::Absolutepath $download_tmp_dir = '/var/tmp',
  String $user = 'netbox',
  String $group = 'netbox',
  String $download_checksum_type = 'sha256',
  Stdlib::Absolutepath $install_root = '/opt',
  Stdlib::Absolutepath $var_directory = '/var/opt/netbox',
  Boolean $should_install = true,
  Boolean $should_configure = true,
  Boolean $handle_database = true,
  Boolean $handle_redis = true,
  Boolean $handle_service = false,
  String $database_name     = 'netbox',
  String $database_user     = 'netbox',
  String $database_password = 'netbox',
  Stdlib::Host $database_host = $trusted['certname'],
  Integer $database_port = 5432,
  Integer $database_conn_max_age = 300,
  Array[Stdlib::Host] $allowed_hosts = ['netbox.exmple.com','newbox.example.com'],
  String $banner_top = '',
  String $banner_bottom = '',
  String $banner_login = '',
  String $base_path = '',
) {

  if $handle_database {
    class { 'netbox::database':
      database_name     => $database_name,
      database_user     => $database_user,
      database_password => $database_password,
    }
  }

  if $handle_redis {
    class { 'netbox::redis':
    }
  }

  if $should_install {
    class { 'netbox::install':
      install_root           => $install_root,
      version                => $version,
      user                   => $user,
      group                  => $group,
      download_url           => $download_url,
      download_checksum      => $download_checksum,
      download_checksum_type => $download_checksum_type,
      download_tmp_dir       => $download_tmp_dir,
    }
  }

  $redis_options = {
    'webhooks' => {
      host => 'localhost',
      port => 6379,
      password => 'password',
      database => 0,
      default_timeout => 300,
      ssl => 'False',
    },
    'caching' => {
      host => 'localhost',
      port => 6379,
      password => 'password',
      database => 1,
      default_timeout => 300,
      ssl => 'False',
    },
  }

  $email_options = {
    server     => 'localhost',
    port       => 25,
    username   => '',
    password   => '',
    timeout    => 10,
    from_email => '',
  }

  if $should_configure {
    class { 'netbox::config':
      user                  => $user,
      group                 => $group,
      install_root          => $install_root,
      allowed_hosts         => $allowed_hosts,
      database_name         => $database_name,
      database_user         => $database_user,
      database_password     => $database_password,
      database_host         => $database_host,
      database_port         => $database_port,
      database_conn_max_age => $database_conn_max_age,
      redis_options         => $redis_options,
      email_options         => $email_options,
      secret_key            => $secret_key,
      banner_top            => $banner_top,
      banner_bottom         => $banner_bottom,
      banner_login          => $banner_login,
      base_path             => $base_path,
    }
  }
  if $handle_service {
    class {'netbox::service':
      install_root => $install_root,
      version      => $version,
      user         => $user,
    }
  }

#  Class['netbox::install'] -> Class['netbox::config'] ~> Class['netbox::service']
}
