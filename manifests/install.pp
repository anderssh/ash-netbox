# @summary Installs Netbox
#
# Installs Netbox
#
# @param install_root
#   The root directory of the netbox installation.
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
  Enum['tarball', 'git_clone'] $install_method = 'tarball',
  Boolean $include_napalm,
  Boolean $include_django_storages,
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

  package { $packages: ensure => 'installed' }

  user { $user:
    system => true,
    gid    => $group,
    home   => $install_root,
  }

  group { $group:
    system => true,
  }

  file { $install_root:
    ensure => directory,
    owner  => 'netbox',
    group  => 'netbox',
    mode   => '0750',
  }

  $local_tarball = "${download_tmp_dir}/netbox-${version}.tar.gz"
  $software_directory_with_version = "${install_root}/netbox-${version}"
  $software_directory = "${install_root}/netbox"
  $venv_dir = "${software_directory}/venv"

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
  }
  file { $software_directory:
    ensure => 'link',
    target => $software_directory_with_version,
  }
  file { 'local_requirements':
    ensure => 'present',
    path   => "${install_root}/netbox/local_requirements.txt",
    owner  => $user,
    group  => $group,
  }

  file_line { 'napalm':
    path   => "${install_root}/netbox/local_requirements.txt",
    line   => 'napalm',
    before => Exec["python_venv_${venv_dir}"],
  }

  file_line { 'django_storages':
    path   => "${install_root}/netbox/local_requirements.txt",
    line   => 'django-storages',
    before => Exec["python_venv_${venv_dir}"],
  }

  exec { "python_venv_${venv_dir}":
    command => "/usr/bin/python3 -m venv ${venv_dir}",
    user    => $user,
    creates => "${venv_dir}/bin/activate",
    cwd     => '/tmp',
    unless  => "/usr/bin/grep '^[\\t ]*VIRTUAL_ENV=[\\\\'\\\"]*${venv_dir}[\\\"\\\\'][\\t ]*$' ${venv_dir}/bin/activate",
  }
  ~>exec { 'install python requirements':
    cwd         => "${install_root}/netbox",
    path        => [ "${venv_dir}/bin", '/usr/bin', '/usr/sbin' ],
    environment => ['VIRTUAL_ENV=/opt/netbox/venv'],
    provider    => shell,
    user        => $user,
    command     => "${venv_dir}/bin/pip3 install -r requirements.txt",
    unless      => "/usr/bin/grep '^[\\t ]*VIRTUAL_ENV=[\\\\'\\\"]*${venv_dir}[\\\"\\\\'][\\t ]*$' ${venv_dir}/bin/activate",
    refreshonly => true,
  }
}
