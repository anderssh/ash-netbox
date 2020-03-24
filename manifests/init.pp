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
# @param group [String]
#   The group owning the Netbox installation files, and running the
#   service.
#
# @param secret_key [String]
#   A random string of letters, numbers and symbols that Netbox needs.
#   This needs to be supplied, and should be treated as a secret. Should
#   be at least 50 characters long.
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
# @param handle_database [Boolean]
#   Should the PostgreSQL database be handled by this module. Defaults to true.
#
# @param email_server
#   Host name or IP address of the email server (use localhost if running locally)
#   https://netbox.readthedocs.io/en/stable/configuration/optional-settings/#email
#   
# @param email_timeout
#   Amount of time to wait for a connection (seconds)
#   https://netbox.readthedocs.io/en/stable/configuration/optional-settings/#email
#
# @param email_port
#   TCP port to use for the connection (default: 25)
#   https://netbox.readthedocs.io/en/stable/configuration/optional-settings/#email
#
# @param email_username
#   Username with which to authenticate
#   https://netbox.readthedocs.io/en/stable/configuration/optional-settings/#email
#
# @param email_password
#   Password with which to authenticate
#   https://netbox.readthedocs.io/en/stable/configuration/optional-settings/#email
#
# @param email_from_email
#   Sender address for emails sent by NetBox
#   https://netbox.readthedocs.io/en/stable/configuration/optional-settings/#email
#
#
# @param handle_redis [Boolean]
#   Should the Redis installation be handled by this module. Defaults to true.
#
# @param database_name [String]
#   Name of the PostgreSQL database. If handle_database is true, then this database
#   gets created as well. If not, then it is only used by the application, and needs to exist.
#   Defaults to 'netbox'
#
# @param database_user [String]
#   Name of the PostgreSQL database user. If handle_database is true, then this database user
#   gets created as well. If not, then it is only used by the application, and needs to exist.
#   Defaults to 'netbox'
#
# @param database_user [String]
#   Name of the PostgreSQL database password. If handle_database is true, then this database password
#   gets created as well. If not, then it is only used by the application, and needs to exist.
#   Defaults to 'netbox'
#
# @param database_host [String]
#   Name of the PostgreSQL database host. Defaults to 'localhost'
#
# @param database_port [Integer]
#   PostgreSQL database port. NB! The PostgreSQL database that is made when using handle_database
#   does not support configuring a non-standard port. So change this parameter only if using 
#   separate PostgreSQL DB with non-standard port. Defaults to 5432.
#
# @param database_conn_max_age [Integer]
#   Database max connection age in seconds. Defaults to 300.
#
# @param allowed_hosts [Array[String]]
#   Array of valid fully-qualified domain names (FQDNs) for the NetBox server. NetBox will not permit write
#   access to the server via any other hostnames. The first FQDN in the list will be treated as the preferred name.
#   Defaults to: ['netbox.exmple.com','localhost']
#
# @param banner_top [String]
#   Text for top banner on the Netbox webapp
#   Defaults to the empty string
#
# @param banner_bottom [String]
#   Text for bottom banner on the Netbox webapp
#   Defaults to the empty string
#
# @param banner_login [String]
#   Text for login banner on the Netbox webapp
#   Defaults to the empty string
#
# @param base_path [String]
#   Base URL path if accessing NetBox within a directory.
#   For example, if installed at http://example.com/netbox/, set: BASE_PATH = 'netbox/'
#   Defaults to the empty string
#
# @param superuser_username [String]
#   Username for the superuser. This user is created, but without a password. To set the password,
#   you must run  /opt/netbox/venv/bin/python /opt/netbox/netbox/manage.py changepassword
#   Defaults to admin
#
# @param superuser_email [String]
#   Email for the superuser
#   Defaults to 'admin@example.com'
#
# @example Defaults
#   include netbox
#
# @example Downloading from a different repository
#   class { 'netbox':
#     version           => 'x.y.z',
#     download_url      => 'https://my.local.repo.example.com/netbox/netbox-x.y.z.tar.gz',
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
  Boolean $handle_database = true,
  Boolean $handle_redis = true,
  String $database_name     = 'netbox',
  String $database_user     = 'netbox',
  String $database_password = 'netbox',
  Stdlib::Host $database_host = 'localhost',
  Integer $database_port = 5432,
  Integer $database_conn_max_age = 300,
  Array[Stdlib::Host] $allowed_hosts = ['netbox.exmple.com','localhost'],
  String $banner_top = '',
  String $banner_bottom = '',
  String $banner_login = '',
  String $base_path ='',
  String $superuser_username = 'admin',
  String $superuser_email = 'admin@example.com',
  String $email_server = 'localhost',
  Integer $email_timeout = 10,
  Stdlib::Port $email_port = 25,
  String $email_username = '',
  String $email_password = '',
  String $email_from_email = '',
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

  $redis_options = {
    'webhooks' => {
      host => 'localhost',
      port => 6379,
      password => '',
      database => 0,
      default_timeout => 300,
      ssl => 'False',
    },
    'caching' => {
      host => 'localhost',
      port => 6379,
      password => '',
      database => 1,
      default_timeout => 300,
      ssl => 'False',
    },
  }

  $email_options = {
    server     => $email_server,
    port       => $email_port,
    username   => $email_username,
    password   => $email_password,
    timeout    => $email_timeout,
    from_email => $email_from_email,
  }

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
    superuser_username    => $superuser_username,
    superuser_email       => $superuser_email,
  }

  class {'netbox::service':
    install_root => $install_root,
    user         => $user,
    group        => $group,
  }

#  Class['netbox::install'] -> Class['netbox::config'] ~> Class['netbox::service']
}
