# @summary Install Netbox
#
# A class for installing Netbox
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
  Boolean $included = true
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

  $local_tarball = "${download_tmp_dir}/netbox-${version}.tar.gz"
  $software_directory = "${install_root}/netbox-${version}"

  archive { $local_tarball:
    source        => $download_url,
    checksum      => $download_checksum,
    checksum_type => $download_checksum_type,
    extract       => true,
    extract_path  => $install_root,
    creates       => $software_directory,
    cleanup       => true,
    user          => $user,
    group         => $group,
  }
  file { '/opt/netbox':
    ensure => 'link',
    target => $software_directory,
  }

  python::pyvenv { '/opt/netbox/venv' :
  ensure     => present,
  version    => 'system',
  systempkgs => true,
  owner      => $user,
  group      => $user,
}

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
}

