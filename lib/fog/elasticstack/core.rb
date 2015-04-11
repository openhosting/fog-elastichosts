require 'fog/core'
require 'fog/json'
require './fog/elasticstack/connection'

module Fog
  module ElasticStack
    extend Fog::Provider

    service(:servers, 'Virtual Machines')
    service(:drives, 'Drives')
    service(:network, 'Network')

  end
end
