# @summary Sets up the PostgreSQL database for netbox
#
# This class sets up PostgreSQL database. This is optional, 
# you can choose to handle that yourself.
#
# @example
#   include netbox::database
class netbox::database (
  String $database_name = 'netbox',
  String $database_user = 'netbox',
  String $user_password = 'mypassword'
){

  class { 'postgresql::server':
}

  postgresql::server::db { $database_name:
    user     => $database_user,
    password => postgresql_password($database_name, $database_user),
  }
  postgresql::server::database_grant { 'user_ALL_on_database':
    privilege => 'ALL',
    db        => $database_name,
    role      => $database_user,
  }
}
