# Example of using zookeeper:
#class { '::zookeeper':
#  hostnames => ['h1'],
#}

class { '::kafka':
  realm => 'MONKEY_ISLAND',
  ssl   => true,
}
