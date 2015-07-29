class ssh::server(
  $ensure               = present,
  $storeconfigs_enabled = true,
  $options              = {}
) inherits ssh::params {

  $fin_options = $ssh::server::options ? {
    undef   => $ssh::params::sshd_default_options,
    ''      => $ssh::params::sshd_default_options,
    default => $ssh::server::options,
  }
  notify {"ssh::server fin_options are: ${fin_options}": }

  $merged_options = merge($ssh::params::sshd_default_options, $fin_options)
  notify {"ssh::server merged_options are: ${merged_options}": }

  include ssh::server::install
  include ssh::server::config
  include ssh::server::service

  anchor { 'ssh::server::start': }
  anchor { 'ssh::server::end': }

  # Provide option to *not* use storeconfigs/puppetdb, which means not managing
  #  hostkeys and knownhosts
  if ($storeconfigs_enabled) {
    include ssh::hostkeys
    include ssh::knownhosts

    Anchor['ssh::server::start'] ->
    Class['ssh::server::install'] ->
    Class['ssh::server::config'] ~>
    Class['ssh::server::service'] ->
    Class['ssh::hostkeys'] ->
    Class['ssh::knownhosts'] ->
    Anchor['ssh::server::end']
  } else {
    Anchor['ssh::server::start'] ->
    Class['ssh::server::install'] ->
    Class['ssh::server::config'] ~>
    Class['ssh::server::service'] ->
    Anchor['ssh::server::end']
  }
}
