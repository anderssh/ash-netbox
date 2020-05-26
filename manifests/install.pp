# @summary Installs Netbox
#
# Installs Netbox
#
# @param install_root
#   The directory where the netbox installation is unpacked
#
# @param version
#   The version of Netbox. This must match the version in the
#   tarball. This is used for managing files, directories and paths in
#   the service.
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
# @param user
#   The user owning the Netbox installation files, and running the
#   service.
#
# @param group
#   The group owning the Netbox installation files, and running the
#   service.
#
# @param install_method
#   Method for getting the Netbox software
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
# @example
#   include netbox::install
class netbox::install (
  Stdlib::Absolutepath $install_root,
  String $version,
  String $download_url,
  String $download_checksum,
  String $download_checksum_type,
  Stdlib::Absolutepath $download_tmp_dir,
  String $user,
  String $group,
  Boolean $include_napalm,
  Boolean $include_django_storages,
  Boolean $include_ldap,
  Boolean $install_dependencies_from_filesystem,
  Stdlib::Absolutepath $python_dependency_path,
  Enum['tarball', 'git_clone'] $install_method = 'tarball',
) {

  $packages =[
    gcc,
    python36,
    python36-devel,
    libxml2-devel,
    libxslt-devel,
    libffi-devel,
    openssl-devel,
    redhat-rpm-config
  ]

  $local_tarball = "${download_tmp_dir}/netbox-${version}.tar.gz"
  $software_directory_with_version = "${install_root}/netbox-${version}"
  $software_directory = "${install_root}/netbox"
  $venv_dir = "${software_directory}/venv"

  $ldap_packages = [openldap-devel]

  package { $packages: ensure => 'installed' }

  if $include_ldap {
    package { $ldap_packages: ensure => 'installed' }
  }

  user { $user:
    system => true,
    gid    => $group,
    home   => $software_directory,
  }

  group { $group:
    system => true,
  }

  if $install_dependencies_from_filesystem {
    $install_requirements_command       = "${venv_dir}/bin/pip3 install -r requirements.txt --no-index --find-links ${python_dependency_path}"
    $install_local_requirements_command = "${venv_dir}/bin/pip3 install -r local_requirements.txt --no-index --find-links ${python_dependency_path}"
  } else {
    $install_requirements_command       = "${venv_dir}/bin/pip3 install -r requirements.txt"
    $install_local_requirements_command = "${venv_dir}/bin/pip3 install -r local_requirements.txt"
  }

  archive { $local_tarball:
    source        => $download_url,
    checksum      => $download_checksum,
    checksum_type => $download_checksum_type,
    extract       => true,
    extract_path  => $install_root,
    creates       => $software_directory_with_version,
    cleanup       => true,
    user          => $user,
    group         => $group,
    notify        => Exec['install python requirements'],
  }
  file { $software_directory:
    ensure => 'link',
    target => $software_directory_with_version,
  }
  file { 'local_requirements':
    ensure => 'present',
    path   => "${software_directory}/local_requirements.txt",
    owner  => $user,
    group  => $group,
  }

  if $include_napalm {
    file_line { 'napalm':
      path    => "${software_directory}/local_requirements.txt",
      line    => 'napalm',
      notify  => Exec['install local python requirements'],
      require => File['local_requirements']
    }
  }

  if $include_django_storages {
    file_line { 'django_storages':
      path    => "${software_directory}/local_requirements.txt",
      line    => 'django-storages',
      notify  => Exec['install local python requirements'],
      require => File['local_requirements']
    }
  }

  if $include_ldap {
    file_line { 'ldap':
      path    => "${software_directory}/local_requirements.txt",
      line    => 'django-auth-ldap',
      notify  => Exec['install local python requirements'],
      require => File['local_requirements']
    }
  }

  exec { 'install local python requirements':
    cwd         => $software_directory,
    path        => [ "${venv_dir}/bin", '/usr/bin', '/usr/sbin' ],
    environment => ["VIRTUAL_ENV=${venv_dir}"],
    provider    => shell,
    user        => $user,
    command     => $install_local_requirements_command,
    onlyif      => "/usr/bin/grep '^[\\t ]*VIRTUAL_ENV=[\\\\'\\\"]*${venv_dir}[\\\"\\\\'][\\t ]*$' ${venv_dir}/bin/activate",
    refreshonly => true,
  }

  exec { "python_venv_${venv_dir}":
    command => "/usr/bin/python3 -m venv ${venv_dir}",
    user    => $user,
    creates => "${venv_dir}/bin/activate",
    cwd     => '/tmp',
    unless  => "/usr/bin/grep '^[\\t ]*VIRTUAL_ENV=[\\\\'\\\"]*${venv_dir}[\\\"\\\\'][\\t ]*$' ${venv_dir}/bin/activate",
  }
  ~>exec { 'install python requirements':
    cwd         => $software_directory,
    path        => [ "${venv_dir}/bin", '/usr/bin', '/usr/sbin' ],
    environment => ["VIRTUAL_ENV=${venv_dir}"],
    provider    => shell,
    user        => $user,
    command     => $install_requirements_command,
    onlyif      => "/usr/bin/grep '^[\\t ]*VIRTUAL_ENV=[\\\\'\\\"]*${venv_dir}[\\\"\\\\'][\\t ]*$' ${venv_dir}/bin/activate",
    refreshonly => true,
  }
}
