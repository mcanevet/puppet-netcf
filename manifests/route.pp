define netcf::route (
  $interface,
  $order,
  $rule,
  $ensure = 'present',
) {
  $full_rule = "ip route ${rule} || true"

  case $ensure {
    'present': {
      $changes = "set iface[. = '${interface}']/$order[last()+1] '${full_rule}'"
      $onlyif = "match iface[. = '${interface}']/$order[. = '${full_rule}'] size == 0"
    }

    'absent': {
      $changes = "rm iface[. = '${interface}']/$order[. = '${full_rule}']"
      $onlyif = "match iface[. = '${interface}']/$order[. = '${full_rule}'] size != 0"
    }

    default: {
      fail("Unknown value for ensure: ${ensure}")
    }
  }

  augeas { "Manage route ${name}":
    incl    => '/etc/network/interfaces',
    lens    => 'Interfaces.lns',
    changes => $changes,
    onlyif  => $onlyif,
  }
}
