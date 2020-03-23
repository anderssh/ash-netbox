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
  $venv_dir = "${software_directory}/netbox"

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

  class { 'python':
    version    => '36',
    pip        => 'present',
    dev        => 'present',
    virtualenv => 'present',
    gunicorn   => 'present',
    use_epel   => false,
  }

  python::virtualenv { $venv_dir:
    ensure       => present,
    cwd          => $software_directory,
    version      => 'system',
    requirements => "${software_directory}/requirements.txt",
    systempkgs   => true,
    owner        => $user,
    group        => $group,
  }

  $gunicorn_file = "${software_directory}/gunicorn.py"

  $gunicorn_settings = {
    port                => 8001,
    workers             => 5,
    threads             => 3,
    timeout             => 120,
    max_requests        => 5000,
    max_requests_jitter => 500,
  }
  file { $gunicorn_file:
    content => epp('netbox/gunicorn.py.epp', $gunicorn_settings),
    owner   => $user,
    group   => $group,
    mode    => '0644',
  }
}
