require 'fog/core'
require 'fog/json'

module Fog
  module ElasticStack
    extend Fog::Provider

    service(:servers, 'Virtual Machines')
    service(:drives, 'Drives')
    service(:network, 'Network')

    end
  end
end
