require 'active_support'

class LHS::Service

  # An endpoint is an url that leads to a backend resource.
  # A service can contain multiple endpoints.
  # The endpoint that is used to request data is choosen
  # based on the provided parameters.
  module Endpoints
    extend ActiveSupport::Concern

    attr_accessor :endpoints

    module ClassMethods

      # Adds the endpoint to the list of endpoints.
      def endpoint(url)
        endpoint = LHC::Endpoint.new(url)
        instance.sanity_check(endpoint)
        instance.endpoints.push(endpoint)
      end
    end

    def initialize
      self.endpoints = []
    end

    # Find an endpoint based on the provided parameters.
    # If no parameters are provided it finds the base endpoint
    # otherwise it finds the endpoint that matches the parameters best.
    def find_endpoint(params = {})
      endpoint = find_best_endpoint(params) if params.keys.count > 0
      endpoint ||= find_base_endpoint
      endpoint
    end

    # Prevent clashing endpoints.
    def sanity_check(endpoint)
      injections = endpoint.injections
      fail 'Clashing endpoints.' if endpoints.any? { |e| e.injections == injections }
    end

    # Computes the url from options
    # by identifiying endpoint and injecting params.
    # Id in options is threaded in a special way.
    def compute_url!(options)
      endpoint = find_endpoint(options)
      url = endpoint.inject(options)
      url +=  "/#{options.delete(:id)}" if options[:id]
      endpoint.remove_injected_params!(options)
      url
    end

    private

    # Finds the best endpoint.
    # The best endpoint is the one that gets all parameters injected
    # and doenst has any injections left empty.
    def find_best_endpoint(params)
      endpoints.find do |endpoint|
        endpoint.injections.all? { |match| endpoint.find_injection(match, params) }
      end
    end

    # Finds the base endpoint.
    # A base endpoint is the one thats has the least amont of injected parameters.
    # There cannot be multiple base endpoints,
    # because this one is used when query the service without any params.
    def find_base_endpoint
      endpoints = self.endpoints.group_by do |endpoint|
        endpoint.injections.length
      end
      bases = endpoints[endpoints.keys.min]
      fail 'Multiple base endpoints found' if bases.count > 1
      bases.first
    end
  end
end
