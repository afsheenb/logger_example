# == Define kafka::properties
#
# Generic resource to generate properties files
#
define kafka::properties($owner, $group, $mode, $properties) {
  file { $title:
    owner   => $owner,
    group   => $group,
    mode    => $mode,
    content => template('kafka/properties.erb'),
  }
}
