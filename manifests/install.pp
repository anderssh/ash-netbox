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

  $venv_dir = '/opt/netbox/venv'
    file { $venv_dir:
      ensure => directory,
      owner  => $user,
      group  => $group,
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

  exec { "python_venv_${venv_dir}":
    command => "/usr/bin/python3 -m venv ${venv_dir}",
    user    => $user,
    creates => "${venv_dir}/bin/activate",
    cwd     => '/tmp',
    unless  => "/usr/bin/grep '^[\\t ]*VIRTUAL_ENV=[\\\\'\\\"]*${venv_dir}[\\\"\\\\'][\\t ]*$' ${venv_dir}/bin/activate", #Unless activate exists and VIRTUAL_ENV is correct we re-create the virtualenv
    require => File[$venv_dir],
  }
  ~>exec { 'install python requirements':
    cwd         => "${install_root}/netbox",
    provider    => shell,
    user        => $user,
    command     => ". ${venv_dir}/bin/activate && ${venv_dir}/bin/pip3 install -r requirements.txt",
    refreshonly => true,
  }


}

