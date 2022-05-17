# @summary Manage the Netbox and Netvox-rq Systemd services
#
# @param install_root
#   The directory where the netbox installation is unpacked
#
# @param user
#   The user running the
#   service.
#
# @param group
#   The group running the
#   service.
#
# A class for running Netbox as a Systemd service
#
class netbox::service (
  Stdlib::Absolutepath $install_root,
  String $user,
  String $group,
  Stdlib::Absolutepath $access_logfile,
  Stdlib::Absolutepath $error_logfile,
){

  $netbox_pid_file = '/var/tmp/netbox.pid'

  $service_params_netbox_rq = {
    'netbox_home'  => "${install_root}/netbox",
    'user'         => $user,
    'group'        => $group,
  }

  $service_params_netbox = {
    'netbox_home'    => "${install_root}/netbox",
    'user'           => $user,
    'group'          => $group,
    'pidfile'        => $netbox_pid_file,
    'access_logfile' => $access_logfile,
    'error_logfile'  => $error_logfile,
  }

  systemd::unit_file { 'netbox-rq.service':
    content => epp('netbox/netbox-rq.service.epp', $service_params_netbox_rq),
    enable  => true,
    active  => true,
  }

  systemd::unit_file { 'netbox.service':
    content => epp('netbox/netbox.service.epp', $service_params_netbox),
    enable  => true,
    active  => true,
  }
}
