require 'active_support'
require File.dirname(__FILE__) + '/../../proxy'

class LHS::Item < LHS::Proxy

  module Update
    extend ActiveSupport::Concern

    def update(params)
      update!(params)
    rescue LHC::Error => e
      self.errors = LHS::Errors.new(e.response)
      false
    end

    def update!(params)
      record = _data._root._record_class
      _data.merge_raw!(LHS::Data.new(params))
      response_data = record.request(
        method: :post,
        url: href,
        body: _data.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )
      _data.merge_raw!(response_data)
      true
    end
  end
end
