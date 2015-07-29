class ssh::client(
  $ensure               = present,
  $storeconfigs_enabled = true,
  $options              = {}
) inherits ssh::params {

  $fin_options = $ssh::client::options ? {
    undef   => $ssh::params::ssh_default_options,
    ''      => $ssh::params::ssh_default_options,
    default => $ssh::client::options,
  }

  $merged_options = merge($ssh::params::ssh_default_options, $fin_options)

  include ssh::client::install
  include ssh::client::config

  anchor { 'ssh::client::start': }
  anchor { 'ssh::client::end': }

  # Provide option to *not* use storeconfigs/puppetdb, which means not managing
  #  hostkeys and knownhosts
  if ($storeconfigs_enabled) {
    include ssh::knownhosts

    Anchor['ssh::client::start'] ->
    Class['ssh::client::install'] ->
    Class['ssh::client::config'] ->
    Class['ssh::knownhosts'] ->
    Anchor['ssh::client::end']
  } else {
    Anchor['ssh::client::start'] ->
    Class['ssh::client::install'] ->
    Class['ssh::client::config'] ->
    Anchor['ssh::client::end']
  }
}
