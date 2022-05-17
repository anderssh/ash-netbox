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
# @param repo_url
#   URL for the git repo to perform the clone.
#
# @param repo_branch
#   Which branch to clone.
#   Defaults to master.
#
# @param manage_packages
#   Boolean for wether packages should be installed by the module or not.
#
# @param packages
#   List of packages to be installed.
#
# @param ldap_packages
#   List of ldap pacakges to install should ldap be enabled.
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
  Enum['tarball', 'git_clone'] $install_method = 'tarball',
  # added fauzi@uchicago.edu
  String $repo_url    = 'https://github.com/netbox-community/netbox.git',
  String $repo_branch = "master",
  Boolean $manage_packages,
  Array $packages = [],
  Array $ldap_packages = []
) {

  $local_tarball = "${download_tmp_dir}/netbox-${version}.tar.gz"
  $software_directory_with_version = "${install_root}/netbox-${version}"
  $software_directory = "${install_root}/netbox"
  $venv_dir = "${software_directory}/venv"

  if $manage_packages {
    ensure_packages($packages)
  }

  if $include_ldap {
    ensure_packages($ldap_packages)
  }

  user { $user:
    system => true,
    gid    => $group,
    home   => $software_directory,
  }

  group { $group:
    system => true,
  }

  if $install_method == "tarball" {
    archive { $local_tarball:
      source        => $download_url,
      checksum      => $download_checksum,
      checksum_type => $download_checksum_type,
      extract       => true,
      extract_path  => $install_root,
      creates       => $software_directory_with_version,
      cleanup       => true,
      notify        => Exec['install python requirements'],
    }

    exec { 'netbox permission':
      command     => "chown -R ${user}:${group} ${software_directory_with_version}",
      path        => ['/usr/bin'],
      subscribe   => Archive[$local_tarball],
      refreshonly => true,
    }

    file { $software_directory:
      ensure => 'link',
      target => $software_directory_with_version,
    }
  } elsif $install_method == 'git_clone' {
    vcsrepo { $software_directory:
      ensure   => present,
      provider => 'git',
      source   => "${repo_url}",
      branch   => "${repo_branch}",
      depth    => 1,
      owner    => "${user}",
      group    => "${group}",
      notify   => Python::Requirements["${software_directory}/requirements.txt"],
    }
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
      notify  => Python::Requirements["${software_directory}/local_requirements.txt"],
      require => File['local_requirements']
    }
  }

  if $include_django_storages {
    file_line { 'django_storages':
      path    => "${software_directory}/local_requirements.txt",
      line    => 'django-storages',
      notify  => Python::Requirements["${software_directory}/local_requirements.txt"],
      require => File['local_requirements']
    }
  }

  if $include_ldap {
    file_line { 'ldap':
      path    => "${software_directory}/local_requirements.txt",
      line    => 'django-auth-ldap',
      notify  => Python::Requirements["${software_directory}/local_requirements.txt"],
      require => File['local_requirements']
    }
  }

  include python

  python::pyvenv { $venv_dir:
    ensure  => present,
    version => 'system',
    owner   => "${user}",
    group   => "${group}",
  }

  python::requirements { "${software_directory}/requirements.txt":
    virtualenv => "${venv_dir}",
    owner   => "${user}",
    group   => "${group}",
  }
  ~>python::requirements { "${software_directory}/local_requirements.txt":
    virtualenv => "${venv_dir}",
    owner   => "${user}",
    group   => "${group}",
  }

}
