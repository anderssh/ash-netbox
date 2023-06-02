# @summary Sets up the PostgreSQL database for netbox
#
# This class sets up PostgreSQL database. This is optional, 
# you can choose to handle that yourself.
#
# @param database_name
#   Name of the PostgreSQL database.
#
# @param database_user
#   Name of the PostgreSQL database user.
#
# @param database_password
#   Name of the PostgreSQL database password.
#
# @param database_encoding
#   Encodding used by the PostgreSQL database.
#
# @param database_locale
#   Locale used by the PostgreSQL database.
#
# @example
#   include netbox::database
class netbox::database (
  String $database_name,
  String $database_user,
  String $database_password,
  String $database_encoding,
  String $database_locale,
){

  class { 'postgresql::globals':
    encoding => $database_encoding,
    locale   => $database_locale,
  }
  ->class { 'postgresql::server':
  }

  postgresql::server::db { $database_name:
    user     => $database_user,
    password => postgresql::postgresql_password($database_name, $database_password),
  }

  postgresql::server::database_grant { 'user_ALL_on_database':
    privilege => 'ALL',
    db        => $database_name,
    role      => $database_user,
  }
}
