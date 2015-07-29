class ssh (
  $server_options       = {},
  $client_options       = {},
  $users_client_options = {},
  $version              = 'present',
  $storeconfigs_enabled = true
) inherits ssh::params {

  validate_hash($server_options)
  validate_hash($client_options)
  validate_hash($users_client_options)
  validate_bool($storeconfigs_enabled)

  notify {"ssh::server_options are: ${ssh::server_options}": }
  notify {"server_options are: ${server_options}": }
  #notify {"module_name is: ${module_name}": }
  #notify {"fin_server_options are: ${fin_server_options}": }

  class { 'ssh::server':
    ensure               => $ssh::version,
    storeconfigs_enabled => $ssh::storeconfigs_enabled,
    options              => $ssh::server_options,
  }

  class { 'ssh::client':
    ensure               => $ssh::version,
    storeconfigs_enabled => $ssh::storeconfigs_enabled,
    options              => $ssh::client_options,
  }

  create_resources('::ssh::client::config::user', $ssh::users_client_options)
}
