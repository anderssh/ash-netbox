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
#   The directory where the netbox installation is unpacked
#
# @param handle_database
#   Should the PostgreSQL database be handled by this module.
#
# @param include_napalm
#   NAPALM allows NetBox to fetch live data from devices and return it to a requester via its REST API.
#   Installation of NAPALM is optional. To enable it, set $include_napalm to true
#
# @param include_django_storages
#   By default, NetBox will use the local filesystem to storage uploaded files.
#   To use a remote filesystem, install the django-storages library and configure your desired backend in configuration.py.
#
# @param include_ldap
#   Makes sure the packages and the python modules needed for LDAP-authentication are installed and loaded.
#   The LDAP-config itself is not handled by this Puppet module at present.
#   Use the documentation found here: https://netbox.readthedocs.io/en/stable/installation/5-ldap/ for information about
#   the config file.
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
# @param handle_redis
#   Should the Redis installation be handled by this module. Defaults to true.
#
# @param install_dependencies_from_filesystem
#   Used if your machine can't reach the place pip would normally go to fetch dependencies
#   as it would when running "pip install -r requirements.txt". Then you would have to
#   fetch those dependencies beforehand and put them somewhere your machine can reach.
#   This can be done by running (on a machine that can reach pip's normal sources) the following:
#   pip download -r <requirements.txt>  -d <destination>
#   Remember to do this on local_requirements.txt also if you have one.
#
# @param python_dependency_path
#   Path to where pip can find packages when the variable $install_dependencies_from_filesystem is true
#
# @param database_name
#   Name of the PostgreSQL database. If handle_database is true, then this database
#   gets created as well. If not, then it is only used by the application, and needs to exist.
#   Defaults to 'netbox'
#
# @param database_user
#   Name of the PostgreSQL database user. If handle_database is true, then this database user
#   gets created as well. If not, then it is only used by the application, and needs to exist.
#   Defaults to 'netbox'
#
# @param database_password
#   Name of the PostgreSQL database password. If handle_database is true, then this database password
#   gets created as well. If not, then it is only used by the application, and needs to exist.
#   Defaults to 'netbox'
#
# @param database_encoding
#   Encoding of the PostgreSQL database. If handle_database is false, this does nothing.
#   Defaults to 'UTF-8'
#
# @param database_locale
#   Locale of the PostgreSQL database. If handle_database is false, this does nothing.
#   Defaults to 'en_US.UTF-8''
#
# @param database_host
#   Name of the PostgreSQL database host. Defaults to 'localhost'
#
# @param database_port
#   PostgreSQL database port. NB! The PostgreSQL database that is made when using handle_database
#   does not support configuring a non-standard port. So change this parameter only if using
#   separate PostgreSQL DB with non-standard port. Defaults to 5432.
#
# @param database_conn_max_age
#   Database max connection age in seconds. Defaults to 300.
#
# @param allowed_hosts
#   Array of valid fully-qualified domain names (FQDNs) for the NetBox server. NetBox will not permit write
#   access to the server via any other hostnames. The first FQDN in the list will be treated as the preferred name.
#
# @param banner_top
#   Text for top banner on the Netbox webapp
#   Defaults to the empty string
#
# @param banner_bottom
#   Text for bottom banner on the Netbox webapp
#   Defaults to the empty string
#
# @param banner_login
#   Text for login banner on the Netbox webapp
#   Defaults to the empty string
#
# @param base_path
#   Base URL path if accessing NetBox within a directory.
#   For example, if installed at http://example.com/netbox/, set: BASE_PATH = 'netbox/'
#
# @param admins
#   Array of hashes with two keys, 'name' and 'email'. This is where the email goes if something goes wrong
#   This feature (in the Puppet module) is not well tested.
#
# @param debug
#   Set to True to enable server debugging. WARNING: Debugging introduces a substantial performance penalty and may reveal
#   sensitive information about your installation. Only enable debugging while performing testing. Never enable debugging
#   on a production system.
#
# @param login_required
#   Setting this to True will permit only authenticated users to access any part of NetBox. By default, anonymous users
#   are permitted to access most data in NetBox (excluding secrets) but not make any changes.
#
# @param metrics_enabled
#   Setting this to true exposes Prometheus metrics at /metrics.
#   See the Promethues Metrics documentation for more details:
#   https://netbox.readthedocs.io/en/stable/additional-features/prometheus-metrics/)
#
# @param enforce_global_unique
#   Enforcement of unique IP space can be toggled on a per-VRF basis. To enforce unique IP space within the global table
#   (all prefixes and IP addresses not assigned to a VRF), set ENFORCE_GLOBAL_UNIQUE to True.
#
# @param prefer_ipv4
#   When determining the primary IP address for a device, IPv6 is preferred over IPv4 by default. Set this to True to
#   prefer IPv4 instead.
#
# @param exempt_view_permissions
#   Exempt certain models from the enforcement of view permissions. Models listed here will be viewable by all users and
#   by anonymous users. List models in the form `<app>.<model>`. Add '*' to this list to exempt all models.
#
# @param napalm_username
#   Username that NetBox will uses to authenticate to devices when connecting via NAPALM.
#
# @param napalm_password
#   Password that NetBox will uses to authenticate to devices when connecting via NAPALM.
#
# @param napalm_timeout
#   NAPALM timeout (in seconds).
#
# @param time_zone
#   Time zone
#
# @param date_format
#   Date/time formatting. See the following link for supported formats:
#   https://docs.djangoproject.com/en/stable/ref/templates/builtins/#date
#
# @param short_date_format
#   Date/time formatting. See the following link for supported formats:
#   https://docs.djangoproject.com/en/stable/ref/templates/builtins/#date
#
# @param time_format
#   Date/time formatting. See the following link for supported formats:
#   https://docs.djangoproject.com/en/stable/ref/templates/builtins/#date
#
# @param short_time_format
#   Date/time formatting. See the following link for supported formats:
#   https://docs.djangoproject.com/en/stable/ref/templates/builtins/#date
#
# @param datetime_format
#   Date/time formatting. See the following link for supported formats:
#   https://docs.djangoproject.com/en/stable/ref/templates/builtins/#date
#
# @param short_datetime_format
#   Date/time formatting. See the following link for supported formats:
#   https://docs.djangoproject.com/en/stable/ref/templates/builtins/#date
#
# @example Defaults
#   class { 'netbox':
#     secret_key => $my_secret_variable
#   }
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
  String $version = '2.10.1',
  String $download_url = 'https://github.com/netbox-community/netbox/archive/v2.10.1.tar.gz',
  String $download_checksum = 'b827c520e4c82842e426a5f9ad2d914d1728a3671e304d5f25eb06392c24866c',
  Stdlib::Absolutepath $download_tmp_dir = '/var/tmp',
  String $user = 'netbox',
  String $group = 'netbox',
  String $download_checksum_type = 'sha256',
  Stdlib::Absolutepath $install_root = '/opt',
  Boolean $handle_database = true,
  Boolean $handle_redis = true,
  Boolean $install_dependencies_from_filesystem = false,
  Stdlib::Absolutepath $python_dependency_path = '/srv/python_dependencies',
  Boolean $include_napalm = true,
  Boolean $include_django_storages = true,
  Boolean $include_ldap = true,
  String $database_name       = 'netbox',
  String $database_user       = 'netbox',
  String $database_password   = 'netbox',
  String $database_encoding   = 'UTF-8',
  String $database_locale     = 'en_US.UTF-8',
  Stdlib::Host $database_host = 'localhost',
  Integer $database_port = 5432,
  Integer $database_conn_max_age = 300,
  Array[Stdlib::Host] $allowed_hosts = ['netbox.exmple.com','localhost'],
  String $banner_top = '',
  String $banner_bottom = '',
  String $banner_login = '',
  String $base_path ='',
  Array $admins = [],
  Boolean $debug = false,
  Boolean $enforce_global_unique = false,
  Boolean $login_required = false,
  Boolean $metrics_enabled = false,
  Boolean $prefer_ipv4 = false,
  Array $exempt_view_permissions = [],
  String $napalm_username = '',
  String $napalm_password = '',
  Integer $napalm_timeout = 30,
  String $email_server = 'localhost',
  Integer $email_timeout = 10,
  Stdlib::Port $email_port = 25,
  String $email_username = '',
  String $email_password = '',
  String $email_from_email = '',
  String $time_zone = 'UTC',
  String $date_format = 'N j, Y',
  String $short_date_format = 'Y-m-d',
  String $time_format = 'g:i a',
  String $short_time_format = 'H:i:s',
  String $datetime_format = 'N j, Y g:i a',
  String $short_datetime_format = 'Y-m-d H:i',
) {

  Class['netbox::install'] -> Class['netbox::config'] ~> Class['netbox::service']

  if $handle_database {
    class { 'netbox::database':
      database_name     => $database_name,
      database_user     => $database_user,
      database_password => $database_password,
      database_encoding => $database_encoding,
      database_locale   => $database_locale,
    }
    if $handle_redis {
      Class['netbox::database'] -> Class['netbox::redis']
    } else {
      Class['netbox::database'] -> Class['netbox::install']
    }
  }

  if $handle_redis {
    class { 'netbox::redis':
    }
    Class['netbox::redis'] -> Class['netbox::install']
  }

  class { 'netbox::install':
    install_root                         => $install_root,
    version                              => $version,
    user                                 => $user,
    group                                => $group,
    download_url                         => $download_url,
    download_checksum                    => $download_checksum,
    download_checksum_type               => $download_checksum_type,
    download_tmp_dir                     => $download_tmp_dir,
    include_napalm                       => $include_napalm,
    include_django_storages              => $include_django_storages,
    include_ldap                         => $include_ldap,
    install_dependencies_from_filesystem => $install_dependencies_from_filesystem,
    python_dependency_path               => $python_dependency_path,
  }

  $redis_options = {
    'tasks' => {
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
    version                 => $version,
    user                    => $user,
    group                   => $group,
    install_root            => $install_root,
    allowed_hosts           => $allowed_hosts,
    database_name           => $database_name,
    database_user           => $database_user,
    database_password       => $database_password,
    database_host           => $database_host,
    database_port           => $database_port,
    database_conn_max_age   => $database_conn_max_age,
    redis_options           => $redis_options,
    email_options           => $email_options,
    secret_key              => $secret_key,
    admins                  => $admins,
    banner_top              => $banner_top,
    banner_bottom           => $banner_bottom,
    banner_login            => $banner_login,
    base_path               => $base_path,
    debug                   => $debug,
    enforce_global_unique   => $enforce_global_unique,
    login_required          => $login_required,
    metrics_enabled         => $metrics_enabled,
    prefer_ipv4             => $prefer_ipv4,
    exempt_view_permissions => $exempt_view_permissions,
    napalm_username         => $napalm_username,
    napalm_password         => $napalm_password,
    napalm_timeout          => $napalm_timeout,
    time_zone               => $time_zone,
    date_format             => $date_format,
    short_date_format       => $short_date_format,
    time_format             => $time_format,
    short_time_format       => $short_time_format,
    datetime_format         => $datetime_format,
    short_datetime_format   => $short_datetime_format,
  }

  class {'netbox::service':
    install_root => $install_root,
    user         => $user,
    group        => $group,
  }
}
